//
//  kanItemView.m
//  pcKan
//
//  Created by admin on 2017/2/21.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "kanItemView.h"

@implementation kanItemView

-(instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = Color_Main.CGColor;
        self.layer.cornerRadius = 10;
        
        [self.titleLabel setFont:kFont(16)];
        [self setTitleColor:Color_Main forState:UIControlStateNormal];
        [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(touchDragExit) forControlEvents:UIControlEventTouchDragExit];
        [self addTarget:self action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)touchDown
{
    [UIView animateWithDuration:0.1f animations:^{
        self.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
    }];
}

-(void)touchDragExit
{
    [UIView animateWithDuration:0.1f animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
}

-(void)touchUpInside
{
    [UIView animateWithDuration:0.1f animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
}

@end
