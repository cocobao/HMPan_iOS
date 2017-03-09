/*### WS@H Project:EHouse ###*/
//
//  RCETimmerHandler.h
//  TestDispatchSource
//
//  Created by jiangjun on 14/11/14.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RCETimmerHandleBlock)(void);
typedef void(^RCETimmerCancelBlock)(void);

@interface RCETimmerHandler : NSObject


- (instancetype)initWithFrequency: (NSTimeInterval)timeInterval
                    handleBlock: (RCETimmerHandleBlock)handlerBlock
                    cancelBlock: (RCETimmerCancelBlock)cancelBlock;
- (void)start;
- (void)cancel;

- (void)resetTimeInterval: (NSTimeInterval)timeInterval;

@property (nonatomic, assign) BOOL isValid;
@end
