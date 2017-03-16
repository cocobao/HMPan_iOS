//
//  UPan_MoveToViewController.m
//  pcKan
//
//  Created by admin on 2017/3/16.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_MoveToViewController.h"

@interface UPan_MoveToViewController ()
@property (nonatomic, strong) UIView *mHeadView;
@property (nonatomic, strong) UIView *mFootView;
@property (nonatomic, strong) UIButton *mCancelBtn;
@property (nonatomic, strong) UIButton *mNewFoldBtn;
@end

@implementation UPan_MoveToViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mHeadView.frame = CGRectMake(0, 0, kScreenWidth, kTopBarHeight);
    self.mFootView.frame = CGRectMake(0, kScreenHeight-kToolBarHeight, kScreenWidth, kToolBarHeight);
    self.mCancelBtn.frame = CGRectMake(kScreenWidth-60, kTopBarHeight-40, 60, 40);
    self.mNewFoldBtn.frame = CGRectMake(15, 3, (kScreenWidth-40)/2, kToolBarHeight-6);
}

-(void)cancelAction:(UIButton *)sender
{
    [self dismiss];
}

-(void)newFoldAction:(UIButton *)sender
{
    
}

-(UIButton *)mNewFoldBtn
{
    if (!_mNewFoldBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = Color_white(10);
        btn.titleLabel.font = kFont(15);
        btn.layer.cornerRadius = 5;
        [btn setTitle:@"新建文件夹" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(newFoldAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mFootView addSubview:btn];
        _mNewFoldBtn = btn;
    }
    return _mNewFoldBtn;
}

-(UIView *)mFootView
{
    if (!_mFootView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = ColorFromHex(0x434142);
        [self.view addSubview:view];
        _mFootView = view;
    }
    return _mFootView;
}

-(UIView *)mHeadView
{
    if (!_mHeadView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = Color_Main;
        [self.view addSubview:view];
        _mHeadView = view;
    }
    return _mHeadView;
}

-(UIButton *)mCancelBtn
{
    if (!_mCancelBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = kFont(18);
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mHeadView addSubview:btn];
        _mCancelBtn = btn;
    }
    return _mCancelBtn;
}
@end
