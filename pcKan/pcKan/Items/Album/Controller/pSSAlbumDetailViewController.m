//
//  pSSAlbumDetailViewController.m
//  picSimpleSend
//
//  Created by admin on 2016/10/11.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSAlbumDetailViewController.h"
#import "pSSAlbumDetailCollectionView.h"
#import "pSSAlbumAsset.h"
#import "pSSPictureViewController.h"
#import "XLPhotoBrowser.h"

@interface pSSAlbumDetailViewController ()<AlbumDetailCollectionViewDelegate, XLPhotoBrowserDatasource>
@property (nonatomic, strong) pSSAlbumDetailCollectionView *mCollectionView;
@property (nonatomic, strong) NSMutableArray *mArrayDataSource;
@end

@implementation pSSAlbumDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.mCollectionView];
    [self loadData];
}

-(void)setMAssetGroup:(ALAssetsGroup *)mAssetGroup
{
    _mAssetGroup = mAssetGroup;
    
    //设置相册页面的标题
    NSString *groupTitle = [mAssetGroup valueForProperty:ALAssetsGroupPropertyName];
    if ([groupTitle isEqualToString:@"Camera Roll"]) {
        groupTitle = @"相机胶卷";
    }
    self.title = groupTitle;
}

//加载数据
-(void)loadData
{
    //是否有访问相册权限
    if (![pSSCommodMethod sysPhotoLibraryIsAuthok]) {
        return;
    }
    
    //加载相册资源
    WeakSelf(weakSelf);
    [[pSSAlbumAsset shareInstance] setupAlbumAssets:_mAssetGroup withAssets:^(NSMutableArray *assets) {
        weakSelf.mArrayDataSource = assets;
        [weakSelf.mCollectionView reloadData];
    }];
}

-(pSSAlbumDetailCollectionView *)mCollectionView
{
    if (!_mCollectionView) {
        pSSAlbumDetailCollectionView *collection = [[pSSAlbumDetailCollectionView alloc] initWithFrame:CGRectMake(0, 1, kScreenWidth, kScreenHeight-NAVBAR_H-2)];
        collection.m_delegate = self;
        _mCollectionView = collection;
    }
    return _mCollectionView;
}

-(NSArray *)AlbumDetail_DataSource
{
    return self.mArrayDataSource;
}

-(void)AlbumDetail_didSelectionWithIndexPath:(NSIndexPath *)indexPath
{
    //点击查看某一张照片, 跳转到查看照片的页面
//    pSSPictureViewController *vc = [[pSSPictureViewController alloc] initWithAssetGroup:self.mArrayDataSource
//                                                                                atIndex:indexPath.item];
//    [self pushVc:vc];
//    pSSAlbumModel *assetModel = [self.mArrayDataSource objectAtIndex:indexPath.item];
//    ALAssetRepresentation* representation = [assetModel.asset defaultRepresentation];
//    //获取资源图片的高清图
//    CGImageRef cgImage = [representation fullResolutionImage];
//    UIImage *image = [UIImage imageWithCGImage:cgImage];
//    [XLPhotoBrowser showPhotoBrowserWithImages:@[image] currentImageIndex:0];
    
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:indexPath.item imageCount:self.mArrayDataSource.count datasource:self];
    browser.pageControlStyle = XLPhotoBrowserPageControlStyleClassic;
}

#pragma mark    -   XLPhotoBrowserDatasource

- (UIImage *)photoBrowser:(XLPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    pSSAlbumModel *assetModel = [self.mArrayDataSource objectAtIndex:index];
    ALAssetRepresentation* representation = [assetModel.asset defaultRepresentation];
    //获取资源图片的高清图
    CGImageRef cgImage = [representation fullResolutionImage];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    return image;
}

-(NSArray *)mArrayDataSource
{
    if (!_mArrayDataSource) {
        NSMutableArray *arr = [NSMutableArray array];
        _mArrayDataSource = arr;
    }
    return _mArrayDataSource;
}
@end
