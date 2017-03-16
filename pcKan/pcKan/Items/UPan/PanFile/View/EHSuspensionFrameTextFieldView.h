/*### WS@H Project:EHouse ###*/
//
//  EHSuspensionFrameTextFieldView.h
//  EHouse
//
//  Created by ybz on 16/4/29.
//  Copyright © 2016年 wondershare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHSuspensionFrameTextFieldView : UIView
-(instancetype)initWithTitle:(NSString *)intitle placeholder:(NSString *)inplaceholder;
-(instancetype)initWithTitle:(NSString *)intitle placeholder:(NSString *)inplaceholder superVc:(UIViewController *)superVc;
-(void)show;

@property (nonatomic, copy) void (^didSelectButton)(NSInteger index, NSString *text);

@property (nonatomic, weak) UIViewController *superVc;
@end
