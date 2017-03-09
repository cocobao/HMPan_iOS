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
    CGFloat minX = MarginW(16);
    CGFloat minY = 5;
    CGFloat width = MarginW(35);
    CGFloat height = MarginW(30);
    _F_Icon = CGRectMake(minX, minY, width, height);
    
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
    
    minY = CGRectGetMaxY(_F_FileName)+5;
    width = maxWidth-50;
    height = 18;
    _F_CreateDate = CGRectMake(minX, minY, width, height);
    
    minX = CGRectGetMaxX(_F_CreateDate);
    width = MarginW(80);
    _F_Persent = CGRectMake(minX, minY, width, height);
    
    _cell_height = 5 + CGRectGetMaxY(_F_CreateDate)+10;
    
    minX = 0;
    minY = _cell_height-3;
    width = kScreenWidth;
    height = 0.5;
    _F_Line = CGRectMake(minX, minY, width, height);

    [self setIcon:file];
}

-(void)setIcon:(UPan_File *)file
{
    if (file.fileType == UPan_FT_Img) {
        file.mIcon = [pSSCommodMethod imageShotcutOfPath:file.filePath w:_F_Icon.size.width h:_F_Icon.size.height];
    }else if (file.fileType == UPan_FT_Mov){
        UIImage *image = [pSSCommodMethod thumbnailImageForVideo:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@", file.filePath]]];
        file.mIcon = [pSSCommodMethod imageShotcutOfImage:image w:_F_Icon.size.width h:_F_Icon.size.height];
    }
}
@end
