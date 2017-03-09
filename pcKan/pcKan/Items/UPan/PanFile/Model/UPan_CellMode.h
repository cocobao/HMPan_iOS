//
//  UPan_CellMode.h
//  pcKan
//
//  Created by admin on 2017/3/6.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_File.h"

#define NOR_CELL_HEIGHT MarginW(35)
#define COMMON_CELL @"CommonCell"

@interface UPan_CellMode : NSObject
@property (nonatomic, assign) CGRect F_Icon;
@property (nonatomic, assign) CGRect F_FileName;
@property (nonatomic, assign) CGRect F_CreateDate;
@property (nonatomic, assign) CGRect F_Line;
@property (nonatomic, assign) CGRect F_Persent;
@property (nonatomic, assign) CGFloat cell_height;
@property (nonatomic, assign) BOOL isCommon;


-(void)setupModel:(UPan_File *)file;
@end
