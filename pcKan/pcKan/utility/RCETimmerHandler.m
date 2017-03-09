/*### WS@H Project:EHouse ###*/
//
//  RCETimmerHandler.m
//  TestDispatchSource
//
//  Created by jiangjun on 14/11/14.
//  Copyright (c) 2014年 eHouse. All rights reserved.
//

#import "RCETimmerHandler.h"

@interface RCETimmerHandler()
@property(nonatomic, strong) dispatch_source_t timer;
@property(nonatomic, assign) NSTimeInterval timeInterval;       // 定时器间隔
@property(nonatomic, strong) RCETimmerHandleBlock handlerBlock; // 定时处理任务
@property(nonatomic, strong) RCETimmerCancelBlock cancelBlock;  // 取消时处理任务
@end

@implementation RCETimmerHandler

- (instancetype)init{
    return nil;
}

- (instancetype)initWithFrequency: (NSTimeInterval)timeInterval
                    handleBlock: (RCETimmerHandleBlock)handleBlock{
    return [self initWithFrequency: timeInterval handleBlock: handleBlock cancelBlock: nil];
}

- (instancetype)initWithFrequency: (NSTimeInterval)timeInterval
                    handleBlock: (RCETimmerHandleBlock)handleBlock
                    cancelBlock: (RCETimmerCancelBlock)cancelBlock{
    self = [super init];
    if (self) {
        self.isValid = NO;
        self.timeInterval = timeInterval;
        self.handlerBlock = handleBlock;
        self.cancelBlock = cancelBlock;
    }
    return self;
}

- (void)resetTimeInterval: (NSTimeInterval)timeInterval
{
    if (timeInterval > 0 && _timer) {
        
        _timeInterval = timeInterval;
        
        // 开始时间,设置为立刻开始
        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 0*NSEC_PER_SEC);
        // 将定时器设定为多久之后开始，间隔多久，误差为1*NSEC_PER_SEC
        dispatch_source_set_timer(_timer, startTime, timeInterval * NSEC_PER_SEC, 1ull*NSEC_PER_SEC);
    }
}

- (void)start {
    self.isValid = YES;
    if (_timer == nil) {
        
        // 指定定时器源
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        
        // 指定定时器源的处理
        if(_handlerBlock) dispatch_source_set_event_handler(_timer,  _handlerBlock);
        
        // 指定取消定时器源的处理
        if(_cancelBlock) dispatch_source_set_cancel_handler(_timer, _cancelBlock);
        
        [self resetTimeInterval: _timeInterval];
        
        dispatch_resume(_timer);
    }
}

- (void)cancel {
    self.isValid = NO;
    if (_timer != nil) {
        // 取消定时器源
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)dealloc{    
    [self cancel];
}

@end
