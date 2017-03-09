//
//  pSSBaseViewController.m
//  picSimpleSend
//
//  Created by admin on 2016/10/9.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSBaseViewController.h"
#import <objc/runtime.h>

const char NHBaseVcNavRightItemHandleKey;
const char NHBaseVcNavLeftItemHandleKey;

@interface pSSBaseViewController ()

@end

@implementation pSSBaseViewController

- (void)viewWillAppear:(BOOL)animated {
    self.view.backgroundColor = Color_BackGround;
    [super viewWillAppear:animated];
    [UIView setAnimationsEnabled:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    UIBarButtonItem *leftItem = self.navigationItem.leftBarButtonItem;
    UIButton *btn = leftItem.customView;
    [btn addTarget:self action:@selector(backBtnPress) forControlEvents:UIControlEventTouchUpInside];
}

-(void)addHub:(NSString *)hub hide:(BOOL)hi
{
    if (hi) {
        [MBProgressHUD showMessage:hub];
    }else{
        [MBProgressHUD showLoading:hub toView:self.view];
    }
}

-(void)removeHub
{
    [MBProgressHUD hideAllHUDsInView:self.view];
}

- (void)backBtnPress
{
    [self pop];
}

/** 设置导航栏右边的item*/
- (void)pss_setUpNavRightItemTitle:(NSString *)itemTitle handle:(void(^)(NSString *rightItemTitle))handle {
    [self nh_setUpNavItemTitle:itemTitle handle:handle leftFlag:NO];
}

/** 设置导航栏左边的item*/
- (void)nh_setUpNavLeftItemTitle:(NSString *)itemTitle handle:(void(^)(NSString *leftItemTitle))handle {
    [self nh_setUpNavItemTitle:itemTitle handle:handle leftFlag:YES];
}

- (void)pss_navItemHandle:(UIBarButtonItem *)item {
    void (^handle)(NSString *) = objc_getAssociatedObject(self, &NHBaseVcNavRightItemHandleKey);
    if (handle) {
        handle(item.title);
    }
}

- (void)nh_setUpNavItemTitle:(NSString *)itemTitle handle:(void(^)(NSString *itemTitle))handle leftFlag:(BOOL)leftFlag {
    if (itemTitle.length == 0 || !handle) {
        if (itemTitle == nil) {
            itemTitle = @"";
        } else if ([itemTitle isKindOfClass:[NSNull class]]) {
            itemTitle = @"";
        }
        if (leftFlag) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:itemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        } else {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:itemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        }
    } else {
        if (leftFlag) {
            objc_setAssociatedObject(self, &NHBaseVcNavLeftItemHandleKey, handle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:itemTitle style:UIBarButtonItemStylePlain target:self action:@selector(pss_navItemHandle:)];
        } else {
            objc_setAssociatedObject(self, &NHBaseVcNavRightItemHandleKey, handle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:itemTitle style:UIBarButtonItemStylePlain target:self action:@selector(pss_navItemHandle:)];
        }
    }
}


- (void)pushVc:(UIViewController *)vc {
    if (![vc isKindOfClass:[UIViewController class]]) return ;
    if (self.navigationController == nil) return ;
    if (!vc.hidesBottomBarWhenPushed) {
        vc.hidesBottomBarWhenPushed = YES;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pop {
    if (self.navigationController == nil) return ;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)popToRootVc {
    if (self.navigationController == nil) return ;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissWithCompletion:(void(^)())completion {
    [self dismissViewControllerAnimated:YES completion:completion];
}

- (void)presentVc:(UIViewController *)vc {
    if (![vc isKindOfClass:[UIViewController class]]) return ;
    [self presentVc:vc completion:nil];
}

- (void)presentVc:(UIViewController *)vc completion:(void (^)(void))completion {
    if (![vc isKindOfClass:[UIViewController class]]) return ;
    [self presentViewController:vc animated:YES completion:completion];
}
@end
