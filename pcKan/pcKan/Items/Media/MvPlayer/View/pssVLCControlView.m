//
//  pssVLCControlView.m
//  pcKan
//
//  Created by bz y on 2019/5/12.
//  Copyright © 2019 ybz. All rights reserved.
//

#import "pssVLCControlView.h"

@interface pssVLCControlView()

@end

@implementation pssVLCControlView

-(void)drawRect:(CGRect)rect
{
    [super layoutSubviews];
    self.backgroundColor = Color_Line;
    self.playBtn.frame = CGRectMake(0, 0, 28, 32);
    self.fullScreen.frame = CGRectMake(self.frame.size.width-28, 0, 25, 25);
    self.playBtn.center = CGPointMake(self.playBtn.center.x, rect.size.height/2);
    self.fullScreen.center = CGPointMake(self.fullScreen.center.x, rect.size.height/2);
}

-(void)setIsPlay:(BOOL)isPlay
{
    _isPlay = isPlay;
    if (isPlay) {
        [self.playBtn setImage:[UIImage imageNamed:@"vlc_puse"] forState:UIControlStateNormal];
    }else{
        [self.playBtn setImage:[UIImage imageNamed:@"vlc_play"] forState:UIControlStateNormal];
    }
}

-(void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    if (isFullScreen) {
        [self.fullScreen setImage:[UIImage imageNamed:@"vlc_full_screen"] forState:UIControlStateNormal];
    }else{
        [self.fullScreen setImage:[UIImage imageNamed:@"vlc_full_screen"] forState:UIControlStateNormal];
    }
}

-(UIButton *)playBtn
{
    if (!_playBtn) {
        UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:view];
        _playBtn = view;
    }
    return _playBtn;
}

-(UIButton *)fullScreen
{
    if (!_fullScreen) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn];
        _fullScreen = btn;
    }
    return _fullScreen;
}
@end
