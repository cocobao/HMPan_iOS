//
//  pSSPictureCollectionViewCell.m
//  pcKan
//
//  Created by admin on 17/3/19.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSPictureCollectionViewCell.h"

@interface pSSPictureCollectionViewCell ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *mImageView;
@property (nonatomic, strong) UIScrollView *mScrollView;
@end

@implementation pSSPictureCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mScrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTopBarHeight);
        self.mImageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth*9/16);
        
        [self.mScrollView setMinimumZoomScale:1];
        [self.mScrollView setZoomScale:1];
        [self.mScrollView setMaximumZoomScale:100];
        
        self.mImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap =[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(tapGesAction:)];
        [self.mImageView addGestureRecognizer:tap];
    }
    return self;
}

-(void)setMAssetModel:(pSSAlbumModel *)mAssetModel
{
    _mAssetModel = mAssetModel;
    [self setImage];
}

-(void)setImage
{
    //获取资源图片的详细资源信息
    ALAssetRepresentation* representation = [_mAssetModel.asset defaultRepresentation];
    
    //获取资源图片的名字
//    NSString* filename = [representation filename];
    
    //获取图片生成时间
//    NSDate* pictureDate = [_mAssetModel.asset valueForProperty:ALAssetPropertyDate];
//    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
//    formatter.dateFormat = @"- yyyy-MM-dd HH:mm:ss -";
//    formatter.timeZone = [NSTimeZone localTimeZone];//要换成本地的时区，才能获得正确的时间
//    NSString * pictureTime = [formatter stringFromDate:pictureDate];
    
    //获取资源图片的高清图
    CGImageRef cgImage = [representation fullResolutionImage];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    self.mImageView.image = image;
    
    //获取图片大小
//    NSInteger cup = [pSSCommodMethod imageDataSize:image];
//    NSString *fileSize = [pSSCommodMethod exchangeSize:(CGFloat)cup];
    
//    self.mDateLabel.text = [NSString stringWithFormat:@"%@ %@ -", pictureTime, fileSize];
    
    //获取资源图片的长宽
    CGSize dimension = [representation dimensions];
    CGRect frame = _mImageView.frame;
    
    //宽图
    if (dimension.width > dimension.height) {
        //图宽超过屏幕宽度,进行缩放显示
        if (dimension.width > kScreenWidth) {
            frame.size.width = kScreenWidth;
            frame.size.height = dimension.height*kScreenWidth/dimension.width;
        }else{
            frame.size.width = dimension.width;
            frame.size.height = dimension.height;
        }
        _mImageView.frame = frame;
        self.mImageView.center = CGPointMake(kScreenWidth/2, kScreenHeight/2-kTopBarHeight);
    }else{
        //长图
        CGFloat maxHeight = kScreenHeight-kTopBarHeight-30;
        //图高超过屏幕高度,进行缩放显示
        if (dimension.height > maxHeight) {
            frame.size.height = maxHeight;
            frame.size.width = dimension.width*maxHeight/dimension.height;
        }else{
            frame.size.width = dimension.width;
            frame.size.height = dimension.height;
        }
        _mImageView.frame = frame;
        self.mImageView.center = CGPointMake(kScreenWidth/2, maxHeight/2);
    }
}

//点击图片，回到默认缩放显示
-(void)tapGesAction:(UIGestureRecognizer*)gestureRecognizer
{
    if (self.mScrollView.zoomScale == 1) {
        return;
    }
    float newscale=0.2*1.5;
    CGRect zoomRect = [self zoomRectForScale:newscale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self.mScrollView zoomToRect:zoomRect animated:YES];
}

//照片比例缩放
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    // the zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self.mScrollView frame].size.height / scale;
    zoomRect.size.width  = [self.mScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    // zoomRect.origin.x=center.x;
    // zoomRect.origin.y=center.y;
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mImageView;
}

-(UIScrollView *)mScrollView
{
    if (!_mScrollView) {
        UIScrollView *view = [[UIScrollView alloc] init];
        view.delegate = self;
        [self.contentView addSubview:view];
        _mScrollView = view;
    }
    return _mScrollView;
}

-(UIImageView *)mImageView
{
    if (!_mImageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        _mImageView = imageView;
    }
    return _mImageView;
}
@end
