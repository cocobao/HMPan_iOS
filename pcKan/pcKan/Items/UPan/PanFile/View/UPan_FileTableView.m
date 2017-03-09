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
@property (nonatomic, strong) NSMutableDictionary *dictCellMode;
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
        _dictCellMode = [NSMutableDictionary dictionary];
    }
    return self;
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
        UPan_File *file = [[self.m_delegate UPanFileDataSource] objectAtIndex:indexPath.row];
        UPan_CellMode *mode = nil;
        if (_dictCellMode[file.fileName]) {
            mode = _dictCellMode[@(file.fileId)];
        }else{
            mode = [[UPan_CellMode alloc] init];
            [mode setupModel:file];
            if (mode.isCommon) {
                if (!_dictCellMode[COMMON_CELL]){
                    _dictCellMode[COMMON_CELL] = mode;
                }
            }else{
                _dictCellMode[@(file.fileId)] = mode;
            }
        }
        
        return mode.cell_height;
    }
    
    return NOR_CELL_HEIGHT;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UPan_FileTableViewCell *cell = [UPan_FileTableViewCell cellWithTableView:self];
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(UPanFileDataSource)]) {
        UPan_File *file = [[self.m_delegate UPanFileDataSource] objectAtIndex:indexPath.row];
        UPan_CellMode *mode = _dictCellMode[@(file.fileId)];
        if (!mode) {
            mode = _dictCellMode[COMMON_CELL];
        }
        [cell setMMode:mode file:file];
        
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor redColor]]];
        cell.rightSwipeSettings.transition = MGSwipeStateSwipingRightToLeft;
        cell.delegate = self;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(UPanFileDataSource)]) {
        UPan_File *file = [[self.m_delegate UPanFileDataSource] objectAtIndex:indexPath.row];
        if ([self.m_delegate respondsToSelector:@selector(didSelectFile:)]) {
            [self.m_delegate didSelectFile:file];
        }
    }
}

//点击删除
-(BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    //必须删除数据源
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(didDeleteFile:)]) {
        UPan_FileTableViewCell *fileCell = (UPan_FileTableViewCell *)cell;
        [self.m_delegate didDeleteFile:fileCell.mFile];
    }
    
    //删除项
    NSIndexPath * path = [self indexPathForCell:cell];
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
