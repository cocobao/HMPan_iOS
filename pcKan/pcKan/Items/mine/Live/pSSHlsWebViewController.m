//
//  pSSHlsWebViewController.m
//  ofoBike
//
//  Created by admin on 2016/12/28.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSHlsWebViewController.h"

@interface pSSHlsWebViewController ()

@end

@implementation pSSHlsWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *str = @"http://10.10.18.139:80/live/2002_20161213/1280_720/2002_1280_720.m3u8";
    NSURL *url = [NSURL URLWithString:str];
    UIWebView *view = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAVBAR_H)];
    [view loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
