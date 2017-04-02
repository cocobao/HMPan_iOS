//
//  pssGUIPlayerViewController.m
//  pcKan
//
//  Created by admin on 17/3/23.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssGUIPlayerViewController.h"
#import "GUIPlayerView.h"

@interface pssGUIPlayerViewController ()<GUIPlayerViewDelegate>
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) GUIPlayerView *playerView;
@end

@implementation pssGUIPlayerViewController

-(instancetype)initWithUrl:(NSURL *)url
{
    self = [super init];
    if(self){
        _url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = kScreenWidth;
    _playerView = [[GUIPlayerView alloc] initWithFrame:CGRectMake(0, 0, width, width * 9.0f / 16.0f)];
    _playerView.center = CGPointMake(kScreenWidth/2, (kScreenHeight)/2-64);
    [_playerView setDelegate:self];
    _playerView.backgroundColor = [UIColor blackColor];
    [[self view] addSubview:_playerView];
    
    [_playerView setVideoURL:_url];
    [_playerView prepareAndPlayAutomatically:YES];
}

-(void)backBtnPress
{
    [_playerView clean];
    [_playerView stop];
    
    [super backBtnPress];
}

#pragma mark - GUI Player View Delegate Methods

- (void)playerWillEnterFullscreen {
    [[self navigationController] setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)playerWillLeaveFullscreen {
    [[self navigationController] setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)playerDidEndPlaying {
//    [_playerView clean];
}

- (void)playerFailedToPlayToEnd {
    NSLog(@"Error: could not play video");
//    [_playerView clean];
}

@end
