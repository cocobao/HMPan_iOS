//
//  Http.m
//  BloogGm
//
//  Created by admin on 16/5/27.
//  Copyright © 2016年 test. All rights reserved.
//

#import "Http.h"
#import "AFURLRequestSerialization.h"
#import "AFHTTPRequestOperation.h"
#import "AFNetworking.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface Http ()

@property(nonatomic,strong)AFHTTPRequestOperationManager *manager; //AF请求对象

@end

@implementation Http

- (instancetype)init
{
    self = [super init];
    //应用配置文件
    self.manager = [AFHTTPRequestOperationManager manager];
    
    //申明返回的结果是JSON类型
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //如果报接受类型不一致请替换一致text/html
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/json",@"text/xml", @"application/octet-stream",@"text/plain",@"application/json",nil];
    //清求时间设置
    self.manager.requestSerializer.timeoutInterval = 5;
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];

    securityPolicy.allowInvalidCertificates = YES;
    [AFHTTPRequestOperationManager manager].securityPolicy = securityPolicy;

    return self;
}


-(AFHTTPRequestOperation*)sendWithData:(NSDictionary*)data Url:(NSString *)Url finish:(callBackFinishBlock)finish
{
    if (Url == nil || Url.length == 0) return nil;
    
    
    NSString *jsonString = nil;
    NSData *jsonData = nil;
    if (data != nil) {
        jsonData = [pSSCommodMethod dictionaryToJsonData:data];
        jsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSString *targetURL = [NSString stringWithFormat: @"%@?lang=%@",Url, @"zh-cn"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:targetURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/json" forHTTPHeaderField:@"Content-Type"];
    
    if (jsonData != nil) {
        [request setHTTPBody:jsonData];
    }
    
     AFHTTPRequestOperation *operation = [self.manager
     HTTPRequestOperationWithRequest:request
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSMutableDictionary *dict = [NSMutableDictionary dictionary];

         if (responseObject != nil && [responseObject isKindOfClass:[NSDictionary class]]) {
             [dict setValuesForKeysWithDictionary:responseObject];
         }else{
              NSLog(@"http response: error %@",resultCode);
             [dict setObject:@(-1) forKey:@"status"];
         }
         if (finish) finish(dict, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (finish) finish(nil, error);
     }];
    [self.manager.operationQueue addOperation:operation];
    return operation;
}

-(AFHTTPRequestOperation*)GET_Url:(NSString *)Url finish:(callBackFinishBlock)finish
{
    if (Url.length == 0) return nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:Url]];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"text/json" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [self.manager
                                         HTTPRequestOperationWithRequest:request
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                             
                                             if (responseObject != nil && [responseObject isKindOfClass:[NSDictionary class]]) {
                                                 [dict setValuesForKeysWithDictionary:responseObject];
                                             }else{
                                                 NSLog(@"http response: error %@",resultCode);
                                                 [dict setObject:@(-1) forKey:@"status"];
                                             }
                                             if (finish) finish(dict, nil);
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             if (finish) finish(nil, error);
                                         }];
    [self.manager.operationQueue addOperation:operation];
    return operation;
}



@end
