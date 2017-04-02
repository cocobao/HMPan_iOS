//
//  pssLinkObj.h
//  pinut
//
//  Created by admin on 2017/1/19.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EHUdpLinkObj.h"
#import "EHTcpLinkObj.h"

#define pssLink [pssLinkObj shareInstance]

@interface pssLinkObj : NSObject
@property (nonatomic, strong, readwrite) EHUdpLinkObj *udp_link;
@property (nonatomic, strong, readwrite) EHTcpLinkObj *tcp_link;

+ (id)shareInstance;
-(tcpConnectState)tcpLinkStatus;
-(void)addTcpDelegate:(id)obj;
-(void)setMvDataDelegate:(id)obj;
-(void)removeTcpDelegate:(id)obj;
-(void)cutoffTcpConnect;
-(pssHSMmsg *)packDataType:(NSInteger)type body:(NSDictionary *)body block:(msgSendBlock)block;
-(pssHSMmsg *)packDataWithMsgId:(int)msgId Type:(NSInteger)type body:(NSDictionary *)body block:(msgSendBlock)block;
-(pssHSMmsg *)setProtocolHead:(NSData *)data type:(NSInteger)type;
@end
