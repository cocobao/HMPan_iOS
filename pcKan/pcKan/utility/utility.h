//
//  utility.h
//  pcKan
//
//  Created by SZ14122141M01 on 2018/5/17.
//  Copyright © 2018年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface utility : NSObject
// 获取当前设备可用内存(单位：MB）
+ (double)availableMemory;

// 获取当前任务所占用的内存（单位：MB）
+ (double)usedMemory;
@end
