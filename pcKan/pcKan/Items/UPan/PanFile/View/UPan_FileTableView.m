//
//  UPan_FileTableView.m
//  pcKan
//
//  Created by admin on 2017/3/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_FileTableView.h"
#import "UPan_FileTableViewCell.h"
#import "UPan_CellMode.h"
#import "UIScrollView+MJRefresh.h"
#import "MJRefreshHeaderView.h"
#import "MGSwipeButton.h"

@interface UPan_FileTableView ()
<
UITableViewDelegate,
UITableViewDataSource,
MGSwipeTableCellDelegate
>
@property (nonatomic, strong) NSMutableArray *cellModes;
@property (nonatomic, copy) void (^headerRereshingBlock)();
@end

@implementation UPan_FileTableView
-(instancetype)init
{
    return [self initWithFrame:CGRectZero style:UITableViewStylePlain];
}

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.rowHeight = CELL_HEIGHT;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = Color_BackGround;
        _cellModes = [NSMutableArray array];
    }
    return self;
}

-(void)reloadData
{
    [_cellModes removeAllObjects];
    [super reloadData];
}

-(void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    //对于单独cell刷新，进行mode重新计算,因为可能有变化
    for (NSIndexPath *index in indexPaths) {
        [_cellModes removeObjectAtIndex:index.row];
        
        UPan_File *file = [[self.m_delegate UPanFileDataSource] objectAtIndex:index.row];
        UPan_CellMode *mode = [[UPan_CellMode alloc] init];
        [mode setupModel:file];
        [_cellModes insertObject:mode atIndex:index.row];
    }
    
    [super reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(UPanFileDataSource)]) {
        return [[self.m_delegate UPanFileDataSource] count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(UPanFileDataSource)]) {
        UPan_CellMode *mode = nil;
        if (_cellModes.count > indexPath.row) {
            mode = [_cellModes objectAtIndex:indexPath.row];
            return mode.cell_height;
        }
        
        UPan_File *file = [[self.m_delegate UPanFileDataSource] objectAtIndex:indexPath.row];
        mode = [[UPan_CellMode alloc] init];
        [mode setupModel:file];
        [_cellModes addObject:mode];
        
        return mode.cell_height;
    }
    
    return NOR_CELL_HEIGHT;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UPan_FileTableViewCell *cell = [UPan_FileTableViewCell cellWithTableView:self];
    cell.tableView = self;
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(UPanFileDataSource)]) {
        cell.mIndexPath = indexPath;
        
        UPan_File *file = [[self.m_delegate UPanFileDataSource] objectAtIndex:indexPath.row];
        if (_cellModes.count > indexPath.row) {
            UPan_CellMode *mode = _cellModes[indexPath.row];
            [cell setMMode:mode file:file];
        }else{
            UPan_File *file = [[self.m_delegate UPanFileDataSource] objectAtIndex:indexPath.row];
            UPan_CellMode *mode = [[UPan_CellMode alloc] init];
            [mode setupModel:file];
            [_cellModes addObject:mode];
            [cell setMMode:mode file:file];
        }

        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor redColor]]];
        cell.rightSwipeSettings.transition = MGSwipeStateSwipingRightToLeft;
        cell.delegate = self;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(UPanFileDataSource)]) {
        if ([self.m_delegate respondsToSelector:@selector(didSelectFile:)]) {
            [self.m_delegate didSelectFile:indexPath];
        }
    }
}

//点击accessoryButton处理
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(accessButtonWithIndex:)]){
        [self.m_delegate accessButtonWithIndex:indexPath];
    }
}

//点击删除
-(BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    //删除项
    NSIndexPath * path = [self indexPathForCell:cell];
    
    //必须删除数据源
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(didDeleteFile:)]) {
        UPan_FileTableViewCell *fileCell = (UPan_FileTableViewCell *)cell;
        [self.m_delegate didDeleteFile:fileCell.mFile];
        
        [_cellModes removeObjectAtIndex:path.row];
    }
    //再进行cell刷新
    [self deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    [self endUpdates];
    return YES;
}

/*顶部刷新*/
- (void)headerRereshing:(BOOL)b rereshingBlock:(void (^)())block{
    if (b) {
        [self addHeaderWithTarget:self action:@selector(headerRereshing)];
        _headerRereshingBlock = block;
    }
}

- (void)headerRereshing
{
    [self headerEndRefreshing];
    
    if (_headerRereshingBlock) {
        _headerRereshingBlock();
    }
}
@end
