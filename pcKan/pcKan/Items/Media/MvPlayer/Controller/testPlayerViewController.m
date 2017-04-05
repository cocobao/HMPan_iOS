//
//  testPlayerViewController.m
//  pcKan
//
//  Created by admin on 17/4/4.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "testPlayerViewController.h"
#import <IJKMediaFramework/IJKMediaFramework.h>

@interface testPlayerViewController ()
@property(atomic,strong) NSURL *url;
@property(atomic, retain) id<IJKMediaPlayback> player;
@end

@implementation testPlayerViewController
- (instancetype)initWithUrl:(NSURL *)url {
    self = [self init];
    if (self) {
        self.url = url;
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
    
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = self.view.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    self.view.autoresizesSubviews = YES;
    [self.view addSubview:self.player.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.player prepareToPlay];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.player shutdown];
}

@end
