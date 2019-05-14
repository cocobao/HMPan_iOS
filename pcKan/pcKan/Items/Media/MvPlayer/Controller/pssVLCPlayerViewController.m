//
//  pssVLCPlayerViewController.m
//  pcKan
//
//  Created by bz y on 2019/4/4.
//  Copyright © 2019 ybz. All rights reserved.
//

#import "pssVLCPlayerViewController.h"
#import "pssVlCPlayerView.h"

@interface pssVLCPlayerViewController ()
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) pssVlCPlayerView *playerView;

@end

@implementation pssVLCPlayerViewController


-(instancetype)initWithFilePath:(NSString *)filePath
{
    if (self = [super init]) {
        _filePath = filePath;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = Color_BackGround;
    _playerView = [[pssVlCPlayerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth*9/16)];
    _playerView.center = CGPointMake(kScreenWidth/2, kScreenHeight/2-NAVBAR_H);
    [self.view addSubview:_playerView];
    
//    [_playerView play:_filePath];
    
//    self.ctrlView.frame = CGRectMake(0, kScreenHeight-40-NAVBAR_H, kScreenWidth, 40);
//    [self.ctrlView setIsPlay:YES];
//    [self.ctrlView setIsFullScreen:NO];
//
//    [self.ctrlView.playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.ctrlView.fullScreen addTarget:self action:@selector(fullScreenClick:) forControlEvents:UIControlEventTouchUpInside];
//
//    _player = [[VLCMediaPlayer alloc] init];
//    _player.delegate = self;
//    [_player setDrawable:_backView];
//    _player.media = [[VLCMedia alloc] initWithURL:[NSURL fileURLWithPath:_filePath]];
//    [_player play];
}
//

//
//-(void)backBtnPress
//{
//    [super backBtnPress];
//
//    [self.player stop];
//    self.player.delegate = nil;
//    self.player.drawable = nil;
//    self.player = nil;
//}
//
//-(UIView *)ctrlView
//{
//    if (!_ctrlView) {
//        _ctrlView = [[pssVLCControlView alloc] init];
//        [self.view addSubview:_ctrlView];
//    }
//    return _ctrlView;
//}
@end
