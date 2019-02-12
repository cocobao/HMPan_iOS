//
//  pssLinkObj+Api.m
//  pinut
//
//  Created by admin on 2017/1/20.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssLinkObj+Api.h"
#import "pssLinkObj+Pack.h"

@implementation pssLinkObj(Api)
//登陆
-(void)NetApi_loginService:(msgSendBlock)block
{
    pssHSMmsg *pack = [self packDataType:emPssProtocolType_Login body:nil block:block];
    [self.tcp_link sendData:pack];
}

//打开文件
-(void)NetApi_OpenFile:(NSString *)file block:(msgSendBlock)block
{
    NSDictionary *dict = @{ptl_file:file};
    pssHSMmsg *pack = [self packDataType:emPssProtocolType_OpenFile body:dict block:block];
    [self.tcp_link sendData:pack];
}

//打开目录
-(void)NetApi_OpenDir:(NSString *)file block:(msgSendBlock)block
{
    NSDictionary *dict = @{ptl_file:file};
    pssHSMmsg *pack = [self packDataType:emPssProtocolType_OpenDir body:dict block:block];
    [self.tcp_link sendData:pack];
}

//关闭视频
-(void)NetApi_CloseMv
{
    pssHSMmsg *pack = [self packDataType:emPssProtocolType_CloseMv body:nil block:nil];
    [self.tcp_link sendData:pack];
}

//视频信息ack
-(void)NetApi_VideoInfoAckWithMsgId:(int)msgId
{
    NSDictionary *dict = @{ptl_status:@(200)};
    pssHSMmsg *pack = [self packDataWithMsgId:msgId Type:emPssProtocolType_VideoInfo body:dict block:nil];
    [self.tcp_link sendData:pack];
}

//广播
-(void)NetApi_BoardCastIp:(NSString *)hostIP
{
    NSDictionary *dic = @{@"hello":@"mosimosi"};
    NSData *jsonBody = [pSSCommodMethod dictionaryToJsonData:dic];
//    NSLog(@"board cast %@", dic);
    [self.udp_link sendData:jsonBody toHost:hostIP toPort:BROUADCAST_PORT];
}

//请求文件部分
-(void)NetApi_FilePartWithFileId:(NSInteger)fileId pcFilePath:(NSString *)pcFilePath seek:(uint64_t)seek block:(msgSendBlock)block
{
    NSDictionary *dict = @{ptl_filePath:pcFilePath, ptl_fileId:@(fileId), ptl_seek:@(seek)};
    pssHSMmsg *pack = [self packDataType:emPssProtocolType_FilePart body:dict block:block];
    [self.tcp_link sendData:pack];
}

//请求接收文件ack
-(void)NetApi_ApplySendFileAck:(NSString *)filePath fileId:(NSInteger)fileId
{
    NSDictionary *dict = @{ptl_status:@(200), ptl_filePath:filePath, ptl_fileId:@(fileId)};
    pssHSMmsg *pack = [self packDataType:emPssProtocolType_ApplySendFile body:dict block:nil];
    [self.tcp_link sendData:pack];
}

//发送文件数据
-(void)sendFileData:(NSData *)data
{
    pssHSMmsg *pack = [self setProtocolHead:data type:emPssProtocolType_RecvFile];
    [self.tcp_link sendData:pack];
}

//请求接收文件
-(void)NetApi_ApplyRecvFile:(NSDictionary *)info block:(msgSendBlock)block
{
    pssHSMmsg *pack = [self packDataType:emPssProtocolType_ApplyRecvFile body:info block:block];
    [self.tcp_link sendData:pack];
}

//心跳
-(void)NetApit_HeartBeat
{
    pssHSMmsg *pack = [self packDataType:emPssProtocolType_HeartBeat body:nil block:nil];
    [self.tcp_link sendData:pack];
}
@end
