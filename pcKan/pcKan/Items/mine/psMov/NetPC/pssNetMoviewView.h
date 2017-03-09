//
//  pssNetMoviewView.h
//  pinut
//
//  Created by admin on 2017/2/6.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface pssNetMoviewView : UIView
-(void)setFps:(NSInteger)fps
     duration:(NSInteger)duration
    mvCodecId:(NSInteger)mvCodecId;
-(void)setAudioInfo:(NSInteger)avCodecId
          sampleFmt:(NSInteger)sampleFmt
         sampleRate:(NSInteger)sampleRate
           channels:(NSInteger)channels;
-(void)cancelMv;
@end
