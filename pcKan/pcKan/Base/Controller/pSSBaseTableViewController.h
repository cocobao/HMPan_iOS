//
//  pSSBaseTableViewController.h
//  picSimpleSend
//
//  Created by admin on 2016/10/10.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSBaseViewController.h"
#import "pSSBaseTableViewCell.h"

@interface pSSBaseTableViewController : pSSBaseViewController<UITableViewDelegate, UITableViewDataSource>
/*tableView风格*/
@property (nonatomic, assign) UITableViewStyle tableViewStyle;

@property (nonatomic, weak) UITableView *tableView;
/** 表视图偏移*/
@property (nonatomic, assign) UIEdgeInsets tableEdgeInset;
/** 是否需要系统的cell的分割线*/
@property (nonatomic, assign) BOOL needCellSepLine;

/*delegate*/
/*分组数*/
-(NSInteger)eh_numberOfSections;
/*cell数*/
-(NSInteger)eh_numberOfRowsInSection:(NSInteger)section;
/*某行cell*/
-(pSSBaseTableViewCell *)eh_cellAtIndexPath:(NSIndexPath *)indexPath;
/*点击某行cell*/
-(void)eh_didSelectCellAtIndexPath:(NSIndexPath *)indexPath cell:(pSSBaseTableViewCell *)cell;
/*行高*/
-(CGFloat)eh_cellHeightAtIndexPath:(NSIndexPath *)indexPath;
/*组头*/
-(UIView *)eh_headerAtSection:(NSInteger)section;
/*组尾*/
-(UIView *)eh_footerAtSection:(NSInteger)section;
/*组头高度*/
-(CGFloat)eh_heightForHeaderAtSection:(NSInteger)section;
/*组尾高度*/
-(CGFloat)eh_heightForFooterAtSection:(NSInteger)section;
/*分割线偏移*/
-(UIEdgeInsets)eh_sepEdgeInsetsAtIndexPath:(NSIndexPath *)indexPath;

- (void)headerRereshing:(BOOL)b rereshingBlock:(void (^)())block;
- (void)footerRereshing:(BOOL)b rereshingBlock:(void (^)())block;
@end
