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

@interface pSSAlbumDetailViewController ()<AlbumDetailCollectionViewDelegate>
@property (nonatomic, strong) pSSAlbumDetailCollectionView *mCollectionView;
@property (nonatomic, strong) NSMutableArray *mArrayDataSource;
@end

@implementation pSSAlbumDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.mCollectionView];
    [self loadData];
}

-(void)loadData
{
    if (![pSSCommodMethod sysPhotoLibraryIsAuthok]) {
        return;
    }
    
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
    pSSAlbumModel *model = [_mArrayDataSource objectAtIndex:indexPath.item];
    pSSPictureViewController *vc = [[pSSPictureViewController alloc] initWithAsset:model];
    [self pushVc:vc];
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
