//
//  pSSMainTabbarViewController.m
//  picSimpleSend
//
//  Created by admin on 2016/10/9.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSMainTabbarViewController.h"
#import "pSSBaseNavgationViewController.h"
#import "pSSAlbumViewController.h"
#import "UPan_PanFileViewController.h"

@interface pSSMainTabbarViewController ()

@end

@implementation pSSMainTabbarViewController

+ (void)initialize
{
    //设置为不透明
    [[UITabBar appearance] setTranslucent:NO];
    
    // 设置背景颜色
    [UITabBar appearance].barTintColor = [UIColor whiteColor];//[UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    
    // 拿到整个导航控制器的外观
    UITabBarItem * item = [UITabBarItem appearance];
    item.titlePositionAdjustment = UIOffsetMake(0, 1.5);
    
    // 普通状态
    NSMutableDictionary * normalAtts = [NSMutableDictionary dictionary];
    normalAtts[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    normalAtts[NSForegroundColorAttributeName] = [UIColor colorWithRed:0.62f green:0.62f blue:0.63f alpha:1.00f];
    [item setTitleTextAttributes:normalAtts forState:UIControlStateNormal];
    
    // 选中状态
    NSMutableDictionary *selectAtts = [NSMutableDictionary dictionary];
    selectAtts[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    selectAtts[NSForegroundColorAttributeName] = [UIColor colorWithRed:0.42f green:0.33f blue:0.27f alpha:1.00f];
    [item setTitleTextAttributes:selectAtts forState:UIControlStateSelected];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addChildViewControllerWithClassName:[UPan_PanFileViewController description] imageName:@"audit" title:@"我的手盘"];
    [self addChildViewControllerWithClassName:[pSSAlbumViewController description] imageName:@"home" title:@"手机相册"];
}

//添加tabbar栏子控制器
-(void)addChildViewControllerWithClassName:(NSString *)className
                                 imageName:(NSString *)imageName
                                     title:(NSString *)title
{
    UIViewController *vc = [[NSClassFromString(className) alloc] init];
    pSSBaseNavgationViewController *nav = [[pSSBaseNavgationViewController alloc] initWithRootViewController:vc];
    
    if(title.length > 0)
        nav.tabBarItem.title = title;
    
    if(imageName.length > 0){
        nav.tabBarItem.image = [UIImage imageNamed:imageName];
        nav.tabBarItem.selectedImage = [[UIImage imageNamed:[imageName stringByAppendingString:@"_press"]]
                                        imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }

    [self addChildViewController:nav];
}
@end
