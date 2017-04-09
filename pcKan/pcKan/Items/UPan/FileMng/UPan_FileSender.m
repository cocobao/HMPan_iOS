//
//  UPan_FileSender.m
//  pcKan
//
//  Created by admin on 2017/3/10.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_FileSender.h"
#import "UPan_FileMng.h"
#import "pSSAlbumAsset.h"

@interface UPan_FileSender ()
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) NSInteger sendLength;
@end

@implementation UPan_FileSender
-(instancetype)initWithFilePath:(NSString *)filePath fileId:(NSInteger)fileId
{
    if (self = [super init]) {
        _filePath = filePath;
        self.mFileId = fileId;
 
        [self threadWithName:[NSString stringWithFormat:@"mvThread_%zd", self.mFileId]
                       Start:@selector(mvThread:)
                      target:self
                         obj:self];
    }
    return self;
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
        NSData *reData = [self resetForSendData:data fid:fileSender.mFileId];
        [pssLink sendFileData:reData];
        //通知当前发送进度
        _sendLength = offset;
        CGFloat persent = _sendLength*100/fileSize;
        time_t nowTime = time(NULL);
        CGFloat speed = (CGFloat)offset/(nowTime - startTime);
        
        [self postNotification:persent fileId:fileId speed:speed];
        
//        NSLog(@"send size:%zd", reData.length);
        usleep(1000000);
    }
    
    [fileHandle closeFile];

    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(didSendFinish:)]) {
        [self.m_delegate didSendFinish:fileSender.threadName];
    }
}


@end
