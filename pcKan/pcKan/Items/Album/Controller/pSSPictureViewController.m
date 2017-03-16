//
//  pSSPictureViewController.m
//  pcKan
//
//  Created by admin on 17/3/16.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSPictureViewController.h"

@interface pSSPictureViewController ()<UIScrollViewDelegate>
@property (nonatomic, weak) pSSAlbumModel *mAssetModel;
@property (nonatomic, strong) UIImageView *mImageview;
@property (nonatomic, strong) UIScrollView *mScrollView;
@end

@implementation pSSPictureViewController
-(instancetype)initWithAsset:(pSSAlbumModel *)assetModel
{
    if (self = [super init]) {
        _mAssetModel = assetModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mScrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTopBarHeight);
    self.mImageview.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth*9/16);
    
    [self setImage];
    
    [self.mScrollView setMinimumZoomScale:1];
    [self.mScrollView setZoomScale:1];
    [self.mScrollView setMaximumZoomScale:100];
    
    self.mImageview.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesAction:)];
    [self.mImageview addGestureRecognizer:tap];
}

-(void)tapGesAction:(UIGestureRecognizer*)gestureRecognizer
{
    float newscale=0.2*1.5;
    CGRect zoomRect = [self zoomRectForScale:newscale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self.mScrollView zoomToRect:zoomRect animated:YES];
}

-(void)setImage
{
    //获取资源图片的详细资源信息
    ALAssetRepresentation* representation = [_mAssetModel.asset defaultRepresentation];
    
    //获取资源图片的高清图
    CGImageRef cgImage = [representation fullResolutionImage];
    self.mImageview.image = [UIImage imageWithCGImage:cgImage];
    
    //获取资源图片的长宽
    CGSize dimension = [representation dimensions];
    CGRect frame = _mImageview.frame;
    
    //宽图
    if (dimension.width > dimension.height) {
        if (dimension.width > kScreenWidth) {
            frame.size.width = kScreenWidth;
            frame.size.height = dimension.height*kScreenWidth/dimension.width;
        }else{
            frame.size.width = dimension.width;
            frame.size.height = dimension.height;
        }
        _mImageview.frame = frame;
        self.mImageview.center = CGPointMake(kScreenWidth/2, kScreenHeight/2-kTopBarHeight);
    }else{
        //长图
        CGFloat maxHeight = kScreenHeight-kTopBarHeight;
        if (dimension.height > maxHeight) {
            frame.size.height = maxHeight;
            frame.size.width = dimension.width*maxHeight/dimension.height;
        }else{
            frame.size.width = dimension.width;
            frame.size.height = dimension.height;
        }
        _mImageview.frame = frame;
        self.mImageview.center = CGPointMake(kScreenWidth/2, (kScreenHeight-kTopBarHeight)/2);
    }
}

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
    return self.mImageview;
}

-(UIScrollView *)mScrollView
{
    if (!_mScrollView) {
        UIScrollView *view = [[UIScrollView alloc] init];
        view.delegate = self;
        [self.view addSubview:view];
        _mScrollView = view;
    }
    return _mScrollView;
}

-(UIImageView *)mImageview
{
    if (!_mImageview) {
        UIImageView *view = [[UIImageView alloc] init];
        [self.mScrollView addSubview:view];
        _mImageview = view;
    }
    return _mImageview;
}

@end
