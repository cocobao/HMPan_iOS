//
//  pssNetCom.m
//  pcKan
//
//  Created by ws on 2017/4/8.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssNetCom.h"
#import "AFNetworking.h"

@implementation pssNetCom
/*
 -1:获取不到网络
 0:未知网络
 2:2G 3:3G 4:4G 5:5G.....10000:10000G
 20:WiFi
 */
+(int)getCurrentNetTypeForInt
{
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        return -1;
    }
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    AFNetworkReachabilityStatus status = manager.networkReachabilityStatus;
    switch (status) {
        case AFNetworkReachabilityStatusReachableViaWWAN:return 2;
        case AFNetworkReachabilityStatusReachableViaWiFi:return 20;
        case AFNetwork_CTRadioAccessTechnology2G:return 2;
        case AFNetwork_CTRadioAccessTechnology3G:return 3;
        case AFNetwork_CTRadioAccessTechnology4G:return 4;
            
        case AFNetworkReachabilityStatusUnknown :
        case AFNetworkReachabilityStatusNotReachable:
        default:
            return 0;
    }
    return status;
}

@end
