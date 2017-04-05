//
//  pSSAudioListView.m
//  pcKan
//
//  Created by admin on 17/4/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSAudioListView.h"
#import "pSSAudioListCell.h"

@interface pSSAudioListView ()
<UITableViewDelegate,UITableViewDataSource>
@end

@implementation pSSAudioListView

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
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(audioDataSource)]) {
        return [self.m_delegate audioDataSource].count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    pSSAudioListCell *cell = [pSSAudioListCell cellWithTableView:self];
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(audioDataSource)]) {
        pSSAvMode *mode = [[self.m_delegate audioDataSource] objectAtIndex:indexPath.row];
        [cell setMMode:mode];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(didSelectWithIndex:)]) {
        [self.m_delegate didSelectWithIndex:indexPath.row];
    }
}
@end
