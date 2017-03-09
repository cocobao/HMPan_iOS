//
//  pssLocalMoviePlayViewController.m
//  ofoBike
//
//  Created by admin on 2016/12/20.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pssLocalMoviePlayViewController.h"
#import "IJKFFMoviePlayerController.h"


@interface pssLocalMoviePlayViewController ()
@property(atomic, retain) id<IJKMediaPlayback> player;
@property(atomic,strong) NSURL *url;
@end

@implementation pssLocalMoviePlayViewController

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //设置报告日志
    [IJKFFMoviePlayerController setLogReport:YES];
    //设置日志的级别为Debug
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
    //检查版本ffmpeg是否匹配
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    //默认选项配置
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = self.view.bounds;
    //设置播放视图的缩放模式
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    //自动更新子视图的大小
    self.view.autoresizesSubviews = YES;
    [self.view addSubview:self.player.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //开始播放
    [self.player prepareToPlay];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //关闭播放
    [self.player shutdown];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
