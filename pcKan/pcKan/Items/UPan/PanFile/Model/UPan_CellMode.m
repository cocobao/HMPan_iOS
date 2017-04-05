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
    CGFloat width = MarginW(35);
    CGFloat height = MarginW(30);
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

    [self setIcon:file];
}

//设置文件图标
-(void)setIcon:(UPan_File *)file
{
    UIImage *image = nil;
    switch (file.fileType) {
        case UPan_FT_Dir:
            image = [UIImage imageNamed:@"fold"];
            break;
        case UPan_FT_Psd:
            image = [UIImage imageNamed:@"icon_psd"];
            break;
        case UPan_FT_Zip:
        case UPan_FT_Rar:
            image = [UIImage imageNamed:@"icon_compress"];
            break;
        case UPan_FT_Pdf:
            image = [UIImage imageNamed:@"icon_pdf"];
            break;
        case UPan_FT_Word:
            image = [UIImage imageNamed:@"icon_word"];
            break;
        case UPan_FT_Ppt:
            image = [UIImage imageNamed:@"UPan_FT_Ppt"];
            break;
        case UPan_FT_Xls:
            image = [UIImage imageNamed:@"icon_xls"];
            break;
        case UPan_FT_Xml:
            image = [UIImage imageNamed:@"icon_xml"];
            break;
        case UPan_FT_Html:
            image = [UIImage imageNamed:@"icon_html"];
            break;
        case UPan_FT_Img:
            image = [pSSCommodMethod imageShotcutOfPath:file.filePath w:_F_Icon.size.width h:_F_Icon.size.height];
            break;
        case UPan_FT_Mov:
        {
            NSURL *url = [NSURL fileURLWithPath:file.filePath];
            UIImage *imageTmp = [pSSCommodMethod thumbnailImageForVideo:url];
            if (imageTmp != nil) {
                image = [pSSCommodMethod imageShotcutOfImage:imageTmp w:_F_Icon.size.width h:_F_Icon.size.height];
            }
        }
            break;
        case UPan_FT_Mus:
        {
            NSURL *url = [NSURL fileURLWithPath:file.filePath];
            image = [pSSCommodMethod musicImageWithMusicURL:url];
        }
            break;
        default:
            break;
    }

    file.mIcon = image;
}
@end
