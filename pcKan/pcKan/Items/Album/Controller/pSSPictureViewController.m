//
//  pSSPictureViewController.m
//  pcKan
//
//  Created by admin on 17/3/16.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSPictureViewController.h"
#import "pssLinkObj+Api.h"
#import "UPan_FileExchanger.h"
#import "UIAlertView+RWBlock.h"
#import "pSSAlbumModel.h"
#import "pSSPictureCollectionView.h"

@interface pSSPictureViewController ()<PictureCollectionViewDelegate>
{
    NSInteger _atIndex;
}
@property (nonatomic, strong) pSSPictureCollectionView *mCollectionView;
@property (nonatomic, strong) UILabel *mDateLabel;
@property (nonatomic, strong) UIButton *mRightBtn;
@property (nonatomic, weak) NSArray *mArrAssetSource;
@end

@implementation pSSPictureViewController
-(instancetype)initWithAssetGroup:(NSArray *)assetGroup atIndex:(NSInteger)atIndex
{
    if (self = [super init]) {
        _atIndex = atIndex;
        _mArrAssetSource = assetGroup;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mDateLabel.frame = CGRectMake(0, kScreenHeight - kTopBarHeight - 30, kScreenWidth, 30);
    self.mRightBtn.frame = CGRectMake(0, 0, 40, 40);
    [self.view addSubview:self.mCollectionView];
    [self.mCollectionView setContentOffset:CGPointMake(_atIndex*kScreenWidth, 0)];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.mRightBtn];
    self.navigationItem.rightBarButtonItem = leftItem;
}

-(void)rightBtnAction:(UIButton *)sender
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
//    WeakSelf(weakSelf);
    [view setCompleteBlock:^(UIAlertView *alertView, NSInteger btnIndex) {
        if (btnIndex == 1) {
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                [weakSelf applyRecvFile];
//            });
        }
    }];
    [view show];
}

-(NSArray *)PictureCollection_DataSource;
{
    return self.mArrAssetSource;
}

-(void)nowDisplayCellIndex:(NSIndexPath *)indexPath
{
    WeakSelf(weakSelf);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        pSSAlbumModel *mAssetModel = [weakSelf.mArrAssetSource objectAtIndex:indexPath.item];
        
        //获取资源图片的详细资源信息
        ALAssetRepresentation* representation = [mAssetModel.asset defaultRepresentation];
        
        //获取资源图片的名字
        NSString* filename = [representation filename];
        
        //获取图片生成时间
        NSDate* pictureDate = [mAssetModel.asset valueForProperty:ALAssetPropertyDate];
        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"- yyyy-MM-dd HH:mm:ss -";
        formatter.timeZone = [NSTimeZone localTimeZone];//要换成本地的时区，才能获得正确的时间
        NSString * pictureTime = [formatter stringFromDate:pictureDate];
        
        CGImageRef cgImage = [representation fullResolutionImage];
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        
        //获取图片大小
        NSInteger cup = [pSSCommodMethod imageDataSize:image];
        NSString *fileSize = [pSSCommodMethod exchangeSize:(CGFloat)cup];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.title = filename;
            weakSelf.mDateLabel.text = [NSString stringWithFormat:@"%@ %@ -", pictureTime, fileSize];
        });
    });
}

////请求pc端接收文件
//-(void)applyRecvFile:(pSSAlbumModel *)modelData
//{
//    //获取资源图片的详细资源信息
//    ALAssetRepresentation* representation = [modelData.asset defaultRepresentation];
//    
//    NSString* filename = [representation filename];
//    
//    //UIImage图片转为NSDate数据
//    NSData *imageData = UIImagePNGRepresentation(self.mImageview.image);
//
//    [pssLink NetApi_ApplyRecvFile:@{ptl_fileName:filename,ptl_fileSize:@(imageData.length)}
//                            block:^(NSDictionary *message, NSError *error) {
//        if (error) {
//            return;
//        }
//        NSInteger code = [message[ptl_status] integerValue];
//        if (code != _SUCCESS_CODE) {
//            NSLog(@"%@", message);
//            return;
//        }
//        NSInteger fileId = [message[ptl_fileId] integerValue];
//        
//        [FileExchanger addSendingFileData:imageData fileId:fileId fileName:filename];
//    }];
//}

-(pSSPictureCollectionView *)mCollectionView
{
    if (!_mCollectionView) {
        pSSPictureCollectionView *view = [[pSSPictureCollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAVBAR_H-30)];
        view.m_delegate = self;
        _mCollectionView = view;
    }
    return _mCollectionView;
}

-(UILabel *)mDateLabel
{
    if (!_mDateLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = kFont(15);
        label.textColor = Color_5a5a5a;
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        _mDateLabel = label;
    }
    return _mDateLabel;
}

-(UIButton *)mRightBtn
{
    if (!_mRightBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"发送" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        _mRightBtn = btn;
    }
    return _mRightBtn;
}

@end
