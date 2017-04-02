//
//  pssMediaControlView.m
//  pcKan
//
//  Created by admin on 17/3/27.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssMediaControlView.h"
#import <IJKMediaFramework/IJKMediaFramework.h>

@implementation pssMediaControlView
{
    BOOL _isMediaSliderBeingDragged;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = Color_black(20);
    
    self.playerBtn.frame = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height);
    self.currentTimeLabel.frame = CGRectMake(CGRectGetMaxX(_playerBtn.frame), 0, 50, self.bounds.size.height);
    self.totalDurationLabel.frame = CGRectMake(self.bounds.size.width-60, 0, 50, self.bounds.size.height);
    self.mediaProgressSlider.frame = CGRectMake(CGRectGetMaxX(_currentTimeLabel.frame), 0, CGRectGetMinX(_totalDurationLabel.frame)-CGRectGetMaxX(_currentTimeLabel.frame)-10, self.bounds.size.height);
}

- (void)beginDragMediaSlider
{
    _isMediaSliderBeingDragged = YES;
}

- (void)endDragMediaSlider
{
    _isMediaSliderBeingDragged = NO;
}

- (void)continueDragMediaSlider
{
    [self refreshMediaControl];
}

- (void)refreshMediaControl
{
    // duration
    NSTimeInterval duration = self.delegatePlayer.duration;
    NSInteger intDuration = duration + 0.5;
    
    // position
    NSTimeInterval position;
    if (_isMediaSliderBeingDragged) {
        position = self.mediaProgressSlider.value;
    } else {
        position = self.delegatePlayer.currentPlaybackTime;
    }
    NSInteger intPosition = position + 0.5;
    NSInteger less = intDuration - intPosition;
    
    if (less >= 0) {
        self.mediaProgressSlider.maximumValue = duration;
        self.totalDurationLabel.text = [NSString stringWithFormat:@"-%02d:%02d", (int)(less / 60), (int)(less % 60)];
    } else {
        self.totalDurationLabel.text = @"00:00";
        self.mediaProgressSlider.maximumValue = 1.0f;
    }
    
    if (intDuration > 0) {
        self.mediaProgressSlider.value = position;
    } else {
        self.mediaProgressSlider.value = 0.0f;
    }
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intPosition / 60), (int)(intPosition % 60)];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshMediaControl) object:nil];
    [self performSelector:@selector(refreshMediaControl) withObject:nil afterDelay:0.5];
}

-(UILabel *)totalDurationLabel
{
    if (!_totalDurationLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = kFont(15);
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _totalDurationLabel = label;
    }
    return _totalDurationLabel;
}

-(UILabel *)currentTimeLabel
{
    if (!_currentTimeLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = kFont(15);
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _currentTimeLabel = label;
    }
    return _currentTimeLabel;
}

-(UIButton *)playerBtn
{
    if (!_playerBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"gui_play"] forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:@"gui_pause"] forState:UIControlStateNormal];
        [self addSubview:btn];
        _playerBtn = btn;
    }
    return _playerBtn;
}

-(UISlider *)mediaProgressSlider
{
    if (!_mediaProgressSlider) {
        UISlider *view = [[UISlider alloc] init];
        view.minimumValue = 0;
        view.continuous = YES;
        [self addSubview:view];
        _mediaProgressSlider = view;
    }
    return _mediaProgressSlider;
}
@end
