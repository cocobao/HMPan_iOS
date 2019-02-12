//
//  UPan_FileRecver.m
//  pcKan
//
//  Created by admin on 2017/3/9.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_FileRecver.h"
#import "pssLinkObj+Api.h"
#import "UPan_FileMng.h"

@interface UPan_FileRecver ()
{
    time_t startTime;
    NSInteger lastCalSize;
}
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) dispatch_queue_t recvQue;
@end

@implementation UPan_FileRecver
-(instancetype)initWithFileId:(NSInteger)fileId filePath:(NSString *)filePath pcFilePath:(NSString *)pcFilePath fileSize:(NSInteger)fileSize
{
    self = [super init];
    if (self) {
        _fileId = fileId;
        _filePath = filePath;
        _pcFilePath = pcFilePath;
        _fileSize = fileSize;
        _seek = 0;
        _persent = 0;
        _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        startTime = time(NULL);
        _recvQue = dispatch_queue_create("fileRecvQue", nil);
        _isSuspend = NO;
        lastCalSize = 0;
        
        [self registartNotify];
    }
    return self;
}

-(instancetype)initWithInfoDict:(NSDictionary *)infoDict
{
    self = [super init];
    if (self) {
        _fileId = [infoDict[ptl_fileId] integerValue];
        _filePath = infoDict[ptl_filePath];
        _pcFilePath = infoDict[ptl_pcFilePath];
        _fileSize = [infoDict[ptl_fileSize] integerValue];
        _seek = [infoDict[ptl_seek] integerValue];
        _persent = ((double)_seek/_fileSize)*100;
        _isSuspend = NO;
        lastCalSize = 0;
        
        startTime = time(NULL);
        _recvQue = dispatch_queue_create("fileRecvQue", nil);
        _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
        
        [self registartNotify];
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"dealloc UPan_FileRecver, %zd", _fileId);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)registartNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logoutNotify:)
                                                 name:kNotificationLogout
                                               object:nil];
}

-(void)logoutNotify:(NSNotification *)notify
{
    NSLog(@"recver suspend, file id:%zd", _fileId);
    _isSuspend = YES;
}

-(void)applyFilePart
{
    if (_isSuspend) {
        return;
    }
    
    if (UserInfo.isLogin && [pssLink tcpLinkStatus] == tcpConnect_ConnectOk) {
        [pssLink NetApi_FilePartWithFileId:_fileId pcFilePath:_pcFilePath seek:_seek block:nil];
        _isSuspend = NO;
    }else{
        NSLog(@"recver suspend, file id:%zd", _fileId);
        _isSuspend = YES;
    }
}

//重新请求传输
-(void)reApply
{
    if (_isSuspend)
        return;
    startTime = time(NULL);
    
    [self applyFilePart];
}

//保存当前的传输信息
-(void)saveInfoFile
{
    NSDictionary *dict = @{
                           ptl_fileId:@(_fileId),
                           ptl_filePath:_filePath,
                           ptl_pcFilePath:_pcFilePath,
                           ptl_seek:@(_seek),
                           ptl_fileSize:@(_fileSize),
                           };
    NSData *data = [pSSCommodMethod dictionaryToJsonData:dict];
    NSString *infoFile = [NSString stringWithFormat:@"%@.hmf", _filePath];
    [UPan_FileMng writeFile:infoFile data:data];
}

//删除传输信息文件
-(void)removeInfoFile
{
    NSString *infoFile = [NSString stringWithFormat:@"%@.hmf", _filePath];
    [UPan_FileMng deleteFile:infoFile];
}

//写数据到文件
-(void)writeFileData:(NSData *)data
{
    [_fileHandle seekToEndOfFile];
    [_fileHandle writeData:data];
    
    _seek += data.length;
    lastCalSize += data.length;
    [self saveInfoFile];
    
    if (_seek >= _fileSize) {
        _persent = 100;
    }else{
        //设置传输进度
        _persent = ((double)_seek/_fileSize)*100;
    }
    
    time_t nowTime = time(NULL);
    if (nowTime - startTime >= 1 || _persent >= 100) {
        CGFloat speed = (CGFloat)lastCalSize/(nowTime - startTime);
        lastCalSize = 0;
        
        startTime = nowTime;
        NSNotificationCenter *nofity = [NSNotificationCenter defaultCenter];
        [nofity postNotificationName:kNotificationFileRecvPersent
                              object:@{ptl_fileId:@(_fileId),
                                       ptl_persent:@(_persent),
                                       ptl_seek:@(_seek),
                                       ptl_speed:@(speed)}];
    }
    
    if (_persent == 100) {
        //传输完毕
        [self closeFile];
        [self removeInfoFile];
        usleep(50000);
        if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(didRecvFileFinish:)]) {
            [self.m_delegate didRecvFileFinish:self.fileId];
        }
    }else{
        WeakSelf(weakSelf);
        dispatch_async(_recvQue, ^{
            usleep(10000);
//            请求接收下一个包
            [weakSelf applyFilePart];
        });
    }
}

-(void)closeFile
{
    if (_fileHandle) {
        [_fileHandle closeFile];
        _fileHandle = nil;
    }
}


@end
