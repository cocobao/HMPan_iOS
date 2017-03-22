//
//  UPan_FileBaseSender.m
//  pcKan
//
//  Created by admin on 17/3/22.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_FileBaseSender.h"

@implementation UPan_FileBaseSender
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

-(void)postNotification:(CGFloat)persent fileId:(NSInteger)fileId speed:(CGFloat)speed
{
    if (persent - _lastPostPersent >= 1) {
        _lastPostPersent = persent;
        NSNotificationCenter *nofity = [NSNotificationCenter defaultCenter];
        [nofity postNotificationName:kNotificationFileSendPersent
                              object:@{ptl_fileId:@(fileId),
                                       ptl_persent:@(persent),
                                       ptl_speed:@(speed)}];
    }
}

-(void)threadWithName:(NSString *)threadName Start:(SEL)selector target:(id)target obj:(id)obj
{
    NSThread *thread = [[NSThread alloc] initWithTarget:target selector:selector object:obj];
    [thread setName:threadName];
    
    _mThread = thread;
    _threadName = threadName;
}

-(void)start
{
    if (_mThread) {
        [_mThread start];
    }
}

-(void)cancel
{
    if (_mThread) {
        [_mThread cancel];
        _mThread = nil;
    }
}
@end
