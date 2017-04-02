//
//  EHTcpLinkObj.h
//  picSimpleSend
//
//  Created by admin on 2016/10/14.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pssProtocolType.h"

typedef enum tcpConnectState{
    tcpConnect_ConnectOk,
    tcpConnect_Connecting,
    tcpConnect_ConnectNotOk,
}tcpConnectState;

@protocol NetTcpCallback
@optional
- (void)NetTcpCallback:(NSDictionary *)receData error:(NSError *)error;
- (void)NetStatusChange:(tcpConnectState)state;
- (void)NetRecvFileData:(NSData *)data fileId:(unsigned long long)fileId;
@end

@interface EHTcpLinkObj : NSObject
@property (nonatomic, assign) tcpConnectState connectState;
@property (nonatomic, copy) NSString *ip;
@property (nonatomic, assign) uint16_t port;

-(BOOL)socketConnectWithIp:(NSString *)ip port:(uint16_t)port;
-(void)cutOffConnection;

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;
-(void)sendData:(pssHSMmsg *)pack;
-(void)checkForTimeoutPack;
@end
