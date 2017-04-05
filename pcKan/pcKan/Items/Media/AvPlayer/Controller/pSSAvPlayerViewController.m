//
//  pSSAvPlayerViewController.m
//  pcKan
//
//  Created by admin on 17/4/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSAvPlayerViewController.h"
#import "pSSAudioPlayerView.h"
#import "pSSAudioListView.h"

@interface pSSAvPlayerViewController ()<audioListDelegate>
@property (nonatomic, strong) pSSAudioPlayerView *mPlayerView;
@property (nonatomic, strong) pSSAudioListView *mListView;
@property (nonatomic, strong) NSMutableArray *mDataSource;
@property (nonatomic, assign) NSInteger nowPlayIndex;
@end

@implementation pSSAvPlayerViewController
-(instancetype)initWithFiles:(NSArray *)files playFile:(UPan_File *)playFile
{
    self = [super init];
    if (self) {
        _mDataSource = [NSMutableArray arrayWithCapacity:files.count];
        
        NSInteger i = 0;
        for (UPan_File *f in files) {
            pSSAvMode *mode = [[pSSAvMode alloc] initWithFile:f];
            [_mDataSource addObject:mode];
            
            if (f.fileId == playFile.fileId) {
                _nowPlayIndex = i;
            }
            i++;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mListView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAVBAR_H-CGRectGetHeight(self.mPlayerView.frame));
    
    [self.mPlayerView playWithMode:[_mDataSource objectAtIndex:_nowPlayIndex]];
}

-(void)backBtnPress
{
    [super backBtnPress];
    [self.mPlayerView releaseView];
}

-(NSArray *)audioDataSource
{
    return _mDataSource;
}

-(void)didSelectWithIndex:(NSInteger)index
{
    if (_nowPlayIndex == index) {
        return;
    }
    _nowPlayIndex = index;
    [self.mPlayerView playWithMode:[_mDataSource objectAtIndex:_nowPlayIndex]];
    
    [self.mListView reloadData];
}

-(pSSAudioListView *)mListView
{
    if (!_mListView) {
        pSSAudioListView *view = [[pSSAudioListView alloc] init];
        view.m_delegate = self;
        [self.view addSubview:view];
        _mListView = view;
    }
    return _mListView;
}

-(pSSAudioPlayerView *)mPlayerView
{
    if (!_mPlayerView) {
        CGFloat height = 150;
        CGRect frame = CGRectMake(-0.5, kScreenHeight-NAVBAR_H-height, kScreenWidth+1, height);
        pSSAudioPlayerView *view = [[pSSAudioPlayerView alloc] initWithFrame:frame];
        [self.view addSubview:view];
        _mPlayerView = view;
        
        WeakSelf(weakSelf);
        view.b_NextPlay = ^(){
            NSInteger index = weakSelf.nowPlayIndex;
            if (index == weakSelf.mDataSource.count - 1) {
                index = 0;
            }else{
                index++;
            }
            [weakSelf didSelectWithIndex:index];
        };
        view.b_previousPlay = ^(){
            NSInteger index = weakSelf.nowPlayIndex;
            if (index == 0) {
                index = weakSelf.mDataSource.count - 1;
            }else{
                index--;
            }
            [weakSelf didSelectWithIndex:index];
        };
    }
    return _mPlayerView;
}
@end
