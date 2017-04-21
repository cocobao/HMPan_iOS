//
//  pSSAlbumTableViewCell.m
//  picSimpleSend
//
//  Created by admin on 2016/10/10.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSAlbumTableViewCell.h"

@interface pSSAlbumTableViewCell ()
@property (nonatomic, strong) UIImageView *mImageView;
@property (nonatomic, strong) UILabel *mLabel;
@end

@implementation pSSAlbumTableViewCell

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.mImageView.frame = CGRectMake(10, 0, CELL_HEIGHT-20, CELL_HEIGHT-20);
    
    CGFloat minX = CGRectGetMaxX(_mImageView.frame)+10;
    self.mLabel.frame = CGRectMake(minX, 0, kScreenWidth-minX-10, 30);
    
    self.mImageView.center = CGPointMake(_mImageView.center.x, CELL_HEIGHT/2);
    self.mLabel.center = CGPointMake(_mLabel.center.x, _mImageView.center.y);
}

-(void)setMAssetGroup:(ALAssetsGroup *)mAssetGroup
{
    if (mAssetGroup == nil) {
        return;
    }
    
    _mAssetGroup = mAssetGroup;
    
    //显示封面
    self.mImageView.image = [UIImage imageWithCGImage:mAssetGroup.posterImage];
    [self setupGroupTitle];
}

-(void)setupGroupTitle
{
    NSDictionary *groupTitleAttribute = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                          NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    NSDictionary *numberOfAssetsAttribute = @{NSForegroundColorAttributeName:[UIColor grayColor],
                                              NSFontAttributeName:[UIFont systemFontOfSize:17]};
    NSString *groupTitle = [_mAssetGroup valueForProperty:ALAssetsGroupPropertyName];
    if ([groupTitle isEqualToString:@"Camera Roll"]) {
        groupTitle = @"相机胶卷";
    }
    long numberOfAssets = _mAssetGroup.numberOfAssets;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@(%ld)",groupTitle,numberOfAssets] attributes:numberOfAssetsAttribute];
    [attributedString addAttributes:groupTitleAttribute range:NSMakeRange(0, groupTitle.length)];
    [self.mLabel setAttributedText:attributedString];
}

-(UIImageView *)mImageView
{
    if (!_mImageView) {
        UIImageView *view = [[UIImageView alloc] init];
        [self.contentView addSubview:view];
        _mImageView = view;
    }
    return _mImageView;
}

-(UILabel *)mLabel
{
    if (!_mLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = kFont(16);
        label.textColor = Color_5a5a5a;
        [self.contentView addSubview:label];
        _mLabel = label;
    }
    return _mLabel;
}
@end
