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
@property (nonatomic, strong) NSURL *mURL;
@property(atomic, retain) id<IJKMediaPlayback> player;
@property (nonatomic, strong) pssMediaControlView *ctrlView;
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
    [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_frame" ofCategory:kIJKFFOptionCategoryCodec];
    [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_loop_filter" ofCategory:kIJKFFOptionCategoryCodec];
    [options setOptionIntValue:0 forKey:@"videotoolbox" ofCategory:kIJKFFOptionCategoryPlayer];
    [options setOptionIntValue:60 forKey:@"max-fps" ofCategory:kIJKFFOptionCategoryPlayer];
    [options setPlayerOptionIntValue:256 forKey:@"vol"];
    
    CGRect playerFrame = CGRectMake(0, 0, kScreenWidth, kScreenWidth*9.0f / 16.0f+64);
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:_mURL withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = playerFrame;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    self.player.view.center = CGPointMake(kScreenWidth/2, (kScreenHeight)/2-64);
    self.player.view.backgroundColor = [UIColor blackColor];
    
    self.ctrlView.delegatePlayer = self.player;
    self.ctrlView.frame = CGRectMake(0, playerFrame.size.height-40-64, playerFrame.size.width, 40);
    
    [self.player.view addSubview:self.ctrlView];
    [self.view addSubview:self.player.view];
}

- (void)viewWillAppear:(BOOL)animated {
    WeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.player prepareToPlay];
    });
    [super viewWillAppear:animated];
    [self installMovieNotificationObservers];
    
    [self.ctrlView refreshMediaControl];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.player shutdown];
    [super viewDidDisappear:animated];
    [self removeMovieNotificationObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    [self.ctrlView beginDragMediaSlider];
}

- (void)didSliderTouchCancel
{
    [self.ctrlView endDragMediaSlider];
}

- (void)didSliderTouchUpOutside
{
    [self.ctrlView endDragMediaSlider];
}

- (void)didSliderTouchUpInside
{
    self.player.currentPlaybackTime = self.ctrlView.mediaProgressSlider.value;
    [self.ctrlView endDragMediaSlider];
}

- (void)didSliderValueChanged
{
    [self.ctrlView continueDragMediaSlider];
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
        _ctrlView = view;
    }
    return _ctrlView;
}
@end
