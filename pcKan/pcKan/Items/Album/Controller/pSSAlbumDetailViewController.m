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
#import "XLPhotoBrowser.h"
#import "pssLinkObj+Api.h"
#import "UIAlertView+RWBlock.h"
#import "UPan_FileExchanger.h"
#import "pSSControlBarView.h"

@interface pSSAlbumDetailViewController ()<AlbumDetailCollectionViewDelegate, XLPhotoBrowserDatasource, XLPhotoBrowserDelegate>
@property (nonatomic, strong) pSSAlbumDetailCollectionView *mCollectionView;
@property (nonatomic, strong) NSMutableArray *mArrayDataSource;
@property (nonatomic, strong) UIButton *mRightBtn;
@property (nonatomic, weak) pSSControlBarView *mCtrlBarView;
@end

@implementation pSSAlbumDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.mCollectionView];
    [self loadData];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.mRightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
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

-(void)rightBtnAction:(UIButton *)sender
{
    if (sender.tag == 0) {
        sender.tag = 1;
        [sender setTitle:@"取消" forState:UIControlStateNormal];
        
        self.mCollectionView.isSelectState = !self.mCollectionView.isSelectState;
        
        pSSControlBarView *ctrlBar = [[pSSControlBarView alloc] init];
        [self.view addSubview:ctrlBar];
        _mCtrlBarView = ctrlBar;
        CGRect frame = ctrlBar.frame;
        frame.origin.y = kScreenHeight - 50 - NAVBAR_H;
        [UIView animateWithDuration:0.3 animations:^{
            ctrlBar.frame = frame;
        }];
        
        CGRect frameCollection = self.mCollectionView.frame;
        frameCollection.size.height -= 50;
        [UIView animateWithDuration:0.3 animations:^{
            self.mCollectionView.frame = frameCollection;
        }];
    }else{
        sender.tag = 0;
        [sender setTitle:@"选择" forState:UIControlStateNormal];
        
        if (_mCtrlBarView) {
            [_mCtrlBarView removeFromSuperview];
        }
        
        CGRect frameCollection = self.mCollectionView.frame;
        frameCollection.size.height += 50;
        self.mCollectionView.frame = frameCollection;
    }
}

#pragma mark - XLPhotoBrowserDatasource
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
    [browser setActionSheetWithTitle:@"" delegate:self cancelButtonTitle:@"取消" deleteButtonTitle:nil otherButtonTitles:@"发送到电脑", @"照片信息", nil];
    browser.pageControlStyle = XLPhotoBrowserPageControlStyleClassic;
}

-(void)sendPictureActionWithIndex:(NSInteger)index
{
    //是否连接正常
    if ([pssLink tcpLinkStatus] != tcpConnect_ConnectOk) {
        [self addHub:@"请先连接电脑客户端" hide:YES];
        return;
    }
    
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示"
                                                   message:[NSString stringWithFormat:@"发送照片:%@ 到电脑", self.title]
                                                  delegate:nil
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"确定", nil];
    WeakSelf(weakSelf);
    [view setCompleteBlock:^(UIAlertView *alertView, NSInteger btnIndex) {
        if (btnIndex == 1) {
            pSSAlbumModel *assetModel = [weakSelf.mArrayDataSource objectAtIndex:index];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [weakSelf applyRecvFile:assetModel];
            });
        }
    }];
    [view show];
}

//请求pc端接收文件
-(void)applyRecvFile:(pSSAlbumModel *)modelData
{
    //获取资源图片的详细资源信息
    ALAssetRepresentation* representation = [modelData.asset defaultRepresentation];

    NSString* filename = [representation filename];

    //UIImage图片转为NSDate数据
    CGImageRef cgImage = [representation fullResolutionImage];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    NSData *imageData = UIImagePNGRepresentation(image);

    [pssLink NetApi_ApplyRecvFile:@{ptl_fileName:filename,ptl_fileSize:@(imageData.length)}
                            block:^(NSDictionary *message, NSError *error) {
        if (error) {
            return;
        }
        NSInteger code = [message[ptl_status] integerValue];
        if (code != _SUCCESS_CODE) {
            NSLog(@"%@", message);
            return;
        }
        NSInteger fileId = [message[ptl_fileId] integerValue];

        [FileExchanger addSendingFileData:imageData fileId:fileId fileName:filename];
    }];
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

- (void)photoBrowser:(XLPhotoBrowser *)browser clickActionSheetIndex:(NSInteger)actionSheetindex currentImageIndex:(NSInteger)currentImageIndex
{
    if (actionSheetindex == 0) {
        [self sendPictureActionWithIndex:currentImageIndex];
    }else if (actionSheetindex == 1){
        
    }
}

-(NSArray *)mArrayDataSource
{
    if (!_mArrayDataSource) {
        NSMutableArray *arr = [NSMutableArray array];
        _mArrayDataSource = arr;
    }
    return _mArrayDataSource;
}

-(UIButton *)mRightBtn
{
    if (!_mRightBtn) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [btn setTitle:@"选择" forState:UIControlStateNormal];
        btn.titleLabel.font = kFont(15);
        [btn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _mRightBtn = btn;
    }
    return _mRightBtn;
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

@end
