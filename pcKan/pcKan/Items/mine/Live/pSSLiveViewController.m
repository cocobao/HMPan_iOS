//
//  pSSLiveViewController.m
//  pinut
//
//  Created by admin on 2016/12/29.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSLiveViewController.h"
#import "pSSSystemACCapture.h"
#import "pSSAVConfig.h"

@interface pSSLiveViewController ()
@property (nonatomic, strong) pSSSystemACCapture *capture;
@property (nonatomic, strong) UIButton *retButton;
@property (nonatomic, strong) UIButton *switchButton;
@end

@implementation pSSLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.retButton.frame = CGRectMake(0, 11, 50, 50);
    self.switchButton.frame = CGRectMake(kScreenWidth-100, 22, 88, 30);
    
    pSSVideoConfig *cfg = [[pSSVideoConfig alloc] init];
    
    _capture = [[pSSSystemACCapture alloc] initWithVideoCfg:cfg];
    [self.view addSubview:_capture.preView];
    [self.view sendSubviewToBack:_capture.preView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [_capture destroySession];
}

-(void)switchCam
{
    [_capture switchCamera];
}

-(UIButton *)switchButton
{
    if (!_switchButton) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.cornerRadius = 5;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = Color_Main.CGColor;
        btn.titleLabel.font = kFont(15);
        [btn setTitle:@"切换摄像头" forState:UIControlStateNormal];
        [btn setTitleColor:Color_Main forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(switchCam) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        _switchButton = btn;
    }
    return _switchButton;
}

-(UIButton *)retButton
{
    if (!_retButton) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"global_ic_nav-whiteback_arrow"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        _retButton = btn;
    }
    return _retButton;
}
@end
