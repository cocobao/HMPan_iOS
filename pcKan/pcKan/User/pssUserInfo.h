//
//  pssUserInfo.h
//  pinut
//
//  Created by admin on 2017/1/22.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UserInfo [pssUserInfo shareInstance]

@interface pssUserInfo : NSObject
@property (nonatomic, assign) uint uid;

+ (id)shareInstance;
-(void)setUserWithInfo:(NSDictionary *)info;
@end
