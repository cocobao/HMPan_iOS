/*### WS@H Project:EHouse ###*/
//
//  EHSuspensionFrameTextFieldView.m
//  EHouse
//
//  Created by ybz on 16/4/29.
//  Copyright © 2016年 wondershare. All rights reserved.
//

#import "EHSuspensionFrameTextFieldView.h"

@interface EHSuspensionFrameTextFieldView ()<UITextFieldDelegate>
{
    NSString *title;
    NSString *placeholder;
    UIView *_backView;
    UIView *backGroundFrameView;
    UITextField *textField;
    CGFloat viewWidth;
    CGFloat viewHeigh;
}
@end

@implementation EHSuspensionFrameTextFieldView
-(instancetype)initWithTitle:(NSString *)intitle placeholder:(NSString *)inplaceholder
{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    if (self) {
        title = intitle;
        placeholder = inplaceholder;
        
        viewWidth = kScreenWidth;
        viewHeigh = kScreenHeight;
        [self setupViews];
    }
    return self;
}

-(instancetype)initWithTitle:(NSString *)intitle placeholder:(NSString *)inplaceholder superVc:(UIViewController *)superVc
{
    self = [super init];
    if (self) {
        _superVc = superVc;
        title = intitle;
        placeholder = inplaceholder;
        
        viewWidth = _superVc.view.bounds.size.width;
        viewHeigh = _superVc.view.bounds.size.height;
        self.frame = CGRectMake(0, 0, viewWidth, viewHeigh);
        
        [self setupViews];
    }
    return self;
}

-(void)setupViews
{
    //黑色全屏背景
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeigh)];
    [_backView setBackgroundColor:Color_black(50)];
    [_backView setAlpha:0];
    [self addSubview:_backView];
    
    //背景框
    backGroundFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, viewWidth-20, viewHeigh/3.f)];
    backGroundFrameView.backgroundColor = [UIColor whiteColor];
    backGroundFrameView.layer.cornerRadius = 5;
    backGroundFrameView.center = CGPointMake(viewWidth/2.f, viewHeigh/2.f);
    [self addSubview:backGroundFrameView];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(backGroundFrameView.frame), CGRectGetHeight(backGroundFrameView.frame)/3.f)];
    titleLabel.font = kFont(19);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = Color_black(60);
    titleLabel.text = title;
    [backGroundFrameView addSubview:titleLabel];

    //编辑框
    UIView *textFieldFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame), CGRectGetWidth(backGroundFrameView.frame)-20, CGRectGetHeight(backGroundFrameView.frame)/3.f-10)];
    textFieldFrameView.layer.cornerRadius = 5.f;
    textFieldFrameView.layer.borderWidth = 0.5f;
    textFieldFrameView.layer.borderColor = Color_Line.CGColor;
    [backGroundFrameView addSubview:textFieldFrameView];

    //编辑栏
    textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, CGRectGetWidth(textFieldFrameView.frame)-20, CGRectGetHeight(textFieldFrameView.frame)-10)];
//    textField.placeholder = placeholder;
    textField.text = placeholder;
    textField.delegate = self;
    [textFieldFrameView addSubview:textField];

    //底部按钮
    CGFloat btnHeigh = CGRectGetHeight(backGroundFrameView.frame)/3.f-10;
    CGFloat btnWidth = CGRectGetWidth(backGroundFrameView.frame)/2.f;
    CGFloat heigh = CGRectGetHeight(backGroundFrameView.frame)-btnHeigh;
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, heigh, btnWidth, btnHeigh)];
    leftButton.titleLabel.font = kFont(15);
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:Color_black(60) forState:UIControlStateNormal];
    leftButton.tag = 0;
    [backGroundFrameView addSubview:leftButton];

    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(btnWidth, heigh, btnWidth, btnHeigh)];
    rightButton.titleLabel.font = kFont(15);
    [rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [rightButton setTitleColor:Color_black(60) forState:UIControlStateNormal];
    rightButton.tag = 1;
    [backGroundFrameView addSubview:rightButton];

    //画线条
    CALayer *line = [CALayer layer];
    line.backgroundColor = Color_Line.CGColor;
    line.frame = CGRectMake(0, heigh, CGRectGetWidth(backGroundFrameView.frame), 0.5f);
    [backGroundFrameView.layer addSublayer:line];

    line = [CALayer layer];
    line.backgroundColor = Color_Line.CGColor;
    line.frame = CGRectMake(btnWidth, heigh, 0.5f, btnHeigh);
    [backGroundFrameView.layer addSublayer:line];

    [leftButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)show
{
    if (_superVc != nil) {
        [_superVc.view addSubview:self];
    }else{
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }

    backGroundFrameView.alpha = 0.1f;
    backGroundFrameView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    
    [UIView animateWithDuration:0.2 animations:^{
        backGroundFrameView.alpha = 1;
        [_backView setAlpha:0.5f];
        backGroundFrameView.transform = CGAffineTransformIdentity;
    }];
}

-(void)removeMySelf
{
    [UIView animateWithDuration:0.2 animations:^{
        _backView.alpha = 0;
        backGroundFrameView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    } completion:^(BOOL finish){
        [self removeFromSuperview];
    }];
}

-(void)buttonPress:(UIButton *)sender
{
    if (sender.tag == 1) {
        if (textField.text == nil || textField.text.length == 0) {
            [self removeMySelf];
            return;
        }
    }
    
    [self removeMySelf];
    
    if (_didSelectButton) {
        _didSelectButton(sender.tag, textField.text);
    }
}

-(void)willShowKeyboard:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = [self convertRect:keyboardRect fromView:nil].origin.y;
    if (CGRectGetMaxY(backGroundFrameView.frame) > keyboardY) {
        CGRect frame = backGroundFrameView.frame;
        frame.origin.y -= CGRectGetMaxY(backGroundFrameView.frame) - keyboardY+10;
        [UIView animateWithDuration:0.3 animations:^{
            backGroundFrameView.frame = frame;
        }];
    }
}

-(void)willHideKeyboard:(NSNotification *)notification
{
    CGPoint center = CGPointMake(viewWidth/2.f, viewHeigh/2.f);
    
    [UIView animateWithDuration:0.3 animations:^{
        backGroundFrameView.center = center;
    }];
}
@end
