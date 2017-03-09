//
//  pSSBaseNavgationViewController.m
//  picSimpleSend
//
//  Created by admin on 2016/10/9.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSBaseNavgationViewController.h"

@interface pSSBaseNavgationViewController ()

@end

@implementation pSSBaseNavgationViewController

+(void)initialize
{
    //设置为不透明
    [[UINavigationBar appearance] setTranslucent:NO];
    //设置导航栏的背景色
    [UINavigationBar appearance].barTintColor = Color_Main;
    //设置导航栏标题文字颜色
    NSMutableDictionary *color = [NSMutableDictionary dictionary];
    color[NSFontAttributeName] = [UIFont systemFontOfSize:17.f];
    color[NSForegroundColorAttributeName] = DEFAULT_NAV_TINTCOLOR;
    [[UINavigationBar appearance] setTitleTextAttributes:color];
    
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    item.tintColor = DEFAULT_NAV_TINTCOLOR;
    
    NSMutableDictionary *atts = [NSMutableDictionary dictionary];
    atts[NSFontAttributeName] = [UIFont systemFontOfSize:17];
    atts[NSForegroundColorAttributeName] = DEFAULT_NAV_TINTCOLOR;
    [item setTitleTextAttributes:atts forState:UIControlStateNormal];
    
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //对压栈的vc默认都添加左导航栏返回
    if (self.viewControllers.count > 0) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [btn setImage:[UIImage imageNamed:@"global_ic_nav-whiteback_arrow"] forState:UIControlStateNormal];
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, -18, 0, 0);
        btn.tintColor = DEFAULT_NAV_TINTCOLOR;
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        viewController.navigationItem.leftBarButtonItem = leftItem;
    }
    [super pushViewController:viewController animated:animated];
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    return [super popViewControllerAnimated:animated];
}
@end
