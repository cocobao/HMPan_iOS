//
//  EHTcpLinkObj.m
//  picSimpleSend
//
//  Created by admin on 2016/10/14.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "EHTcpLinkObj.h"
#import "GCDAsyncSocket.h"
#import "GCDMulticastDelegate.h"

#define MAX_BUF_SIZE (1024*1024*10)

@interface EHTcpLinkObj ()<GCDAsyncSocketDelegate>
{
    unsigned char *recvDataBuf;
    uint8_t *pRecvBuf;
}
@property (nonatomic, strong) dispatch_queue_t mSocketQueue;
@property (nonatomic, strong) dispatch_queue_t mRecvHandleQueue;
@property (nonatomic, strong) GCDAsyncSocket *mGcdTcpSocket;
@property (nonatomic, strong) NSMutableData *mRecvDataBuf;
@property (nonatomic, assign) void *RecvQueueTag;
@property (nonatomic, strong) GCDMulticastDelegate <NetTcpCallback> *multicastDelegate;
@property (nonatomic, strong) NSMutableArray *mMessageQueue;
@end

@implementation EHTcpLinkObj
-(instancetype)init
{
    self = [super init];
    if (self) {
        recvDataBuf = (unsigned char *)malloc(MAX_BUF_SIZE);
        pRecvBuf = recvDataBuf;
        
        _mSocketQueue = dispatch_queue_create("mSocketQueue", nil);
        _mRecvHandleQueue = dispatch_queue_create("_mRecvHandleQueue", nil);
        dispatch_queue_set_specific(_mRecvHandleQueue, _RecvQueueTag, _RecvQueueTag, NULL);
        _mRecvDataBuf = [[NSMutableData alloc] initWithCapacity:1024];
        _mMessageQueue = [NSMutableArray arrayWithCapacity:10];
        _mGcdTcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                    delegateQueue:_mRecvHandleQueue
                                                      socketQueue:_mSocketQueue];
        [_mGcdTcpSocket setIPv6Enabled:YES];
        [_mGcdTcpSocket setPreferIPv4OverIPv6:NO];
        [_mGcdTcpSocket setAutoDisconnectOnClosedReadStream:YES];
        
        _multicastDelegate = (GCDMulticastDelegate <NetTcpCallback> *)[[GCDMulticastDelegate alloc] init];
        
        [self setConnectState:tcpConnect_ConnectNotOk];
    }
    return self;
}

// socket连接
-(BOOL)socketConnectWithIp:(NSString *)ip port:(uint16_t)port
{
    [self setConnectState:tcpConnect_Connecting];
    NSError *error;
    [_mGcdTcpSocket connectToHost:ip onPort:port withTimeout:10 error:&error];
    if (error) {
        _connectState = tcpConnect_ConnectNotOk;
        NSLog(@"connect fail, error%@", error);
        return NO;
    }
    
    return YES;
}

//主动切断连接
-(void)cutOffConnection
{
    NSLog(@"cut off by mySelf");
    if (_connectState == tcpConnect_ConnectOk) {
        [_mGcdTcpSocket disconnect];
    }
}

-(void)setConnectState:(tcpConnectState)connectState
{
    _connectState = connectState;
    [_multicastDelegate NetStatusChange:_connectState];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    _ip = host;
    _port = port;
    [self setConnectState:tcpConnect_ConnectOk];
    NSLog(@"connect to host:%@ ok", host);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"did disconnect");
    for (pssHSMmsg *msg in _mMessageQueue) {
        NSError *error = [NSError errorWithDomain:@"网络错误" code:404 userInfo:nil];
        msg.sendBlock(nil, error);
    }
    [_mMessageQueue removeAllObjects];
    [self setConnectState:tcpConnect_ConnectNotOk];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    memcpy(pRecvBuf, data.bytes, data.length);
    pRecvBuf += data.length;
//    NSLog(@"recv data size:%zd", data.length);

    [self didReadData];
    [_mGcdTcpSocket readDataWithTimeout:-1 tag:0];
}

-(void)sendData:(pssHSMmsg *)pack
{
    WeakSelf(weakSelf);
    dispatch_async(_mSocketQueue, ^{
        [weakSelf.mGcdTcpSocket writeData:pack.sendData withTimeout:10 tag:0];
        [weakSelf.mGcdTcpSocket readDataWithTimeout:-1 tag:0];
    });
    if (pack.sendBlock) {
        [_mMessageQueue addObject:pack];
    }
}

-(void)didReadData
{
    for(;;) {
        NSInteger lastDataSize = pRecvBuf - recvDataBuf;
        if (lastDataSize < sizeof(stPssProtocolHead)) {
            return;
        }
        
        stPssProtocolHead *head = (stPssProtocolHead *)recvDataBuf;
        if (head->head[0] != HEADER_0 ||
            head->head[1] != HEADER_1 ||
            head->head[2] != HEADER_2 ||
            head->head[3] != HEADER_3 ) {
            //脏数据
            pRecvBuf = recvDataBuf;
            return;
        }
        
        int msgLen = ntohl(head->bodyLength);
        if (msgLen < 0 || msgLen > MAX_BUF_SIZE) {
            //脏数据
            pRecvBuf = recvDataBuf;
            return;
        }
        
        int packLen = msgLen + sizeof(stPssProtocolHead);
        if (lastDataSize < packLen) {
            //数据包不完整
            return;
        }

        NSData *pack = pack = [[NSData alloc] initWithBytes:recvDataBuf length:packLen];;
        NSInteger lastLen = lastDataSize-packLen;
        if (lastLen > 0) {
            memmove(recvDataBuf, recvDataBuf+packLen, lastLen);
            pRecvBuf = recvDataBuf+lastLen;
        }else{
            pRecvBuf = recvDataBuf;
        }
        
        head = (stPssProtocolHead *)pack.bytes;
        head->bodyLength = msgLen;
        head->msgId = ntohl(head->msgId);
        if (head->version == 0x1) {
            WeakSelf(weakSelf);
            dispatch_async(_mSocketQueue, ^{
                [weakSelf packHandlerVer1:pack];
            });
        }
    }
}

-(void)packHandlerVer1:(NSData *)data
{
    stPssProtocolHead *head = (stPssProtocolHead *)data.bytes;
    char *body = (char *)data.bytes + sizeof(stPssProtocolHead);
    
    //文件数据
    if (head->type == emPssProtocolType_SendFile) {
        int sizeSpace = sizeof(unsigned long long);
        NSData *fileData = [NSData dataWithBytes:body+sizeSpace length:(data.length - sizeof(stPssProtocolHead)-sizeSpace)];
        unsigned long long fileId = 0;
        memcpy(&fileId, body, sizeSpace);
        [_multicastDelegate NetRecvFileData:fileData fileId:fileId];
        return;
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@(head->type) forKey:PSS_CMD_TYPE];
    [dict setValue:@(head->msgId) forKey:ptl_msgId];
    
    NSLog(@"recv cmd type:%zd", head->type);
    
    if (head->bodyLength > 0) {
        NSData *jsonData = [[NSData alloc] initWithBytes:body length:head->bodyLength];
        [dict addEntriesFromDictionary:[pSSCommodMethod jsonObjectWithJsonData:jsonData]];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.msgId == %d)", head->msgId];
    NSArray *tmpArr = [_mMessageQueue filteredArrayUsingPredicate:predicate];
    if (tmpArr.count > 0) {
        pssHSMmsg *msgSave = nil;
        msgSave = [tmpArr firstObject];
        @synchronized (_mMessageQueue) {
            [_mMessageQueue removeObject:msgSave];
        }
        if (msgSave.sendBlock) {
            msgSave.sendBlock(dict, nil);
        }
    }else{
        [_multicastDelegate NetTcpCallback:dict error:nil];
    }
}

-(void)checkForTimeoutPack
{
    if (_mMessageQueue.count == 0) {
        return;
    }
    
    time_t nowTimeInternal = time(NULL);
    NSArray *arrCopySource = [NSArray arrayWithArray:_mMessageQueue];
    for (pssHSMmsg *pack in arrCopySource) {
        if (nowTimeInternal - pack.sendTime > 5) {
            [_mMessageQueue removeObject:pack];
            
            if (pack.sendBlock) {
                pack.sendBlock(nil, [NSError errorWithDomain:@"网络超时" code:-1 userInfo:nil]);
            }
        }
    }
}

#pragma mark - GCDMulticastDelegate
- (void)addDelegate:(id)delegate
{
    dispatch_block_t block = ^{
        [_multicastDelegate addDelegate:delegate delegateQueue:_mRecvHandleQueue];
    };
    
    if (dispatch_get_specific(_RecvQueueTag))
        block();
    else
        dispatch_async(_mRecvHandleQueue, block);
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    dispatch_block_t block = ^{
        [_multicastDelegate removeDelegate:delegate delegateQueue:delegateQueue];
    };
    
    if (dispatch_get_specific(_RecvQueueTag))
        block();
    else
        dispatch_sync(_mRecvHandleQueue, block);
}

- (void)removeDelegate:(id)delegate
{
    dispatch_block_t block = ^{
        [_multicastDelegate removeDelegate:delegate];
    };
    
    if (dispatch_get_specific(_RecvQueueTag))
        block();
    else
        dispatch_sync(_mRecvHandleQueue, block);
}

@end
