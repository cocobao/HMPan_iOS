//
//  pSSBaseViewController.h
//  picSimpleSend
//
//  Created by admin on 2016/10/9.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface pSSBaseViewController : UIViewController
- (void)pushVc:(UIViewController *)vc ;

- (void)pop ;

- (void)popToRootVc ;

- (void)dismiss ;

- (void)dismissWithCompletion:(void(^)())completion;

- (void)presentVc:(UIViewController *)vc;

- (void)presentVc:(UIViewController *)vc completion:(void (^)(void))completion;

- (void)backBtnPress;

-(void)addHub:(NSString *)hub hide:(BOOL)hi;

-(void)removeHub;
@end
