//
//  MBProgressHUD+pSSAddition.h
//  ofoBike
//
//  Created by admin on 2016/12/6.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface MBProgressHUD(pSSAddition)
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view ;

+ (void)showLoading:(UIView *)view ;

+ (void)showLoading:(NSString *)text toView:(UIView *)view ;
+ (void)showMessage:(NSString *)message ;
+ (void)showMessage:(NSString *)message toView:(UIView *)view ;

+ (void)showMessage:(NSString *)message detailMessage:(NSString*)detailMessage toView:(UIView *)view;

+ (void)hideAllHUDsInView:(UIView *)view;
@end
