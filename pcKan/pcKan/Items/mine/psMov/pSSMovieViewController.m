//
//  pSSMovieViewController.m
//  pinut
//
//  Created by admin on 2017/1/7.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSMovieViewController.h"
#import "pssMovieView.h"
#import "pssNetMoviewView.h"
#import "pssLinkObj+Api.h"

@interface pSSMovieViewController ()
@property (nonatomic, strong) pssMovieView *movieView;
@property (nonatomic, strong) pssNetMoviewView *mNetPcMovieView;
@end

@implementation pSSMovieViewController

-(instancetype)initWithFilePath:(NSURL *)urlPath
{
    self = [super init];
    if (self) {
        _movieView = [[pssMovieView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth*9/16) urlPath:urlPath];
        [self.view addSubview:_movieView];
    }
    return self;
}

-(instancetype)initNetPcType
{
    self = [super init];
    if (self) {
        _mNetPcMovieView = [[pssNetMoviewView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth*9/16)];
        [self.view addSubview:_mNetPcMovieView];
    }
    return self;
}

-(void)setNetPcFps:(NSInteger)fps duration:(NSInteger)duration mvCodecId:(NSInteger)mvCodecId
{
    [_mNetPcMovieView setFps:fps duration:duration mvCodecId:mvCodecId];
}

-(void)setNetPcSampleFmt:(NSInteger)sampleFmt
              sampleRate:(NSInteger)sampleRate
                channels:(NSInteger)channels
               avCodecId:(NSInteger)avCodecId
{
    [_mNetPcMovieView setAudioInfo:avCodecId sampleFmt:sampleFmt sampleRate:sampleRate channels:channels];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(_movieView){
        [_movieView restorePlay];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(_movieView){
        [_movieView pause];
    }
    
    if (_mNetPcMovieView) {
        [pssLink NetApi_CloseMv];
        [_mNetPcMovieView cancelMv];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
