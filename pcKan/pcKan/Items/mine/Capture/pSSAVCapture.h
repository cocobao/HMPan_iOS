//
//  pSSAVCapture.h
//  pinut
//
//  Created by admin on 2016/12/28.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pSSAVConfig.h"


@interface pSSAVCapture : NSObject
-(instancetype)initWithVideoCfg:(pSSVideoConfig *)videoCfg;
@property (nonatomic, strong) pSSVideoConfig *videoCfg;

@property (nonatomic, strong) UIView *preView;

-(void)onInit;
-(NSString *)sessionPreset;
//修改fps
-(void)setfps:(NSInteger)fps;
//切换摄像头
-(void) switchCamera;
@end
