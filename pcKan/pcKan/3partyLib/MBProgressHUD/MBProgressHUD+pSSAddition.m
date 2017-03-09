//
//  MBProgressHUD+pSSAddition.m
//  ofoBike
//
//  Created by admin on 2016/12/6.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "MBProgressHUD+pSSAddition.h"

@implementation MBProgressHUD(pSSAddition)
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view {
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:0.7];
}

+ (void)showLoading:(UIView *)view {
    [self showLoading:nil toView:view];
}

+ (void)showLoading:(NSString *)text toView:(UIView *)view {
    
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    if (text.length == 0) {
        text = @"Loading";
    }
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    // Set the label text.
    hud.labelText = text;
    hud.color = [UIColor blackColor];
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:15];
    
}

+ (void)showMessage:(NSString *)message {
    [self showMessage:message toView:nil];
}

+ (void)showMessage:(NSString *)message toView:(UIView *)view {
    
    if (message.length == 0) return;
    
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    hud.mode = MBProgressHUDModeText;
    hud.margin = 10.f;
    // 设置hub颜色
    hud.color = [UIColor blackColor];
    hud.cornerRadius = 5.0f;
    // 设置边框颜色
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1.3秒之后再消失
    [hud hide:YES afterDelay:2.0f];
}

+ (void)showMessage:(NSString *)message detailMessage:(NSString*)detailMessage toView:(UIView *)view {
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    hud.detailsLabelText = detailMessage;
    hud.mode = MBProgressHUDModeText;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:1.8];
    
}

+ (void)hideAllHUDsInView:(UIView *)view {
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}
@end
