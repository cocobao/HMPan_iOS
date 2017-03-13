//
//  pssLinkObj+Api.h
//  pinut
//
//  Created by admin on 2017/1/20.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssLinkObj.h"

@interface pssLinkObj(Api)
-(void)NetApi_loginService:(msgSendBlock)block;
-(void)NetApi_OpenFile:(NSString *)file block:(msgSendBlock)block;
-(void)NetApi_OpenDir:(NSString *)file block:(msgSendBlock)block;
-(void)NetApi_CloseMv;
-(void)NetApi_VideoInfoAckWithMsgId:(int)msgId;
-(void)NetApi_BoardCastIp;
-(void)NetApi_ApplySendFileAck:(NSString *)filePath fileId:(NSInteger)fileId;
-(void)NetApi_ApplyRecvFile:(NSDictionary *)info block:(msgSendBlock)block;
-(void)sendFileData:(NSData *)data;
@end
