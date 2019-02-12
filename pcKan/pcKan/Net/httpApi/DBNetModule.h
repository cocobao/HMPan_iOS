//
//  DBNetModule.h
//  DBPic
//
//  Created by admin on 16/7/1.
//  Copyright © 2016年 db. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Http.h"

#define NetModule [DBNetModule shareInstance]

#define NET_COM_ADDR @"https://api.1719.com"

@interface DBNetModule : NSObject
+ (id)shareInstance;
- (void)sendData:(NSDictionary*)data uri:(NSString *)uri pathDict:(NSDictionary *)pathDict finish:(callBackFinishBlock)finish;

@end
