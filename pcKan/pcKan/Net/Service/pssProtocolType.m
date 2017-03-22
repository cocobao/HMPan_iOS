//
//  pssProtocolType.m
//  pinut
//
//  Created by admin on 2017/1/19.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssProtocolType.h"

@implementation pssHSMmsg
-(instancetype)initWithData:(NSData *)data msgId:(int)msgId block:(msgSendBlock)block
{
    self = [super init];
    if (self) {
        _sendData = data;
        _msgId = msgId;
        _sendBlock = block;
        _sendTime = time(NULL);
    }
    return self;
}

@end
