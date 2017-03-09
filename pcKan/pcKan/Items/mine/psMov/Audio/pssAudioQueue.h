//
//  pssAudioQueue.h
//  pinut
//
//  Created by admin on 2017/2/10.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pssAudioQueue : NSObject
+ (id)shareInstance;
-(void)addAudioData:(NSData *)data;
- (void)SetupAudioFormat:(UInt32) inFormatID;
- (OSStatus)StopQueue;
@end
