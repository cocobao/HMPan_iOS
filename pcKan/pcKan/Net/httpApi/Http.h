//
//  Http.h
//  BloogGm
//
//  Created by admin on 16/5/27.
//  Copyright © 2016年 test. All rights reserved.
//

#import <Foundation/Foundation.h>

#define resultCode @"resultCode"

@class AFHTTPRequestOperation;

@interface Http : NSObject
-(AFHTTPRequestOperation*)sendWithData:(NSDictionary*)data Url:(NSString *)Url finish:(callBackFinishBlock)finish;

@end

