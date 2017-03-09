//
//  pssGLView.h
//  pinut
//
//  Created by admin on 17/1/7.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "pssGLRender.h"

@interface pssGLView : UIView
-(instancetype)initWithFrame:(CGRect)frame format:(KxVideoFrameFormat)format;
-(void)render:(KxVideoFrame *)frame;
-(void)setFrameWidth:(float)width height:(float)height;
@end
