//
//  pssProtocolType.h
//  pinut
//
//  Created by admin on 2017/1/19.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ACCEPT_PORT 39890

#define HEADER_0 9
#define HEADER_1 5
#define HEADER_2 2
#define HEADER_3 7

typedef enum {
    emPssCmd_FlashDir,  //更新路径
}emPssCmd;

typedef enum {
    emPssProtocolType_Broadcast, //局域网广播
    emPssProtocolType_Login,    //登录
    emPssProtocolType_PushDir, //推送
    emPssProtocolType_OpenFile, //打开文件
    emPssProtocolType_OpenDir,  //打开目录
    emPssProtocolType_CloseMv,
    emPssProtocolType_VideoInfo,
    emPssProtocolType_ApplySendFile,
    emPssProtocolType_SendFile,
    emPssProtocolType_ApplyRecvFile,
    emPssProtocolType_FilePart,
    emPssProtocolType_RecvFile,
    emPssProtocolType_VideoData,
    emPssProtocolType_AudioData,
    emPssProtocolType_HeartBeat,
}emPssProtocolType;

#pragma pack(1)
typedef struct {
    char head[4];
    char version;
    char type;      //emPssProtocolType
    char extend;
    uint uid;
    int msgId;
    int bodyLength;
}stPssProtocolHead;
#pragma pack()

typedef void (^msgSendBlock)(NSDictionary *message, NSError *error);

@interface pssHSMmsg : NSObject
@property (nonatomic, assign) int msgId;
@property (nonatomic, strong) msgSendBlock sendBlock;
@property (nonatomic, strong) NSData *sendData;
@property (nonatomic, assign) time_t sendTime;

-(instancetype)initWithData:(NSData *)data msgId:(int)msgId block:(msgSendBlock)block;

@end
