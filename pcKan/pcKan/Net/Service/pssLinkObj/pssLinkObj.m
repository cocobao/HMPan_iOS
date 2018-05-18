//
//  pssLinkObj.m
//  pinut
//
//  Created by admin on 2017/1/19.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssLinkObj.h"
#import "pssLinkObj+Api.h"
#import "pssLinkObj+Pack.h"
#import "pssUserInfo.h"
#import "RCETimmerHandler.h"
#import "UPan_FileExchanger.h"
#import "pssNetCom.h"



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
        
        //启动5秒钟定时器
        _mTimer = [[RCETimmerHandler alloc] initWithFrequency:5 handleBlock:^{
//            if (weakSelf.tcpLinkStatus == tcpConnect_ConnectOk) {
//                if (!UserInfo.isLogin) {
//                    //局域网登录电脑端
//                    [weakSelf.tcp_link clearDataBuf];
//                    [weakSelf NetLogin];
//                }
//            }else{
                //获取当前网络类型
//                NSInteger netType = [pssNetCom getCurrentNetTypeForInt];
//                if (netType == 20 || netType == 0) {
//                    [weakSelf NetApi_BoardCastIp];
//                    [_tcp_link socketConnectWithIp:@"192.168.0.101" port:39890];
//                }
//            }
            
            //检测网络超时包
            [weakSelf.tcp_link checkForTimeoutPack];
            
            [weakSelf NetApit_HeartBeat];
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
    MITLog(@"send login");
    [self NetApi_loginService:^(NSDictionary *message, NSError *error) {
        if (error) {
            return;
        }
        MITLog(@"login ok");
        [UserInfo setUserWithInfo:message];
        UserInfo.isLogin = YES;
    }];
}

- (void)NetStatusChange:(tcpConnectState)state
{
    if (state != tcpConnect_ConnectOk) {
        UserInfo.isLogin = NO;
        
        MITLog(@"logout");
        NSNotificationCenter *no = [NSNotificationCenter defaultCenter];
        [no postNotificationName:kNotificationLogout object:nil];
    }else{
        [self NetLogin];
    }
}


@end
