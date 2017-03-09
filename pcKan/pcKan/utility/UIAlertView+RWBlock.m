/*### WS@H Project:EHouse ###*/
//
//  UIAlertView+RWBlock.m
//  StringUsing
//
//  Created by admin on 15/11/11.
//  Copyright © 2015年 admin. All rights reserved.
//

#import "UIAlertView+RWBlock.h"
#import <objc/runtime.h>

@implementation UIAlertView(RWBlock)

-(void)setCompleteBlock:(didCompleteBlock)regBlock
{
    objc_setAssociatedObject(self, @selector(didComplete), regBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (regBlock) {
        self.delegate = self;
    }else{
        self.delegate = nil;
    }
}

-(didCompleteBlock)didComplete
{
    return objc_getAssociatedObject(self, @selector(didComplete));
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.didComplete) {
        self.didComplete(alertView, buttonIndex);
    }
}

@end
