//
//  pSSBaseTableViewController.m
//  picSimpleSend
//
//  Created by admin on 2016/10/10.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSBaseTableViewController.h"
#import "pSSBaseTableHeaderFooterView.h"
#import "UIScrollView+MJRefresh.h"
#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"

@interface pSSBaseTableViewController ()
@property (nonatomic, copy) void (^headerRereshingBlock)();
@property (nonatomic, copy) void (^footerRereshingBlock)();
@end

@implementation pSSBaseTableViewController

-(instancetype)init
{
    self = [super init];
    if (self) {
        _tableViewStyle = UITableViewStylePlain;
        _needCellSepLine = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

-(UITableView *)tableView
{
    if (!_tableView) {
        CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:_tableViewStyle];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorColor = Color_Line;
        [self.view addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}

/** 需要系统分割线*/
- (void)setNeedCellSepLine:(BOOL)needCellSepLine {
    _needCellSepLine = needCellSepLine;
    self.tableView.separatorStyle = needCellSepLine ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
}

/** 表视图偏移*/
- (void)setTableEdgeInset:(UIEdgeInsets)tableEdgeInset {
    _tableEdgeInset = tableEdgeInset;
    CGRect frame = self.tableView.frame;
    frame.origin.x += tableEdgeInset.left;
    frame.origin.x += tableEdgeInset.right;
    frame.origin.y += tableEdgeInset.top;
    frame.origin.y += tableEdgeInset.bottom;
    self.tableView.frame = frame;
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
    [self.view setNeedsLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view bringSubviewToFront:self.tableView];
}

#pragma mark - UITableView DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self respondsToSelector:@selector(eh_numberOfSections)]) {
        return self.eh_numberOfSections;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self respondsToSelector:@selector(eh_numberOfRowsInSection:)]) {
        return [self eh_numberOfRowsInSection:section];
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self respondsToSelector:@selector(eh_headerAtSection:)]) {
        return [self eh_headerAtSection:section];
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ([self respondsToSelector:@selector(eh_footerAtSection:)]) {
        return [self eh_footerAtSection:section];
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self respondsToSelector:@selector(eh_cellAtIndexPath:)]) {
        return [self eh_cellAtIndexPath:indexPath];
    }
    
    return [pSSBaseTableViewCell cellWithTableView:self.tableView];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self respondsToSelector:@selector(eh_didSelectCellAtIndexPath:cell:)]) {
        pSSBaseTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self eh_didSelectCellAtIndexPath:indexPath cell:cell];
    }
}

// 设置分割线偏移间距并适配
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_needCellSepLine) {
        //不设置分割线
        return;
    }
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    if ([self respondsToSelector:@selector(eh_sepEdgeInsetsAtIndexPath:)]) {
        edgeInsets = [self eh_sepEdgeInsetsAtIndexPath:indexPath];
    }
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) [tableView setSeparatorInset:edgeInsets];
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) [tableView setLayoutMargins:edgeInsets];
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) [cell setSeparatorInset:edgeInsets];
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) [cell setLayoutMargins:edgeInsets];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self respondsToSelector:@selector(eh_cellHeightAtIndexPath:)]) {
        return [self eh_cellHeightAtIndexPath:indexPath];
    }
    return tableView.rowHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self respondsToSelector:@selector(eh_heightForHeaderAtSection:)]) {
        return [self eh_heightForHeaderAtSection:section];
    }
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([self respondsToSelector:@selector(eh_heightForFooterAtSection:)]) {
        return [self eh_heightForFooterAtSection:section];
    }
    return 0.001;
}

/*顶部刷新*/
- (void)headerRereshing:(BOOL)b rereshingBlock:(void (^)())block{
    if (b) {
        [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
        _headerRereshingBlock = block;
    }
}

/*底部刷新*/
- (void)footerRereshing:(BOOL)b rereshingBlock:(void (^)())block{
    if (b) {
        [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
        _footerRereshingBlock = block;
    }
}

- (void)headerRereshing
{
    [self.tableView headerEndRefreshing];
    
    if (_headerRereshingBlock) {
        _headerRereshingBlock();
    }
}

-(void)footerRereshing{
    [self.tableView footerEndRefreshing];
    if (_footerRereshingBlock) {
        _footerRereshingBlock();
    }
}

-(NSInteger)eh_numberOfSections{return 1;}

-(NSInteger)eh_numberOfRowsInSection:(NSInteger)section{return 0;}

-(pSSBaseTableViewCell *)eh_cellAtIndexPath:(NSIndexPath *)indexPath
{
    return [pSSBaseTableViewCell cellWithTableView:self.tableView];
}

-(void)eh_didSelectCellAtIndexPath:(NSIndexPath *)indexPath cell:(pSSBaseTableViewCell *)cell{}

-(CGFloat)eh_cellHeightAtIndexPath:(NSIndexPath *)indexPath{return 0.0;}

-(UIView *)eh_headerAtSection:(NSInteger)section
{
    return [pSSBaseTableHeaderFooterView headerFooterViewWithTableView:self.tableView];
}

-(UIView *)eh_footerAtSection:(NSInteger)section
{
    return [pSSBaseTableHeaderFooterView headerFooterViewWithTableView:self.tableView];
}

-(CGFloat)eh_heightForHeaderAtSection:(NSInteger)section{return 0.00001;}

-(CGFloat)eh_heightForFooterAtSection:(NSInteger)section{return 0.00001;}

-(UIEdgeInsets)eh_sepEdgeInsetsAtIndexPath:(NSIndexPath *)indexPath{ return UIEdgeInsetsMake(0, 15, 0, 0); }
@end
