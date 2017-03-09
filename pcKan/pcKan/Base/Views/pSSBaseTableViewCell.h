//
//  pSSBaseTableViewCell.h
//  picSimpleSend
//
//  Created by admin on 2016/10/10.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface pSSBaseTableViewCell : MGSwipeTableCell
@property (nonatomic, weak) UITableView *tableView;
+(instancetype)cellWithTableView:(UITableView *)tableView;
+(instancetype)cellWithTableView:(UITableView *)tableView style:(UITableViewCellStyle)style;
+(instancetype)cellWithTableView:(UITableView *)tableView style:(UITableViewCellStyle)style indexPath:(NSIndexPath *)indexPath;
@end
