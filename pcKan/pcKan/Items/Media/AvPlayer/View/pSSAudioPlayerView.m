//
//  pSSAudioPlayerView.m
//  pcKan
//
//  Created by admin on 17/4/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSAudioPlayerView.h"

@interface pSSAudioPlayerView ()
//标题
@property (nonatomic, strong) UILabel *mTitleLabel;
//进度条
@property (nonatomic, strong) UIProgressView *playPrograss;
//进度控制
@property (nonatomic, strong) UISlider *playControlPrograss;
//album
@property (nonatomic, strong) UILabel *mAlbumLabel;
//播放按钮
@property (nonatomic, strong) UIButton *playBtn;
//下一首
@property (nonatomic, strong) UIButton *nextPlay;
//
@property (nonatomic, strong) UIButton *previousPlay;
//进度更新定时器
@property (nonatomic, strong) NSTimer *mTimer;
//当前播放时间显示
@property (nonatomic, strong) UILabel *mCurrentTimeLabel;
//总时间显示
@property (nonatomic, strong) UILabel *mDurationLabel;
@end

@implementation pSSAudioPlayerView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = Color_Line.CGColor;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,-2);
        self.layer.shadowOpacity = 0.1;
        self.layer.shadowRadius = 4;
        [self initViews];
    }
    return self;
}

-(void)releaseView
{
    if (![PSS_AVPLAYER isPlaying]){
        [PSS_AVPLAYER stop];
    }
    
    if (_mTimer) {
        [_mTimer invalidate];
        _mTimer = nil;
    }
}

-(void)initViews
{
    CGFloat MaxWidth = self.bounds.size.width;
    CGFloat MaxHeight = self.frame.size.height;
    
    CGFloat minX = 0;
    CGFloat minY = 0;
    CGFloat width = MaxWidth-40;
    CGFloat height = 30;
    self.playPrograss.frame = CGRectMake(0, 0, width, height);
    self.playPrograss.center = CGPointMake(MaxWidth/2, MaxHeight/2);
//    self.playControlPrograss.frame = self.playPrograss.frame;
    
    minX = 10;
    minY = 10;
    width = MaxWidth-20;
    height = 25;
    self.mTitleLabel.frame = CGRectMake(minX, minY, width, height);
    
    minX = 10;
    minY = CGRectGetMaxY(_mTitleLabel.frame);
    width = CGRectGetWidth(_mTitleLabel.frame);
    height = 20;
    self.mAlbumLabel.frame = CGRectMake(minX, minY, width, height);
    
    width = 40;
    height = width;
    minX = 0;
    minY = MaxHeight-height-10;
    self.playBtn.frame = CGRectMake(minX, minY, width, height);
    self.playBtn.center = CGPointMake(MaxWidth/2, _playBtn.center.y);
    
    minX = CGRectGetMinX(_playPrograss.frame);
    minY = CGRectGetMaxY(_playPrograss.frame);
    width = 100;
    height = 25;
    self.mCurrentTimeLabel.frame = CGRectMake(minX, minY, width, height);
    
    width = 100;
    height = 25;
    minX = CGRectGetMaxX(_playPrograss.frame)-width;
    minY = CGRectGetMaxY(_playPrograss.frame);
    self.mDurationLabel.frame = CGRectMake(minX, minY, width, height);
    
    width = 40;
    height = 40;
    minX = CGRectGetMinX(_playBtn.frame) - width - 30;
    minY = CGRectGetMinY(_playBtn.frame);
    self.previousPlay.frame = CGRectMake(minX, minY, width, height);
    
    minX = CGRectGetMaxX(_playBtn.frame) + 30;
    self.nextPlay.frame = CGRectMake(minX, minY, width, height);
}

-(void)playWithMode:(pSSAvMode *)mode
{
    [self setPlayBtnState];
    
    NSMutableString *str = [NSMutableString stringWithString:mode.mTitle];
    if (mode.mArtwork.length > 0) {
        [str appendFormat:@" - %@", mode.mArtwork];
    }
    self.mTitleLabel.text = str;
    self.mAlbumLabel.text = mode.mAlbum;
    
//    self.playControlPrograss.maximumValue = PSS_AVPLAYER.duration;
    self.mTimer.fireDate = [NSDate distantPast];
}

//设置播放按钮样式
-(void)setPlayBtnState
{
    if ([PSS_AVPLAYER isPlaying]){
        [self.playBtn setImage:[UIImage imageNamed:@"gui_pause_black"] forState:UIControlStateNormal];
    }else{
        [self.playBtn setImage:[UIImage imageNamed:@"gui_play_black"] forState:UIControlStateNormal];
    }
}

//更新播放进度
-(void)updateProgress{
    NSTimeInterval current = [PSS_AVPLAYER currentTime];
    NSTimeInterval duration = [PSS_AVPLAYER duration];
    float progress= current/duration;
    if (progress > 0) {
        [self.playPrograss setProgress:progress animated:YES];
    }else{
        [self.playPrograss setProgress:progress animated:NO];
    }
    
    self.mCurrentTimeLabel.text = [NSString stringWithFormat:@"%.2d:%.2d", (int)current / 60 , (int)current % 60];
    self.mDurationLabel.text = [NSString stringWithFormat:@"%.2d:%.2d", (int)duration/60, (int)duration % 60];
}

//播放暂停
-(void)playOrStop:(UIButton *)sender
{
    if ([PSS_AVPLAYER isPlaying]){
        [PSS_AVPLAYER pause];
        self.mTimer.fireDate = [NSDate distantFuture];
    }else{
        [PSS_AVPLAYER play];
        self.mTimer.fireDate = [NSDate distantPast];
    }
    [self setPlayBtnState];
}

//下一首
-(void)nextPlayAction:(UIButton *)sender
{
    if (_b_NextPlay) {
        _b_NextPlay();
    }
}

//上一首
-(void)previousAction:(UIButton *)sender
{
    if (_b_previousPlay) {
        _b_previousPlay();
    }
}

-(NSTimer *)mTimer{
    if (!_mTimer) {
        _mTimer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress) userInfo:nil repeats:true];
    }
    return _mTimer;
}

-(UISlider *)playControlPrograss
{
    if (!_playControlPrograss) {
        UISlider *view = [[UISlider alloc] init];
        view.minimumValue = 0;
        view.continuous = YES;
        [self addSubview:view];
        _playControlPrograss = view;
    }
    return _playControlPrograss;
}

-(UILabel *)mCurrentTimeLabel
{
    if (!_mCurrentTimeLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = kFont(15);
        label.textColor = Color_5a5a5a;
        label.textAlignment = NSTextAlignmentLeft;
        [self addSubview:label];
        _mCurrentTimeLabel = label;
    }
    return _mCurrentTimeLabel;
}

-(UILabel *)mDurationLabel
{
    if (!_mDurationLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = kFont(15);
        label.textColor = Color_5a5a5a;
        label.textAlignment = NSTextAlignmentRight;
        [self addSubview:label];
        _mDurationLabel = label;
    }
    return _mDurationLabel;
}

-(UILabel *)mAlbumLabel
{
    if (!_mAlbumLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = kFont(12);
        label.textColor = Color_828282;
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _mAlbumLabel = label;
    }
    return _mAlbumLabel;
}

-(UIProgressView *)playPrograss
{
    if (!_playPrograss) {
        UIProgressView *view = [[UIProgressView alloc] initWithProgressViewStyle: UIProgressViewStyleDefault];
        [self addSubview:view];
        _playPrograss = view;
    }
    return _playPrograss;
}

-(UILabel *)mTitleLabel
{
    if (!_mTitleLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = kFont(15);
        label.textColor = Color_5a5a5a;
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _mTitleLabel = label;
    }
    return _mTitleLabel;
}

-(UIButton *)playBtn
{
    if (!_playBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(playOrStop:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        _playBtn = btn;
    }
    return _playBtn;
}

-(UIButton *)nextPlay
{
    if (!_nextPlay) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"next_play"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(nextPlayAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        _nextPlay = btn;
    }
    return _nextPlay;
}

-(UIButton *)previousPlay
{
    if (!_previousPlay) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"previous_play"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(previousAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        _previousPlay = btn;
    }
    return _previousPlay;
}
@end
