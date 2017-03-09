//
//  pSSURLVideoViewController.m
//  ofoBike
//
//  Created by admin on 2016/12/27.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSURLVideoViewController.h"
#import "IJKFFMoviePlayerController.h"
#import "pSSMovieViewController.h"

@interface pSSURLVideoViewController ()
@property (nonatomic, strong) IJKFFMoviePlayerController *player;
@end

@implementation pSSURLVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    NSURL *url = [NSURL URLWithString:@"rtmp://10.10.18.139:1935/vod/output1.mp4"];
//    NSURL *url = [NSURL URLWithString:@"http://10.10.18.139:80/live/2002_20161213/1280_720/2002_1280_720.m3u8"];
//    IJKFFMoviePlayerController *playerVc = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:nil];
//    //准备播放
//    [playerVc prepareToPlay];
//    playerVc.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth*9/16);
//    playerVc.view.center = CGPointMake(kScreenWidth/2, kScreenHeight/2-NAVBAR_H);
//    [self.view addSubview:playerVc.view];
//    _player = playerVc;
    
    pSSMovieViewController *vc = [[pSSMovieViewController alloc] initWithFilePath:nil];
    [self.view addSubview:vc.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
//    [_player pause];
//    [_player stop];
//    [_player shutdown];
}

@end
