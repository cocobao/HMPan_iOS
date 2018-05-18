//
//  pssLinkObj+Pack.m
//  pcKan
//
//  Created by SZ14122141M01 on 2018/5/16.
//  Copyright © 2018年 ybz. All rights reserved.
//

#import "pssLinkObj+Pack.h"
#import "pssNetCom.h"
#define PRO_VERSION 1

@implementation pssLinkObj(Pack)
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
