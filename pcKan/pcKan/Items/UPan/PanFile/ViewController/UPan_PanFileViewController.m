//
//  UPan_PanFileViewController.m
//  pcKan
//
//  Created by admin on 2017/3/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_PanFileViewController.h"
#import "UPan_FileTableView.h"
#import "UPan_FileMng.h"
#import "UPan_File.h"
#import "pssLocalMoviePlayViewController.h"
#import "pssLinkObj.h"
#import "pssLinkObj+Api.h"
#import "UPan_FileExchanger.h"

@interface UPan_PanFileViewController ()<UPanFileDelegate, NetTcpCallback>
@property (nonatomic, strong) UPan_FileTableView *mTableView;
@property (nonatomic, strong) NSMutableArray *mDataSource;
@property (nonatomic, strong) NSString *mCurDir;
@property (nonatomic, strong) UIButton *mLinkBtn;
@end

@implementation UPan_PanFileViewController

-(instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _mCurDir = path;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mDataSource = [NSMutableArray array];
    self.mTableView.frame = CGRectMake(0, 0, kScreenWidth, kViewHeight);

    WeakSelf(weakSelf);
    [self.mTableView headerRereshing:YES rereshingBlock:^{
        [weakSelf setupFileSource];
    }];
    [self setupFileSource];
    
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.mLinkBtn];
//    self.navigationItem.rightBarButtonItem = leftItem;
    
    [self.navigationController.navigationBar addSubview:self.mLinkBtn];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [pssLink addTcpDelegate:self];
    
    tcpConnectState state = [pssLink tcpLinkStatus];
    if (state == tcpConnect_ConnectOk) {
        self.mLinkBtn.backgroundColor = [UIColor greenColor];
    }else{
        self.mLinkBtn.backgroundColor = [UIColor redColor];
    }
    
    NSNotificationCenter *ntf = [NSNotificationCenter defaultCenter];
    [ntf addObserver:self selector:@selector(ntfCreateNewFile:) name:kNotificationFileCreate object:nil];
    
    [FileExchanger setMNowPath:self.mCurDir];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [pssLink removeTcpDelegate:self];
    
    NSNotificationCenter *ntf = [NSNotificationCenter defaultCenter];
    [ntf removeObserver:self];
}

-(void)setupFileSource
{
    //生成主路径
    NSString *rootPath = nil;
    rootPath = self.mCurDir;

    //获取路径下所有文件
    NSArray *arr = [UPan_FileMng ContentOfPath:rootPath];
    if (arr.count == 0) {
        return;
    }
    
    NSMutableArray *arrO = [NSMutableArray arrayWithCapacity:arr.count];
    for (NSString *file in arr) {
        NSString *path = [rootPath stringByAppendingPathComponent:file];
        NSDictionary *fileAtts = [UPan_FileMng fileAttriutes:path];
        
        UPan_File *uFile = [[UPan_File alloc] initWithPath:path Atts:fileAtts];
        [arrO addObject:uFile];
    }
    
    //把目录排到前面
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fileType = %d", UPan_FT_Dir];
    NSArray *arrD = [arrO filteredArrayUsingPredicate:predicate];
    [arrO removeObjectsInArray:arrD];
    
    [_mDataSource removeAllObjects];
    if (arrD.count > 0) {
        [_mDataSource addObjectsFromArray:arrD];
    }
    
    if (arrO.count > 0) {
        [_mDataSource addObjectsFromArray:arrO];
    }
    
    [self.mTableView reloadData];
}

-(void)ntfCreateNewFile:(NSNotification *)ntf
{
    UPan_File *uFile = ntf.object;
    if (!uFile) {
        [self addHub:@"创建文件失败" hide:YES];
        return;
    }
    [_mDataSource addObject:uFile];
    WeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.mDataSource.count-1 inSection:0];
        [weakSelf.mTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

#pragma mark - NetTcpCallback
- (void)NetStatusChange:(tcpConnectState)state
{
    WeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (state == tcpConnect_ConnectOk) {
            weakSelf.mLinkBtn.backgroundColor = [UIColor greenColor];
        }else{
            weakSelf.mLinkBtn.backgroundColor = [UIColor redColor];
        }
    });
}

#pragma mark - UPanFileDelegate
-(NSArray *)UPanFileDataSource
{
    return _mDataSource;
}

-(void)didSelectFile:(UPan_File *)file
{
    if (file.fileType == UPan_FT_Dir) {
        UPan_PanFileViewController *vc = [[UPan_PanFileViewController alloc] initWithPath:file.filePath];
        [self pushVc:vc];
    }else if (file.fileType == UPan_FT_Img){
        
    }else if (file.fileType == UPan_FT_Mov){
        pssLocalMoviePlayViewController *vc = [[pssLocalMoviePlayViewController alloc] initWithURL:
                                               [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", file.filePath]]];
        [self pushVc:vc];
    }
}

-(void)didDeleteFile:(UPan_File *)file
{
    [UPan_FileMng deleteFile:file.filePath];
    
    [self.mDataSource removeObject:file];
}

#pragma mark - views
-(UPan_FileTableView *)mTableView
{
    if (!_mTableView) {
        UPan_FileTableView *view = [[UPan_FileTableView alloc] init];
        view.m_delegate = self;
        [self.view addSubview:view];
        _mTableView = view;
    }
    return _mTableView;
}

-(UIButton *)mLinkBtn
{
    if (!_mLinkBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(60, kTabBarHeight-40, 30, 30);
        _mLinkBtn = btn;
    }
    return _mLinkBtn;
}

-(NSString *)mCurDir
{
    if (!_mCurDir) {
        _mCurDir = [UPan_FileMng hmPath];
        [UPan_FileMng createDir:_mCurDir];
    }
    return _mCurDir;
}
@end
