//
//  pSSAlbumDetailCollectionViewCell.m
//  picSimpleSend
//
//  Created by admin on 2016/10/11.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSAlbumDetailCollectionViewCell.h"

@interface pSSAlbumDetailCollectionViewCell ()
@property (nonatomic, strong) UIImageView *mImageView;
@property (nonatomic, strong) UIImageView *mSelectIcon;
@end

@implementation pSSAlbumDetailCollectionViewCell
-(void)setMMdel:(pSSAlbumModel *)mMdel
{
    if (mMdel == nil) {
        return;
    }
    _mMdel = mMdel;
    
    UIImage *image = [UIImage imageWithCGImage:mMdel.asset.aspectRatioThumbnail];
    image = [UIImage imageWithCGImage:[image CGImage] scale:2 orientation:image.imageOrientation];
    
    self.mImageView.backgroundColor = [UIColor colorWithPatternImage:image];
}

-(void)isSelectState:(BOOL)n
{
    if (n) {
        self.mSelectIcon.hidden = NO;
        _isSelect = NO;
    }else{
        self.mSelectIcon.hidden = YES;
        [self.mSelectIcon setImage:[UIImage imageNamed:@"choose"]];
    }
}

-(void)setIsSelect:(BOOL)isSelect
{
    _isSelect = isSelect;
    if (isSelect) {
        [self.mSelectIcon setImage:[UIImage imageNamed:@"choose-up"]];
    }else{
        [self.mSelectIcon setImage:[UIImage imageNamed:@"choose"]];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.mImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    CGFloat minX = self.bounds.size.width - 30;
    CGFloat minY = self.bounds.size.height - 30;
    self.mSelectIcon.frame = CGRectMake(minX, minY, MarginW(25), MarginH(25));
}

-(UIImageView *)mSelectIcon
{
    if (!_mSelectIcon) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        _mSelectIcon = imageView;
    }
    return _mSelectIcon;
}

-(UIImageView *)mImageView
{
    if (!_mImageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _mImageView = imageView;
    }

    return _mImageView;
}



@end
