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
#import "pssLinkObj.h"
#import "pssLinkObj+Api.h"
#import "UPan_FileExchanger.h"
#import "EHScSetDefendView.h"
#import "EHSuspensionFrameTextFieldView.h"
#import "UPan_MoveToViewController.h"
#import "pssGUIPlayerViewController.h"

@interface UPan_PanFileViewController ()<UPanFileDelegate, NetTcpCallback>
@property (nonatomic, strong) UPan_FileTableView *mTableView;
@property (nonatomic, strong) NSMutableArray *mDataSource;
@property (nonatomic, strong) NSString *mCurDir;
@property (nonatomic, strong) UIButton *mLinkBtn;
@property (nonatomic, strong) UIButton *mCreateFoldBtn;
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
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.mCreateFoldBtn];
    self.navigationItem.rightBarButtonItem = leftItem;
    
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
    //页面消息的时候，注销tcp代理,以及通知，交给下一个页面
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

//通知创建新文件
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

//请求pc端接收文件
-(void)applyRecvFile:(UPan_File *)file
{
    NSDictionary *dict = @{
                           ptl_fileName:file.fileName,
                           ptl_fileSize:@(file.fileSize),
                           };
    [pssLink NetApi_ApplyRecvFile:dict block:^(NSDictionary *message, NSError *error) {
        if (error) {
            return;
        }
        NSInteger code = [message[ptl_status] integerValue];
        if (code != _SUCCESS_CODE) {
            NSLog(@"%@", message);
            return;
        }
        NSInteger fileId = [message[ptl_fileId] integerValue];
        [FileExchanger addSendingFilePath:file.filePath fileId:fileId];
    }];
}

//重命名文件
-(void)reNameFile:(UPan_File *)file indexPath:(NSIndexPath *)indexPath
{
    EHSuspensionFrameTextFieldView *view = [[EHSuspensionFrameTextFieldView alloc] initWithTitle:@"重命名" placeholder:file.fileName];
    [view show];
    WeakSelf(weakSelf);
    view.didSelectButton = ^(NSInteger index, NSString *text){
        if (index == 1 && text.length > 0) {
            if ([text isEqualToString:file.fileName]) {
                return;
            }
            NSArray *arrSrcFile = [UPan_FileMng ContentOfPath:weakSelf.mCurDir];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", text];
            NSArray *arrTmp = [arrSrcFile filteredArrayUsingPredicate:predicate];
            if (arrTmp.count > 0){
                [weakSelf addHub:@"文件名已存在" hide:YES];
                return;
            }
            if (![UPan_FileMng renameFileName:file.fileName toNewName:text atPath:weakSelf.mCurDir]) {
                [weakSelf addHub:@"重命名失败" hide:YES];
            }
            //刷新文件信息以及显示信息
            file.fileName = text;
            file.filePath = [weakSelf.mCurDir stringByAppendingPathComponent:text];
            [weakSelf.mTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    };
}

//新建文件夹
-(void)createFoldSction:(UIButton *)sender
{
    NSString *placeholder = @"新建文件夹";
    NSArray *arrSrcFile = [UPan_FileMng ContentOfPath:_mCurDir];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", placeholder];
    NSArray *arrTmp = [arrSrcFile filteredArrayUsingPredicate:predicate];
    if (arrTmp.count > 0) {
        placeholder = [NSString stringWithFormat:@"%@%zd", placeholder, arrTmp.count];
    }
    
    EHSuspensionFrameTextFieldView *view = [[EHSuspensionFrameTextFieldView alloc] initWithTitle:@"新建文件夹" placeholder:placeholder];
    [view show];
    WeakSelf(weakSelf);
    view.didSelectButton = ^(NSInteger index, NSString *text){
        if (index == 1 && text.length > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", text];
            NSArray *arrTmp = [arrSrcFile filteredArrayUsingPredicate:predicate];
            if (arrTmp.count > 0){
                [weakSelf addHub:@"文件夹已存在" hide:YES];
                return;
            }
            
            if (![UPan_FileMng createDir:[weakSelf.mCurDir stringByAppendingPathComponent:text]]) {
                [weakSelf addHub:@"创建文件夹失败" hide:YES];
                return;
            }
            
            //刷新文件信息以及显示信息
            [weakSelf setupFileSource];
        }
    };

}

#pragma mark - NetTcpCallback
//网络状态改变
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

//查看文件
-(void)didSelectFile:(UPan_File *)file
{
    if (file.fileType == UPan_FT_Dir) {
        UPan_PanFileViewController *vc = [[UPan_PanFileViewController alloc] initWithPath:file.filePath];
        [self pushVc:vc];
    }else if (file.fileType == UPan_FT_Img){
        
    }else if (file.fileType == UPan_FT_Mov){
        pssGUIPlayerViewController *vc = [[pssGUIPlayerViewController alloc] initWithUrl:[NSURL fileURLWithPath:file.filePath]];
        [self pushVc:vc];
    }
}

//删除文件
-(void)didDeleteFile:(UPan_File *)file
{
    [UPan_FileMng deleteFile:file.filePath];
    
    [self.mDataSource removeObject:file];
}

-(void)accessButtonWithIndex:(NSIndexPath *)indexPath
{
    NSArray *arrItems = @[@"重命名", @"发送到电脑", @"移动到", @"取消"];
    EHScSetDefendView *view = [[EHScSetDefendView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)
                                                                   arr:arrItems];
    [view show];
    WeakSelf(weakSelf);
    view.didSelectIndex = ^(NSInteger index){
        if (index == arrItems.count - 1) {
            return;
        }
        
        UPan_File *file = [weakSelf.mDataSource objectAtIndex:indexPath.row];
        if (index == 0) {
            [weakSelf reNameFile:file indexPath:indexPath];
        }else if (index == 1) {
            if ([pssLink tcpLinkStatus] != tcpConnect_ConnectOk) {
                [weakSelf addHub:@"请先连接电脑客户端" hide:YES];
                return;
            }
            [weakSelf applyRecvFile:file];
        }else if (index == 2){
            UPan_MoveToViewController *vc = [[UPan_MoveToViewController alloc] init];
            [weakSelf presentVc:vc];
        }
    };
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

-(UIButton *)mCreateFoldBtn
{
    if (!_mCreateFoldBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor orangeColor];
        btn.frame = CGRectMake(0, 0, 30, 30);
        [btn addTarget:self action:@selector(createFoldSction:) forControlEvents:UIControlEventTouchUpInside];
        _mCreateFoldBtn = btn;
    }
    return _mCreateFoldBtn;
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
