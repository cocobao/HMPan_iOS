/*### WS@H Project:EHouse ###*/
//
//  UIAlertView+RWBlock.h
//  StringUsing
//
//  Created by admin on 15/11/11.
//  Copyright © 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^didCompleteBlock)(UIAlertView *alertView, NSInteger btnIndex);

@interface UIAlertView(RWBlock)<UIAlertViewDelegate>
-(void)setCompleteBlock:(didCompleteBlock)regBlock;

-(didCompleteBlock)didComplete;
@end
