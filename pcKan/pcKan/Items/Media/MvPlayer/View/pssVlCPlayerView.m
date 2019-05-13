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
@end

@implementation pssVlCPlayerView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.ctrlView.frame = CGRectMake(0, 0, kScreenWidth, 40);
        [self.ctrlView setIsPlay:YES];
        [self.ctrlView setIsFullScreen:NO];
    
        [self.ctrlView.playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.ctrlView.fullScreen addTarget:self action:@selector(fullScreenClick:) forControlEvents:UIControlEventTouchUpInside];
    
        _player = [[VLCMediaPlayer alloc] init];
        _player.delegate = self;
        [_player setDrawable:self];
    }
    return self;
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
        [self forceChangeOrientation:UIInterfaceOrientationLandscapeRight];
    } else {
        [self forceChangeOrientation:UIInterfaceOrientationPortrait];
    }
}

- (void)forceChangeOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}
@end
