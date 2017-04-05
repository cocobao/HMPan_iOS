//
//  pssMediaControlView.h
//  pcKan
//
//  Created by admin on 17/3/27.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IJKMediaPlayback;

@interface pssMediaControlView : UIControl
@property(nonatomic,weak) id<IJKMediaPlayback> delegatePlayer;

@property (nonatomic, strong) UIButton *playerBtn;
@property (nonatomic, strong) UIButton *fullBtn;
@property (nonatomic,strong)  UILabel *currentTimeLabel;
@property (nonatomic,strong)  UILabel *totalDurationLabel;
@property (nonatomic,strong)  UISlider *mediaProgressSlider;

- (void)refreshMediaControl;

- (void)beginDragMediaSlider;

- (void)endDragMediaSlider;

- (void)continueDragMediaSlider;
@end
