//
//  UPan_CellMode.m
//  pcKan
//
//  Created by admin on 2017/3/6.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_CellMode.h"

@implementation UPan_CellMode
-(void)setupModel:(UPan_File *)file
{
    //图标
    CGFloat minX = MarginW(16);
    CGFloat minY = 5;
    CGFloat width = ICON_WIDTH;
    CGFloat height = ICON_WIDTH;
    _F_Icon = CGRectMake(minX, minY, width, height);
    
    //文件名
    minX = CGRectGetMaxX(_F_Icon)+5;
    minY = 5;
    CGFloat maxWidth = kScreenWidth-minX-MarginW(80);
    CGFloat maxHeight = kViewHeight;
    CGSize size = MB_MULTILINE_TEXTSIZE(file.fileName, kFont(15), CGSizeMake(maxWidth, maxHeight), 0);
    if (size.height > 20) {
        _isCommon = NO;
    }else{
        _isCommon = YES;
    }
    height = size.height;
    width = maxWidth;
    _F_FileName = CGRectMake(minX, minY, width, height);
    
    //时间
    minY = CGRectGetMaxY(_F_FileName)+5;
    width = maxWidth-50;
    height = 18;
    _F_CreateDate = CGRectMake(minX, minY, width, height);
    
    //百分比
    minX = CGRectGetMaxX(_F_CreateDate);
    width = MarginW(100);
    _F_Persent = CGRectMake(minX, minY, width, height);
    
    //cell高度
    _cell_height = 5 + CGRectGetMaxY(_F_CreateDate)+10;
    
    //底部线条
    minX = 0;
    minY = _cell_height-3;
    width = kScreenWidth;
    height = 0.5;
    _F_Line = CGRectMake(minX, minY, width, height);
}
@end
