//
//  pssUserInfo.m
//  pinut
//
//  Created by admin on 2017/1/22.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssUserInfo.h"

@implementation pssUserInfo
__strong static pssUserInfo *sharedInstance = nil;
+ (instancetype)shareInstance
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

-(void)setUserWithInfo:(NSDictionary *)info
{
    if (info[ptl_uid]) {
        _uid = [info[ptl_uid] intValue];
    }
}
@end
