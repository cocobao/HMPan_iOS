//
//  pssMovieView.h
//  pinut
//
//  Created by admin on 2017/1/17.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface pssMovieView : UIView
@property (nonatomic, assign) BOOL playing;

- (instancetype)initWithFrame:(CGRect)frame urlPath:(NSURL *)urlPath;
-(void)pause;
-(void)restorePlay;
-(void)play;
@end
