//
//  pSSNetDecoder.h
//  pinut
//
//  Created by admin on 2017/2/5.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pssMvFrame.h"

@interface pSSNetDecoder : NSObject
-(KxVideoFrame *)decoderFrame:(NSData *)frameData;
-(KxAudioFrame *)decoderAudio:(NSData *)frameData;
-(void)initVideoDecoderWithId:(NSInteger)codecId;
-(void)initAudioDecoderWithId:(NSInteger)codecId
                    sampleFmt:(NSInteger)sampleFmt
                   sampleRate:(NSInteger)sampleRate
                     channels:(NSInteger)channels;
@end
