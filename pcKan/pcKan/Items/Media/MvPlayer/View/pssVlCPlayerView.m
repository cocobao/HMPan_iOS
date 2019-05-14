//
//  pssVlCPlayerView.m
//  pcKan
//
//  Created by bz y on 2019/5/13.
//  Copyright © 2019 ybz. All rights reserved.
//

#import "pssVlCPlayerView.h"
#import "MRVLCPlayer.h"
#import "pssVLCControlView.h"

@interface pssVlCPlayerView()<VLCMediaPlayerDelegate,MRVideoControlViewDelegate>
@property (strong, nonatomic) VLCMediaPlayer *player;
@property (strong, nonatomic) pssVLCControlView *ctrlView;
@property (assign, nonatomic) CGRect _sframe;
@end

@implementation pssVlCPlayerView

-(instancetype)initWithFrame:(CGRect)frame
{
    __sframe = frame;
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.ctrlView.frame = CGRectMake(0, frame.size.height-40, kScreenWidth, 40);
        [self.ctrlView setIsPlay:YES];
        [self.ctrlView setIsFullScreen:NO];
        [self.ctrlView.playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.ctrlView.fullScreen addTarget:self action:@selector(fullScreenClick:) forControlEvents:UIControlEventTouchUpInside];
    
        _player = [[VLCMediaPlayer alloc] init];
        _player.delegate = self;
        [_player setDrawable:self];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleTap];
    }
    return self;
}

-(void)handleSingleTap:(UIGestureRecognizer *)gest
{
    self.ctrlView.hidden = !self.ctrlView.hidden;
}

-(pssVLCControlView *)ctrlView
{
    if (!_ctrlView) {
        _ctrlView = [[pssVLCControlView alloc] init];
        _ctrlView.hidden = YES;
        [self addSubview:_ctrlView];
    }
    return _ctrlView;
}

-(void)play:(NSString *)filePath
{
    _player.media = [[VLCMedia alloc] initWithURL:[NSURL fileURLWithPath:filePath]];
    [_player play];
}

-(void)playClick:(UIButton *)btn
{
    self.ctrlView.isPlay = !self.ctrlView.isPlay;
    if (self.ctrlView.isPlay) {
        [_player play];
    }else{
        [_player pause];
    }
}

-(void)fullScreenClick:(UIButton *)btn
{
    [self.ctrlView setIsFullScreen:!self.ctrlView.isFullScreen];
    if (self.ctrlView.isFullScreen) {
        self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
    } else {
        self.transform = CGAffineTransformIdentity;
        self.frame = __sframe;
    }
}


@end
