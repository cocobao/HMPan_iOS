//
//  pssLocalViewController.m
//  pinut
//
//  Created by admin on 2017/1/19.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssLocalViewController.h"
#import "pssPCFileViewController.h"
#import "pssLocalFoldViewController.h"

@interface pssLocalViewController ()
@property (nonatomic, strong) NSArray *mArrTitle;
@end

@implementation pssLocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mArrTitle = @[@"看电脑里的东西", @"看本地的东西"];
}

-(NSInteger)eh_numberOfRowsInSection:(NSInteger)section
{
    return _mArrTitle.count;
}

-(CGFloat)eh_cellHeightAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(pSSBaseTableViewCell *)eh_cellAtIndexPath:(NSIndexPath *)indexPath
{
    pSSBaseTableViewCell *cell = [pSSBaseTableViewCell cellWithTableView:self.tableView];
    cell.textLabel.text = _mArrTitle[indexPath.row];
    return cell;
}

-(void)eh_didSelectCellAtIndexPath:(NSIndexPath *)indexPath cell:(pSSBaseTableViewCell *)cell
{
    if (indexPath.row == 0) {
        pssPCFileViewController *vc = [[pssPCFileViewController alloc] init];
        [self pushVc:vc];
    }else if (indexPath.row == 1){
        pssLocalFoldViewController *vc = [[pssLocalFoldViewController alloc] init];
        [self pushVc:vc];
    }
}
@end
