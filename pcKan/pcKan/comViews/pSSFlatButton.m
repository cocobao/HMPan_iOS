//
//  pSSFlatButton.m
//  OneYuanBike
//
//  Created by admin on 2016/12/6.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSFlatButton.h"

@implementation pSSFlatButton

{
    NSInteger _Style;
}
-(instancetype)init
{
    if (self = [super init]) {
        [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(touchDragExit) forControlEvents:UIControlEventTouchDragExit];
        [self addTarget:self action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(touchDragExit) forControlEvents:UIControlEventTouchDragExit];
        [self addTarget:self action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame style:(NSInteger)style
{
    if (self = [super initWithFrame:frame]) {
        [self setButtonStyle:style];
        
        [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(touchDragExit) forControlEvents:UIControlEventTouchDragExit];
        [self addTarget:self action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)setButtonStyle:(NSInteger)style
{
    CGRect frame = self.frame;
    _Style = style;
    switch (_Style) {
        case 10:
        {
            frame.size.width = MarginW(60);
            frame.size.height = MarginH(26);
            self.layer.borderWidth = 1.f;
            self.layer.borderColor = Color_bfbfbf.CGColor;
            self.layer.cornerRadius = frame.size.height/2;
            self.titleLabel.font = kFont(13);
            [self setTitleColor:Color_828282 forState:UIControlStateNormal];
            [self setTitleColor:Color_Main_50 forState:UIControlStateHighlighted];
        }
            break;
        case 13:
        {
            frame.size.width = MarginW(126);
            frame.size.height = MarginH(42);
            self.layer.borderWidth = 1.f;
            self.layer.borderColor = Color_bfbfbf.CGColor;
            self.layer.cornerRadius = frame.size.height/2;
            self.titleLabel.font = kFont(15);
            [self setTitleColor:Color_828282 forState:UIControlStateNormal];
            [self setTitleColor:Color_Main_50 forState:UIControlStateHighlighted];
            
        }
            break;
        default:
            break;
    }
    self.frame = frame;
}

-(void)touchDown
{
    switch (_Style) {
        case 10:
        case 13:
        {
            self.layer.borderColor = Color_Main_50.CGColor;
        }
            break;
            
        default:
            break;
    }
}

-(void)touchDragExit
{
    switch (_Style) {
        case 10:
        case 13:
        {
            self.layer.borderColor = Color_bfbfbf.CGColor;
        }
            break;
            
        default:
            break;
    }
}

-(void)touchUpInside
{
    switch (_Style) {
        case 10:
        case 13:
        {
            self.layer.borderColor = Color_bfbfbf.CGColor;
        }
            break;
            
        default:
            break;
    }
}


@end
