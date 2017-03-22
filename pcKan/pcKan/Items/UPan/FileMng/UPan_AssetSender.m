//
//  UPan_AssetSender.m
//  pcKan
//
//  Created by admin on 17/3/22.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_AssetSender.h"

@interface UPan_AssetSender ()
@property (nonatomic, strong) NSData *mSendData;
@end

@implementation UPan_AssetSender

-(instancetype)initWithFileData:(NSData *)fileData fileId:(NSInteger)fileId fileName:(NSString *)fileName
{
    if (self = [super init]){
        _mSendData = fileData;
        self.mFileId = fileId;
        [self threadWithName:[NSString stringWithFormat:@"fThread_pic_%@", fileName]
                       Start:@selector(fileDataThread:)
                      target:self obj:self];
    }
    return self;
}

//直接发送数据线程
-(void)fileDataThread:(id)obj
{
    __weak UPan_AssetSender *fileSender = (UPan_AssetSender *)obj;
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

    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(didSendFinish:)]) {
        [self.m_delegate didSendFinish:fileSender.threadName];
    }
    NSLog(@"file Send complete");
}
@end
