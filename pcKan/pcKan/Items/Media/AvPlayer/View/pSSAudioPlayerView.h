//
//  pSSAudioPlayerView.h
//  pcKan
//
//  Created by admin on 17/4/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "pSSAvPlayerModule.h"

@interface pSSAudioPlayerView : UIView
-(void)playWithMode:(pSSAvMode *)mode;
-(void)releaseView;
@property (nonatomic, copy) void (^b_NextPlay)(void);
@property (nonatomic, copy) void (^b_previousPlay)(void);
@end
