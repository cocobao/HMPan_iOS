//
//  pSSControlBarView.m
//  pcKan
//
//  Created by admin on 17/3/21.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSControlBarView.h"

@interface pSSControlBarView ()
@property (nonatomic, strong) UILabel *mSelectCountLabel;
@end

@implementation pSSControlBarView

-(instancetype)init
{
    CGRect frame = CGRectMake(0, kScreenHeight-NAVBAR_H, kScreenWidth, 50);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectAllBtn.frame = CGRectMake(20, 0, 80, frame.size.height);
        self.sendBtn.frame = CGRectMake(kScreenWidth-120, 0, 100, frame.size.height);
        self.mSelectCountLabel.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    }
    return self;
}

-(void)addCount:(NSInteger)count
{
    self.mSelectCountLabel.tag += count;
    self.mSelectCountLabel.text = [NSString stringWithFormat:@"%zd", self.mSelectCountLabel.tag];
}

-(void)setCount:(NSInteger)count
{
    self.mSelectCountLabel.tag = count;
    self.mSelectCountLabel.text = [NSString stringWithFormat:@"%zd", count];
}

-(UILabel *)mSelectCountLabel
{
    if (!_mSelectCountLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        label.font = kFont(14);
        label.backgroundColor = Color_Main;
        label.layer.cornerRadius = label.frame.size.height/2;
        label.textColor = [UIColor whiteColor];
        label.text = @"0";
        label.textAlignment = NSTextAlignmentCenter;
        label.clipsToBounds = YES;
        [self addSubview:label];
        _mSelectCountLabel = label;
    }
    return _mSelectCountLabel;
}

-(UIButton *)selectAllBtn
{
    if (!_selectAllBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"全选" forState:UIControlStateNormal];
        btn.titleLabel.font = kFont(15);
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
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
        [btn setTitle:@"发送到电脑" forState:UIControlStateNormal];
        btn.titleLabel.font = kFont(15);
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [btn setTitleColor:Color_Main forState:UIControlStateNormal];
        [self addSubview:btn];
        _sendBtn = btn;
    }
    return _sendBtn;
}
@end
