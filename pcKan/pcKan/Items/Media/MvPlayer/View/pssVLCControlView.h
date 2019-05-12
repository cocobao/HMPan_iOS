//
//  pssVLCControlView.h
//  pcKan
//
//  Created by bz y on 2019/5/12.
//  Copyright © 2019 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface pssVLCControlView : UIView
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *fullScreen;
@property (nonatomic, assign) BOOL isPlay;
@property (nonatomic, assign) BOOL isFullScreen;
@end

NS_ASSUME_NONNULL_END
