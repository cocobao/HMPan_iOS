//
//  pSSControlBarView.m
//  pcKan
//
//  Created by admin on 17/3/21.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSControlBarView.h"

@implementation pSSControlBarView

-(instancetype)init
{
    CGRect frame = CGRectMake(0, kScreenHeight-NAVBAR_H, kScreenWidth, 50);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectAllBtn.frame = CGRectMake(0, 0, 80, frame.size.height);
        self.sendBtn.frame = CGRectMake(kScreenWidth-80, 0, 80, frame.size.height);
    }
    return self;
}

-(UIButton *)selectAllBtn
{
    if (!_selectAllBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"全选" forState:UIControlStateNormal];
        btn.titleLabel.font = kFont(15);
        [btn setTitleColor:Color_Main forState:UIControlStateNormal];
        [self addSubview:btn];
        _selectAllBtn = btn;
    }
    return _selectAllBtn;
}

-(UIButton *)sendBtn
{
    if (!_sendBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"发送" forState:UIControlStateNormal];
        btn.titleLabel.font = kFont(15);
        [btn setTitleColor:Color_Main forState:UIControlStateNormal];
        [self addSubview:btn];
        _sendBtn = btn;
    }
    return _sendBtn;
}
@end
