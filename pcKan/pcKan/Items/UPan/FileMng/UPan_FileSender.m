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

static const NSInteger MaxReadSize = (1024*1024);

@interface UPan_FileSender ()
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) NSInteger sendLength;
@property (nonatomic, assign) NSInteger mFileId;
@property (nonatomic, strong) NSThread *mThread;
@end

@implementation UPan_FileSender
-(instancetype)initWithFilePath:(NSString *)filePath fileId:(NSInteger)fileId
{
    if (self = [super init]) {
        _filePath = filePath;
        _mFileId = fileId;
        
        NSString *threadName = [NSString stringWithFormat:@"mvThread_%zd", fileId];
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(mvThread:) object:self];
        [thread setName:threadName];
        [thread start];
        _mThread = thread;
        _threadName = threadName;
    }
    return self;
}

-(void)cancel
{
    [_mThread cancel];
}

-(void)postNotification:(CGFloat)persent fileId:(NSInteger)fileId speed:(CGFloat)speed
{
    NSNotificationCenter *nofity = [NSNotificationCenter defaultCenter];
    [nofity postNotificationName:kNotificationFileSendPersent
                          object:@{ptl_fileId:@(fileId),
                                   ptl_persent:@(persent),
                                   ptl_speed:@(speed)}];
}

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
        [self postNotification:persent fileId:fileId sp];
        
        NSData *reData = [self resetForSendData:data fid:fileSender.mFileId];
        [pssLink sendFileData:reData];
//        NSLog(@"send size:%zd", reData.length);
        usleep(50000);
    }
    
    [fileHandle closeFile];
    
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(didSendFinish:)]) {
        [self.m_delegate didSendFinish:fileSender.threadName];
    }
}

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

-(NSData *)resetForSendData:(NSData *)pSrc fid:(unsigned long long)fid
{
    int sizeSpace = sizeof(unsigned long long);
    int headerSize = sizeof(stPssProtocolHead);
    NSMutableData *muData = [[NSMutableData alloc] initWithLength:(headerSize+pSrc.length+sizeSpace)];
    
    uint8_t *pDes = (uint8_t *)[muData bytes];
    memcpy(pDes+headerSize, &fid, sizeof(fid));
    memcpy(pDes+headerSize+sizeSpace, [pSrc bytes], pSrc.length);
    return muData;
}
@end
