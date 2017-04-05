//
//  pssIjkPlayerViewController.m
//  pcKan
//
//  Created by admin on 17/3/27.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssIjkPlayerViewController.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "pssMediaControlView.h"

@interface pssIjkPlayerViewController ()
@property (atomic, strong) NSURL *mURL;
@property(atomic, retain) id<IJKMediaPlayback> player;
@property (nonatomic, strong) pssMediaControlView *ctrlView;
@property (assign, nonatomic) CGRect defaultFrame;
@end

@implementation pssIjkPlayerViewController

-(instancetype)initWithUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        _mURL = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
//    [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_frame" ofCategory:kIJKFFOptionCategoryCodec];
//    [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_loop_filter" ofCategory:kIJKFFOptionCategoryCodec];
//    [options setOptionIntValue:0 forKey:@"videotoolbox" ofCategory:kIJKFFOptionCategoryPlayer];
//    [options setOptionIntValue:60 forKey:@"max-fps" ofCategory:kIJKFFOptionCategoryPlayer];
//    [options setPlayerOptionIntValue:256 forKey:@"vol"];
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGRect playerFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);//CGRectMake(0, 0, width, width*9/16+NAVBAR_H);
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:_mURL withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = playerFrame;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    self.player.view.backgroundColor = [UIColor blackColor];
    self.player.view.center = CGPointMake(width/2, (kScreenHeight - NAVBAR_H)/2);
//    self.ctrlView.delegatePlayer = self.player;
//    self.ctrlView.frame = CGRectMake(0, playerFrame.size.height-40-NAVBAR_H, playerFrame.size.width, 40);
    
//    [self.player.view addSubview:self.ctrlView];
    [self.view addSubview:self.player.view];
    
//    _defaultFrame = self.view.frame;
    
//    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlayer:)]; 
//    [self.player.view addGestureRecognizer:gesture];
}

- (BOOL)prefersStatusBarHidden{
    if (self.ctrlView.fullBtn.selected) {
        return YES;
    }
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self installMovieNotificationObservers];
//    [self.ctrlView refreshMediaControl];
    [self.player prepareToPlay];
    
//    [self performSelector:@selector(hideCtrlBar) withObject:nil afterDelay:3];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player shutdown];
    [self removeMovieNotificationObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)tapPlayer:(UITapGestureRecognizer *)gesture
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCtrlBar) object:nil];
    if (self.ctrlView.hidden) {
        self.ctrlView.hidden = NO;
        [self performSelector:@selector(hideCtrlBar) withObject:nil afterDelay:3];
    }else{
        self.ctrlView.hidden = YES;
    }
}

-(void)hideCtrlBar
{
    self.ctrlView.hidden = YES;
}

- (void)onClickPlay:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [self.player play];
    }else{
        [self.player pause];
    }
    
    [self.ctrlView refreshMediaControl];
}

- (void)didSliderTouchDown
{
    [self.player pause];
    [self.ctrlView beginDragMediaSlider];
}

- (void)didSliderTouchCancel
{
    [self.ctrlView endDragMediaSlider];
}

- (void)didSliderTouchUpOutside
{
    if (!self.ctrlView.playerBtn.selected) {
        [self.player play];
    }
    [self.ctrlView endDragMediaSlider];
}

- (void)didSliderTouchUpInside
{
    self.player.currentPlaybackTime = self.ctrlView.mediaProgressSlider.value;
    if (!self.ctrlView.playerBtn.selected) {
        [self.player play];
    }
    
    [self.ctrlView endDragMediaSlider];
}

- (void)didSliderValueChanged
{
    self.player.currentPlaybackTime = self.ctrlView.mediaProgressSlider.value;
    [self.ctrlView continueDragMediaSlider];
}

-(void)fullAction:(UIButton *)sender
{
    if (sender.selected) {
        sender.selected = NO;
        [sender setImage:[UIImage imageNamed:@"gui_expand"] forState:UIControlStateNormal];

        [self.navigationController setNavigationBarHidden:NO animated:NO];
        
        [UIView animateWithDuration:0.3f animations:^{
            [self.view setTransform:CGAffineTransformIdentity];
            [self.view setFrame:_defaultFrame];
            
            CGRect frame = _defaultFrame;
            frame.origin = CGPointZero;
            frame.size.height = frame.size.width*9/16+NAVBAR_H;
            
            [self.player.view setFrame:frame];
            self.player.view.center = CGPointMake(frame.size.width/2, (kScreenHeight - NAVBAR_H)/2);
            self.ctrlView.frame = CGRectMake(0, frame.size.height-40-NAVBAR_H, frame.size.width, 40);
        }];
    }else{
        sender.selected = YES;
        [sender setImage:[UIImage imageNamed:@"gui_shrink"] forState:UIControlStateNormal];

        //隐藏导航栏
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        
        CGFloat width = [[UIScreen mainScreen] bounds].size.width;
        CGFloat height = [[UIScreen mainScreen] bounds].size.height;
        CGRect frame;
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            CGFloat aux = width;
            width = height;
            height = aux;
            frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
        } else {
            frame = CGRectMake(0, 0, width, height);
        }
        
        [UIView animateWithDuration:0.3f animations:^{
            [self.view setFrame:frame];
            [self.player.view setFrame:CGRectMake(0, 0, width, height)];
            self.ctrlView.frame = CGRectMake(0, frame.size.height-40, frame.size.width, 40);
            
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
            }
        }];
    }
}

- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    
    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            self.ctrlView.playerBtn.selected = YES;
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}

-(pssMediaControlView *)ctrlView
{
    if (!_ctrlView) {
        pssMediaControlView *view = [[pssMediaControlView alloc] init];
        [view.playerBtn addTarget:self action:@selector(onClickPlay:) forControlEvents:UIControlEventTouchUpInside];
        [view.mediaProgressSlider addTarget:self action:@selector(didSliderTouchDown) forControlEvents:UIControlEventTouchDown];
        [view.mediaProgressSlider addTarget:self action:@selector(didSliderTouchCancel) forControlEvents:UIControlEventTouchCancel];
        [view.mediaProgressSlider addTarget:self action:@selector(didSliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [view.mediaProgressSlider addTarget:self action:@selector(didSliderTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [view.mediaProgressSlider addTarget:self action:@selector(didSliderTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [view.fullBtn addTarget:self action:@selector(fullAction:) forControlEvents:UIControlEventTouchUpInside];
        _ctrlView = view;
    }
    return _ctrlView;
}
@end
