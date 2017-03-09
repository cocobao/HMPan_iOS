//
//  pssMovieConfig.m
//  pinut
//
//  Created by admin on 2017/1/13.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssMovieConfig.h"

@implementation pssMovieConfig
-(instancetype)init
{
    self = [super init];
    if (self) {
        _MovieMinBufferedDuration = 0.0f;
        _MovieDisableDeinterlacing = NO;
    }
    return self;
}
@end
