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

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.mImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}

-(UIImageView *)mImageView
{
    if (!_mImageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        _mImageView = imageView;
    }

    return _mImageView;
}



@end
