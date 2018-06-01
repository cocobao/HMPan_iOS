//
//  CamPaiViewController.m
//  pcKan
//
//  Created by SZ14122141M01 on 2018/5/22.
//  Copyright © 2018年 ybz. All rights reserved.
//

#import "CamPaiViewController.h"
#import "pssSystemAvCapture.h"

@interface CamPaiViewController ()
@property (nonatomic, strong) UIView *preView;
@property (nonatomic, strong) pssSystemAVCapture *canPai;
@end

@implementation CamPaiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preView.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth*9/16);
    
    _canPai = [[pssSystemAVCapture alloc] initWithView:self.preView];
}

-(UIView *)preView
{
    if (!_preView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor blackColor];
        [self.view addSubview:view];
        _preView = view;
    }
    return _preView;
}


@end
