//
//  pssMineViewController.m
//  ofoBike
//
//  Created by admin on 2016/12/19.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pssMineViewController.h"
#import "pssLocalFoldViewController.h"
#import "pSSURLVideoViewController.h"
#import "pSSHlsWebViewController.h"
#import "pSSLiveViewController.h"

@interface pssMineViewController ()
@property (nonatomic, strong) NSArray *mArrTitles;
@end

@implementation pssMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mArrTitles = @[@"签到", @"本地视频", @"远程视频", @"HLS", @"直播"];
}

-(CGFloat)eh_cellHeightAtIndexPath:(NSIndexPath *)indexPath
{
    return MarginH(50);
}

-(NSInteger)eh_numberOfRowsInSection:(NSInteger)section
{
    return _mArrTitles.count;
}

-(pSSBaseTableViewCell *)eh_cellAtIndexPath:(NSIndexPath *)indexPath
{
    pSSBaseTableViewCell *cell = [pSSBaseTableViewCell cellWithTableView:self.tableView];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = _mArrTitles[indexPath.row];
    return cell;
}

-(void)eh_didSelectCellAtIndexPath:(NSIndexPath *)indexPath cell:(pSSBaseTableViewCell *)cell
{
    if (indexPath.row == 0) {

    }else if (indexPath.row == 1){
        pssLocalFoldViewController *vc = [[pssLocalFoldViewController alloc] init];
        [self pushVc:vc];
    }else if (indexPath.row == 2){
        pSSURLVideoViewController *vc = [[pSSURLVideoViewController alloc] init];
        [self pushVc:vc];
    }else if (indexPath.row == 3){
        pSSHlsWebViewController *vc = [[pSSHlsWebViewController alloc] init];
        [self pushVc:vc];
    }else if (indexPath.row == 4){
        pSSLiveViewController *vc = [[pSSLiveViewController alloc] init];
        [self pushVc:vc];
    }
}
@end
