//
//  pSSAlbumViewController.m
//  picSimpleSend
//
//  Created by admin on 2016/10/9.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSAlbumViewController.h"
#import "pSSAlbumAsset.h"
#import "pSSAlbumTableViewCell.h"
#import "pSSAlbumDetailViewController.h"

@interface pSSAlbumViewController ()
@property (nonatomic,strong) NSArray *mArrayDataSource;
@end

@implementation pSSAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"手机相册";
    [self loadData];
}

-(void)loadData
{
    if (![pSSCommodMethod sysPhotoLibraryIsAuthok]) {
        return;
    }
    
    WeakSelf(weakSelf);
    [[pSSAlbumAsset shareInstance] setupAlbumGroups:^(NSMutableArray *groups) {
        weakSelf.mArrayDataSource = groups;
        [weakSelf.tableView reloadData];
    }];
}

-(NSArray *)mArrayDataSource
{
    if (!_mArrayDataSource) {
        NSArray *arr = [NSArray array];
        _mArrayDataSource = arr;
    }
    return _mArrayDataSource;
}

-(NSInteger)eh_numberOfSections
{
    return 1;
}

-(NSInteger)eh_numberOfRowsInSection:(NSInteger)section
{
    return self.mArrayDataSource.count;
}

-(CGFloat)eh_cellHeightAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

-(UIEdgeInsets)eh_sepEdgeInsetsAtIndexPath:(NSIndexPath *)indexPath
{
    return UIEdgeInsetsMake(0, 10, 0, 0);
}

-(pSSBaseTableViewCell *)eh_cellAtIndexPath:(NSIndexPath *)indexPath
{
    pSSAlbumTableViewCell *cell = [pSSAlbumTableViewCell cellWithTableView:self.tableView];
    cell.mAssetGroup = self.mArrayDataSource[indexPath.row];
    return cell;
}

-(void)eh_didSelectCellAtIndexPath:(NSIndexPath *)indexPath cell:(pSSAlbumTableViewCell *)cell
{
    pSSAlbumDetailViewController *vc = [[pSSAlbumDetailViewController alloc] init];
    vc.mAssetGroup = cell.mAssetGroup;
    [self pushVc:vc];
}

@end
