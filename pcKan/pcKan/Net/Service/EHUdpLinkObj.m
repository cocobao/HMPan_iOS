//
//  EHUdpLinkObj.m
//  picSimpleSend
//
//  Created by admin on 2016/10/14.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "EHUdpLinkObj.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#import "pssProtocolType.h"

#define BUF_SIZE (1024*1024)

@interface EHUdpLinkObj ()
{
    int mUdpSocket;
    BOOL isRun;
    struct sockaddr_in server;
}
@property (nonatomic, strong) NSThread *mThread;
@end

@implementation EHUdpLinkObj
-(instancetype)init
{
    if (self = [super init]) {
        [self setupUdpSpcket];
    }
    return self;
}

-(void)setupUdpSpcket
{
    mUdpSocket = socket(AF_INET, SOCK_DGRAM, 0);
    
    const int buf_size = BUF_SIZE;
    const int opt = 1;
    setsockopt(mUdpSocket, SOL_SOCKET, SO_RCVBUF, (char *)&buf_size, sizeof(buf_size));
    setsockopt(mUdpSocket, SOL_SOCKET, SO_SNDBUF, (char *)&buf_size, sizeof(buf_size));
    setsockopt(mUdpSocket, SOL_SOCKET, SO_BROADCAST, (char *)&opt, sizeof(opt));
    
    struct sockaddr_in addrto;
    bzero(&addrto, sizeof(struct sockaddr_in));
    addrto.sin_family = AF_INET;
    addrto.sin_addr.s_addr = htonl(INADDR_ANY);
    addrto.sin_port = htons(BIND_UDP_PORT);

    bind(mUdpSocket,(struct sockaddr *)&(addrto), sizeof(struct sockaddr_in));
    
    isRun = YES;
    _mThread = [[NSThread alloc] initWithTarget:self selector:@selector(recvThread) object:nil];
    [_mThread setName:@"udpRecvThread"];
    [_mThread start];
}

-(void)sendData:(NSData *)data toHost:(NSString *)host toPort:(NSInteger)port
{
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = inet_addr([host UTF8String]);
    
    ssize_t ret = sendto(mUdpSocket, data.bytes, data.length, 0, (struct sockaddr *)&addr, sizeof(struct sockaddr));
    if (ret < 0) {
        MITLog(@"send size:%zd, length:%zd, %s", ret, data.length, strerror(errno));
    }
}

-(void)recvThread
{
    struct sockaddr_in from;
    int len = sizeof(struct sockaddr_in);
    ssize_t ret= 0;
    uint8_t *pBuf = (uint8_t *)malloc(BUF_SIZE);
    
    while (isRun) {
        ret = recvfrom(mUdpSocket, pBuf, BUF_SIZE, 0, (struct sockaddr*)&from, (socklen_t*)&len);
        if (ret > 0) {
            [self recvHandler:pBuf size:ret addr:&from];
        }
    }
    free(pBuf);
}

-(void)recvHandler:(uint8_t *)data size:(ssize_t)size addr:(struct sockaddr_in *)addr
{
    if (data == NULL) {
        return;
    }
    
    stPssProtocolHead *head = (stPssProtocolHead *)data;
    if (head->head[0] != HEADER_0 ||
        head->head[1] != HEADER_1 ||
        head->head[2] != HEADER_2 ||
        head->head[3] != HEADER_3 ) {
        return;
    }
    
    int msgLen = ntohl(head->bodyLength);
    if (msgLen < 0 || msgLen > BUF_SIZE) {
        return;
    }
    head->bodyLength = msgLen;
    head->msgId = ntohl(head->msgId);
    
    if (head->type == emPssProtocolType_Broadcast) {
        //收到局域网服务端的ip广播
        [self broadcastData:data+sizeof(stPssProtocolHead)
                       size:(int)size-sizeof(stPssProtocolHead)
                       addr:addr];
    }
    else{
        NSData *frameData = [[NSData alloc] initWithBytes:data+sizeof(stPssProtocolHead)
                                                   length:(int)size-sizeof(stPssProtocolHead)];

        if (head->type == emPssProtocolType_VideoData) {
            if (_m_mvDelegate && [_m_mvDelegate respondsToSelector:@selector(recvVideoData:)]) {
                [_m_mvDelegate recvVideoData:frameData];
            }
        }else if (head->type == emPssProtocolType_AudioData){
            if (_m_mvDelegate && [_m_mvDelegate respondsToSelector:@selector(recvAudioData:)]) {
                [_m_mvDelegate recvAudioData:frameData];
            }
        }
    }
}

-(void)broadcastData:(uint8_t *)data size:(int)size addr:(struct sockaddr_in *)addr
{
    NSData *d = [[NSData alloc] initWithBytes:data length:size];
    NSDictionary *dict = [pSSCommodMethod jsonObjectWithJsonData:d];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        if (dict[@"hello"]) {
            NSInteger c = [dict[@"hello"] integerValue];
            if (c == 200) {
                NSString *ip = [pSSCommodMethod inet_ntoa:addr->sin_addr.s_addr];
                
                if (_m_delegate && [_m_delegate respondsToSelector:@selector(recvBoatcastWithIp:port:)]) {
                    [_m_delegate recvBoatcastWithIp:ip port:ACCEPT_PORT];
                }
            }
        }
    }
}

-(void)closeUdpSocket
{
    isRun = NO;
}

@end
