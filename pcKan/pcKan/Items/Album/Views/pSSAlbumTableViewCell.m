//
//  pSSAlbumTableViewCell.m
//  picSimpleSend
//
//  Created by admin on 2016/10/10.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSAlbumTableViewCell.h"

@implementation pSSAlbumTableViewCell

-(void)setMAssetGroup:(ALAssetsGroup *)mAssetGroup
{
    if (mAssetGroup == nil) {
        return;
    }
    
    _mAssetGroup = mAssetGroup;
    
    //显示封面
    self.imageView.image = [UIImage imageWithCGImage:mAssetGroup.posterImage];
    [self setupGroupTitle];
}

-(void)setupGroupTitle
{
    NSDictionary *groupTitleAttribute = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                          NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    NSDictionary *numberOfAssetsAttribute = @{NSForegroundColorAttributeName:[UIColor grayColor],
                                              NSFontAttributeName:[UIFont systemFontOfSize:17]};
    NSString *groupTitle = [_mAssetGroup valueForProperty:ALAssetsGroupPropertyName];
    long numberOfAssets = _mAssetGroup.numberOfAssets;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@(%ld)",groupTitle,numberOfAssets] attributes:numberOfAssetsAttribute];
    [attributedString addAttributes:groupTitleAttribute range:NSMakeRange(0, groupTitle.length)];
    [self.textLabel setAttributedText:attributedString];
    
}
@end
