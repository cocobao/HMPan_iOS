//
//  pssVLCPlayerViewController.m
//  pcKan
//
//  Created by bz y on 2019/4/4.
//  Copyright © 2019 ybz. All rights reserved.
//

#import "pssVLCPlayerViewController.h"
#import "MRVLCPlayer.h"
#import "pssVLCControlView.h"

@interface pssVLCPlayerViewController ()<VLCMediaPlayerDelegate,MRVideoControlViewDelegate>
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) VLCMediaPlayer *player;
@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) pssVLCControlView *ctrlView;
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
    self.view.backgroundColor = [UIColor blackColor];
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth*9/16)];
    _backView.backgroundColor = [UIColor blackColor];
    _backView.center = CGPointMake(kScreenWidth/2, kScreenHeight/2-NAVBAR_H);
    [self.view addSubview:_backView];
    
    self.ctrlView.frame = CGRectMake(0, kScreenHeight-32-NAVBAR_H, kScreenWidth, 40);
    
    [self.ctrlView setIsPlay:YES];
    [self.ctrlView setIsFullScreen:NO];
    
    [self.ctrlView.playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.ctrlView.fullScreen addTarget:self action:@selector(fullScreenClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _player = [[VLCMediaPlayer alloc] init];
    _player.delegate = self;
    [_player setDrawable:_backView];
    _player.media = [[VLCMedia alloc] initWithURL:[NSURL fileURLWithPath:_filePath]];
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
    self.ctrlView.isFullScreen = !self.ctrlView.isFullScreen;
}

-(void)backBtnPress
{
    [super backBtnPress];

    [self.player stop];
    self.player.delegate = nil;
    self.player.drawable = nil;
    self.player = nil;
}

-(UIView *)ctrlView
{
    if (!_ctrlView) {
        _ctrlView = [[pssVLCControlView alloc] init];
        [self.view addSubview:_ctrlView];
    }
    return _ctrlView;
}
@end
