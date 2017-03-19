//
//  UPan_FileSender.m
//  pcKan
//
//  Created by admin on 2017/3/10.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_FileSender.h"
#import "UPan_FileMng.h"
#import "pssProtocolType.h"
#import "pSSAlbumAsset.h"

static const NSInteger MaxReadSize = (1024*512);

@interface UPan_FileSender ()
{
    CGFloat lastPostPersent;
}
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) NSInteger sendLength;
@property (nonatomic, assign) NSInteger mFileId;
@property (nonatomic, strong) NSThread *mThread;
@property (nonatomic, strong) NSData *mSendData;
@end

@implementation UPan_FileSender
-(instancetype)initWithFilePath:(NSString *)filePath fileId:(NSInteger)fileId
{
    if (self = [super init]) {
        _filePath = filePath;
        _mFileId = fileId;
        lastPostPersent = 0;
        
        [self threadWithName:[NSString stringWithFormat:@"mvThread_%zd", _mFileId] Start:@selector(mvThread:)];
    }
    return self;
}

-(instancetype)initWithFileData:(NSData *)fileData fileId:(NSInteger)fileId fileName:(NSString *)fileName
{
    if (self = [super init]){
        lastPostPersent = 0;
        _mSendData = fileData;
        _mFileId = fileId;
        [self threadWithName:[NSString stringWithFormat:@"fThread_pic_%@", fileName] Start:@selector(fileDataThread:)];
    }
    return self;
}

-(void)threadWithName:(NSString *)threadName Start:(SEL)selector
{
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:selector object:self];
    [thread setName:threadName];
    [thread start];
    _mThread = thread;
    _threadName = threadName;
}

-(void)cancel
{
    if (_mThread) {
        [_mThread cancel];
    }
}

-(void)postNotification:(CGFloat)persent fileId:(NSInteger)fileId speed:(CGFloat)speed
{
    if (persent - lastPostPersent >= 1) {
        lastPostPersent = persent;
        NSNotificationCenter *nofity = [NSNotificationCenter defaultCenter];
        [nofity postNotificationName:kNotificationFileSendPersent
                              object:@{ptl_fileId:@(fileId),
                                       ptl_persent:@(persent),
                                       ptl_speed:@(speed)}];
    }
}

//直接发送数据线程
-(void)fileDataThread:(id)obj
{
    __weak UPan_FileSender *fileSender = (UPan_FileSender *)obj;
    NSInteger offset = 0;
    NSData *data = fileSender.mSendData;
    
    NSThread *currentThread = [NSThread currentThread];
    do {
        if (currentThread.isCancelled) {
            NSLog(@"thread is cannel");
            break;
        }
        
        NSInteger readSize = 0;
        if (data.length - offset > MaxReadSize) {
            readSize = MaxReadSize;
        }else{
            readSize = data.length - offset;
        }
        
        NSData *tmpData = [NSData dataWithBytes:(void *)(data.bytes + offset) length:readSize];
        NSData *reData = [self resetForSendData:tmpData fid:fileSender.mFileId];
        offset += readSize;
        [pssLink sendFileData:reData];
        usleep(80000);
    }while (offset < data.length);
    _mThread = nil;
    
    NSLog(@"file Send complete");
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(didSendFinish:)]) {
        [self.m_delegate didSendFinish:fileSender.threadName];
    }
}

//读取文件数据发送线程
-(void)mvThread:(id)obj
{
    __weak UPan_FileSender *fileSender = (UPan_FileSender *)obj;
    
    NSDictionary *info = [UPan_FileMng fileAttriutes:fileSender.filePath];
    NSInteger fileSize = [info[NSFileSize] integerValue];
    NSInteger fileId = [info[NSFileSystemFileNumber] integerValue];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fileSender.filePath];
    NSInteger offset = 0;
    NSThread *currentThread = [NSThread currentThread];
    time_t startTime = time(NULL);
    for(;;){
        if (currentThread.isCancelled) {
            NSLog(@"thread is cannel");
            break;
        }
        
        [fileHandle seekToFileOffset:offset];
        NSData *data = [self readFileHandle:fileHandle offset:offset fileSize:fileSize];
        if (!data) {
            NSLog(@"finish");
            break;
        }
        offset += data.length;
        _sendLength = offset;
        CGFloat persent = _sendLength*100/fileSize;
        time_t nowTime = time(NULL);
        CGFloat speed = (CGFloat)offset/(nowTime - startTime);
        [self postNotification:persent fileId:fileId speed:speed];
        
        NSData *reData = [self resetForSendData:data fid:fileSender.mFileId];
        [pssLink sendFileData:reData];
//        NSLog(@"send size:%zd", reData.length);
        usleep(80000);
    }
    
    [fileHandle closeFile];
    _mThread = nil;
    
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(didSendFinish:)]) {
        [self.m_delegate didSendFinish:fileSender.threadName];
    }
}

//从文件里读取数据
-(NSData *)readFileHandle:(NSFileHandle *)handle offset:(NSInteger)offSet fileSize:(NSInteger)fileSize
{
    NSInteger readSize = 0;
    if (fileSize - offSet > MaxReadSize) {
        readSize = MaxReadSize;
    }else{
        readSize = fileSize - offSet;
    }
    
    if (readSize <= 0) {
        return nil;
    }
    
    return [handle readDataOfLength:readSize];
}

//把数据调整为对端可解格式
-(NSData *)resetForSendData:(NSData *)pSrc fid:(unsigned long long)fid
{
    int sizeSpace = sizeof(unsigned long long);
    int headerSize = sizeof(stPssProtocolHead);
    NSMutableData *muData = [[NSMutableData alloc] initWithLength:(headerSize+pSrc.length+sizeSpace)];
    
    uint8_t *pDes = (uint8_t *)[muData bytes];
    //添加文件ID
    memcpy(pDes+headerSize, &fid, sizeof(fid));
    //添加文件数据
    memcpy(pDes+headerSize+sizeSpace, [pSrc bytes], pSrc.length);
    return muData;
}
@end
