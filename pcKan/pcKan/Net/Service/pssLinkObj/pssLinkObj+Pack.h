//
//  pssLinkObj+Pack.h
//  pcKan
//
//  Created by SZ14122141M01 on 2018/5/16.
//  Copyright © 2018年 ybz. All rights reserved.
//

#import "pssLinkObj.h"

@interface pssLinkObj(Pack)
-(pssHSMmsg *)packDataType:(NSInteger)type body:(NSDictionary *)body block:(msgSendBlock)block;
-(pssHSMmsg *)packDataWithMsgId:(int)msgId Type:(NSInteger)type body:(NSDictionary *)body block:(msgSendBlock)block;
-(pssHSMmsg *)setProtocolHead:(NSData *)data type:(NSInteger)type;
@end
