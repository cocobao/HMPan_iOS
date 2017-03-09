//
//  pSSMovieViewController.h
//  pinut
//
//  Created by admin on 2017/1/7.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSBaseViewController.h"

@interface pSSMovieViewController : pSSBaseViewController
- (instancetype)initWithFilePath:(NSURL *)urlPath;
- (instancetype)initNetPcType;
-(void)setNetPcFps:(NSInteger)fps
          duration:(NSInteger)duration
         mvCodecId:(NSInteger)mvCodecId;
-(void)setNetPcSampleFmt:(NSInteger)sampleFmt
              sampleRate:(NSInteger)sampleRate
                channels:(NSInteger)channels
               avCodecId:(NSInteger)avCodecId;
@end
