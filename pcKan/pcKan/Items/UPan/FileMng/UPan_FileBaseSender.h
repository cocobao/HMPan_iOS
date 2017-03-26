//
//  UPan_FileBaseSender.h
//  pcKan
//
//  Created by admin on 17/3/22.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pssProtocolType.h"
#import "pssLinkObj+Api.h"

@protocol picFileSenderDelegate <NSObject>
-(void)didSendFinish:(NSString *)threadName;
@end

#define MaxReadSize (1024*256)

@interface UPan_FileBaseSender : NSObject
@property (nonatomic, assign) CGFloat lastPostPersent;
@property (nonatomic, strong) NSThread *mThread;
@property (nonatomic, strong) NSString *threadName;
@property (nonatomic, assign) NSInteger mFileId;

@property (nonatomic, weak) id<picFileSenderDelegate> m_delegate;

//从文件里读取数据
-(NSData *)readFileHandle:(NSFileHandle *)handle offset:(NSInteger)offSet fileSize:(NSInteger)fileSize;

//把数据调整为对端可解格式
-(NSData *)resetForSendData:(NSData *)pSrc fid:(unsigned long long)fid;

//广播发送进度
-(void)postNotification:(CGFloat)persent fileId:(NSInteger)fileId speed:(CGFloat)speed;

//设置线程处理函数
-(void)threadWithName:(NSString *)threadName Start:(SEL)selector target:(id)target obj:(id)obj;

//启动线程
-(void)start;

//关闭线程
-(void)cancel;
@end
