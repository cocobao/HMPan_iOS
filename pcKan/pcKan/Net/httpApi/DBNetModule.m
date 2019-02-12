//
//  DBNetModule.m
//  DBPic
//
//  Created by admin on 16/7/1.
//  Copyright © 2016年 db. All rights reserved.
//

#import "DBNetModule.h"
#import "AFNetworking.h"


@interface DBNetModule ()
@property (nonatomic, strong) Http *mHttp;
@end

@implementation DBNetModule
__strong static id sharedInstance = nil;
+ (id)shareInstance
{
    static dispatch_once_t pred = 0;
    //    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init]; // or some other init method
    });
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone//其实alloc也是调用此方法，只是参数zone为nil而已
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            [sharedInstance initHttp];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return sharedInstance; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;//此处保证不会产生副本
}

- (void)initHttp{
    _mHttp = [[Http alloc] init];
}

- (void)sendData:(NSDictionary*)data uri:(NSString *)uri pathDict:(NSDictionary *)pathDict finish:(callBackFinishBlock)finish
{
    WeakSelf(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableString *url = [NSMutableString stringWithString:NET_COM_ADDR];
        
        if (uri.length > 0) {
            [url appendFormat:@"%@",uri];
        }
        
        if (pathDict != nil) {
            NSArray *allkeys = [pathDict allKeys];
            if (allkeys.count > 0) {
                for (int i = 0; i< allkeys.count; i++) {
                    if (i == 0) {
                        [url appendString:@"?"];
                    }else{
                        [url appendString:@"&"];
                    }
                    [url appendFormat:@"%@=%@",allkeys[i], pathDict[allkeys[i]]];
                }
            }
        }

        [weakSelf.mHttp sendWithData:data Url:url finish:finish];
    });
}

- (void)GETMethod_Addr:(NSString *)addr uri:(NSString *)uri pathDict:(NSDictionary *)pathDict finish:(callBackFinishBlock)finish
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableString *url = [NSMutableString stringWithString:addr];
        
        if (uri.length > 0) {
            [url appendFormat:@"/%@",uri];
        }
        
        if (pathDict != nil) {
            NSArray *allkeys = [pathDict allKeys];
            if (allkeys.count > 0) {
                for (int i = 0; i< allkeys.count; i++) {
                    if (i == 0) {
                        [url appendString:@"?"];
                    }else{
                        [url appendString:@"&"];
                    }
                    [url appendFormat:@"%@=%@",allkeys[i], pathDict[allkeys[i]]];
                }
            }
        }

//        [_mHttp sendWithData:data Url:url finish:finish];
    });
}

@end
