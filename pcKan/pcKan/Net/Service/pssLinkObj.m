//
//  pssLinkObj.m
//  pinut
//
//  Created by admin on 2017/1/19.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssLinkObj.h"
#import "pssLinkObj+Api.h"
#import "pssUserInfo.h"
#import "RCETimmerHandler.h"
#import "UPan_FileExchanger.h"

#define PRO_VERSION 1

@interface pssLinkObj()<pssUdpLinkDelegate>
@property (nonatomic, strong) RCETimmerHandler *mTimer;
@end

@implementation pssLinkObj

__strong static id sharedInstance = nil;
+ (id)shareInstance
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _udp_link = [[EHUdpLinkObj alloc] init];
        _tcp_link = [[EHTcpLinkObj alloc] init];
        
        _udp_link.m_delegate = self;
        [_tcp_link addDelegate:self];
        
        WeakSelf(weakSelf);
        _mTimer = [[RCETimmerHandler alloc] initWithFrequency:5 handleBlock:^{
            if (weakSelf.tcpLinkStatus == tcpConnect_ConnectOk) {
                if (!UserInfo.isLogin) {
                    [weakSelf NetLogin];
                }
            }else{
                [weakSelf NetApi_BoardCastIp];
            }
            
            [weakSelf.tcp_link checkForTimeoutPack];
        } cancelBlock:nil];
        [_mTimer start];
    }
    return self;
}

-(void)addTcpDelegate:(id)obj
{
    if (obj == nil) {
        return;
    }
    [_tcp_link addDelegate:obj];
}

-(void)setMvDataDelegate:(id)obj
{
    _udp_link.m_mvDelegate = obj;
}

-(void)removeTcpDelegate:(id)obj
{
    [_tcp_link removeDelegate:obj];
}

-(void)dealloc{
    if (_tcp_link.connectState == tcpConnect_ConnectOk){
        [_tcp_link cutOffConnection];
    }
    
    [_udp_link closeUdpSocket];
}

-(tcpConnectState)tcpLinkStatus
{
    return _tcp_link.connectState;
}

-(void)cutoffTcpConnect
{
    [_tcp_link cutOffConnection];
}

//收到服务端IP广播
-(void)recvBoatcastWithIp:(NSString *)ip port:(NSInteger)port
{
    if (port != ACCEPT_PORT || ip.length == 0) {
        return;
    }
    if (_tcp_link.connectState != tcpConnect_ConnectOk) {
        [_tcp_link socketConnectWithIp:ip port:port];
    }else{
        [_tcp_link cutOffConnection];
        _tcp_link.ip = ip;
        _tcp_link.port = port;
        [_tcp_link socketConnectWithIp:ip port:port];
    }
}

-(void)NetLogin
{
    NSLog(@"send login");
    [self NetApi_loginService:^(NSDictionary *message, NSError *error) {
        if (error) {
            return;
        }
        NSLog(@"login ok");
        [UserInfo setUserWithInfo:message];
        UserInfo.isLogin = YES;
    }];
}

- (void)NetStatusChange:(tcpConnectState)state
{
    if (state != tcpConnect_ConnectOk) {
        UserInfo.isLogin = NO;
        
        NSLog(@"logout");
        NSNotificationCenter *no = [NSNotificationCenter defaultCenter];
        [no postNotificationName:kNotificationLogout object:nil];
    }else{
        [self NetLogin];
    }
}

//打包
-(pssHSMmsg *)packDataType:(NSInteger)type body:(NSDictionary *)body block:(msgSendBlock)block
{
    uint32_t msgId = [pSSCommodMethod getRandomMessageID];
    
    if (!body) {
        body = @{};
    }
    
    NSData *jsonBody = [pSSCommodMethod dictionaryToJsonData:body];
    
    NSMutableData *data = [[NSMutableData alloc] initWithLength:(jsonBody.length + sizeof(stPssProtocolHead))];
    stPssProtocolHead *head = (stPssProtocolHead *)data.bytes;
    head->head[0] = HEADER_0;
    head->head[1] = HEADER_1;
    head->head[2] = HEADER_2;
    head->head[3] = HEADER_3;
    head->version = PRO_VERSION;
    head->msgId = htonl(msgId);
    head->type = type;
    head->uid = [UserInfo uid];
    if (jsonBody.length > 0) {
        head->bodyLength = htonl(jsonBody.length);
        memcpy((void *)(data.bytes + sizeof(stPssProtocolHead)), jsonBody.bytes, jsonBody.length);
    }
    pssHSMmsg *pack = [[pssHSMmsg alloc] initWithData:data msgId:msgId block:block];
    return pack;
}

-(pssHSMmsg *)packDataWithMsgId:(int)msgId Type:(NSInteger)type body:(NSDictionary *)body block:(msgSendBlock)block
{
    if (!body) {
        body = @{};
    }
    
    NSData *jsonBody = [pSSCommodMethod dictionaryToJsonData:body];
    
    NSMutableData *data = [[NSMutableData alloc] initWithLength:(jsonBody.length + sizeof(stPssProtocolHead))];
    stPssProtocolHead *head = (stPssProtocolHead *)data.bytes;
    head->head[0] = HEADER_0;
    head->head[1] = HEADER_1;
    head->head[2] = HEADER_2;
    head->head[3] = HEADER_3;
    head->version = PRO_VERSION;
    head->msgId = htonl(msgId);
    head->type = type;
    head->uid = [UserInfo uid];
    if (jsonBody.length > 0) {
        head->bodyLength = htonl(jsonBody.length);
        memcpy((void *)(data.bytes + sizeof(stPssProtocolHead)), jsonBody.bytes, jsonBody.length);
    }
    pssHSMmsg *pack = [[pssHSMmsg alloc] initWithData:data msgId:msgId block:block];
    return pack;
}

-(pssHSMmsg *)setProtocolHead:(NSData *)data type:(NSInteger)type
{
    stPssProtocolHead *protoHead = (stPssProtocolHead *)data.bytes;
    protoHead->head[0] = HEADER_0;
    protoHead->head[1] = HEADER_1;
    protoHead->head[2] = HEADER_2;
    protoHead->head[3] = HEADER_3;
    protoHead->version = PRO_VERSION;
    protoHead->msgId = 0;
    protoHead->type = type;
    protoHead->uid = [UserInfo uid];
    protoHead->bodyLength = htonl((int)data.length - sizeof(stPssProtocolHead));
    
    pssHSMmsg *pack = [[pssHSMmsg alloc] initWithData:data msgId:0 block:nil];
    return pack;
}
@end
