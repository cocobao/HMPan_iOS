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
#import "UIAlertView+RWBlock.h"
#import "pssLinkObj+Api.h"
#import "UPan_FileRecvMgr.h"

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

-(void)dealloc
{
    
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
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.mLinkBtn];
    self.navigationItem.rightBarButtonItem = leftItem;
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
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [pssLink removeTcpDelegate:self];
}

-(void)setupFileSource
{
    //生成主路径
    NSString *rootPath = nil;
    if (_mCurDir.length > 0) {
        rootPath = _mCurDir;
    }else{
        _mCurDir = [[UPan_FileMng dirCache] stringByAppendingPathComponent:UPAN_SRC_PATH];
        [UPan_FileMng createDir:rootPath];
        rootPath = _mCurDir;
    }

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//生成文件
-(UPan_File *)createFile:(NSString *)fileName
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fileName BEGINSWITH %@", fileName];
    NSArray *arrTmp = [_mDataSource filteredArrayUsingPredicate:predicate];
    if (arrTmp.count > 0) {
        //创建副本文件
        fileName = [NSString stringWithFormat:@"%@-副本%zd", fileName, arrTmp.count];
    }
    
    NSString *createPath = [_mCurDir stringByAppendingPathComponent:fileName];
    [UPan_FileMng createFile:createPath];
    NSDictionary *fileAtts = [UPan_FileMng fileAttriutes:createPath];
    if (!fileAtts) {
        return nil;
    }
    
    UPan_File *uFile = [[UPan_File alloc] initWithPath:createPath Atts:fileAtts];
    return uFile;
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

- (void)NetTcpCallback:(NSDictionary *)receData error:(NSError *)error
{
    NSInteger comType = [receData[PSS_CMD_TYPE] integerValue];
    if (comType == emPssProtocolType_ApplySendFile) {
        NSString *fileName = receData[ptl_fileName];
        NSString *filePath = receData[ptl_filePath];
        NSInteger fileSize = [receData[ptl_fileSize] integerValue];
        NSString *strSize = [pSSCommodMethod exchangeSize:fileSize];
        
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示"
                                                       message:[NSString stringWithFormat:@"请求接收文件:%@,大小:%@", fileName, strSize]
                                                      delegate:nil
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"确定", nil];
        WeakSelf(weakSelf);
        [view setCompleteBlock:^(UIAlertView *alertView, NSInteger btnIndex) {
            if (btnIndex == 1) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    //这里待实现内存空间判断
                    
                    //生成文件
                    UPan_File *uFile = [weakSelf createFile:fileName];
                    if (!uFile) {
                        [weakSelf addHub:@"创建文件失败" hide:YES];
                        return;
                    }

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.mDataSource addObject:uFile];
                        [weakSelf.mTableView reloadData];
                    });
                    
                    NSLog(@"create fileId:%zd, fileSize:%zd", uFile.fileId, fileSize);
                
                    [FileRecver addFileRecver:uFile fileSize:fileSize];
                    [pssLink NetApi_ApplySendFileAck:filePath fileId:uFile.fileId];
                });
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [view show];
        });
    }
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
        btn.frame = CGRectMake(0, 0, 30, 30);
        _mLinkBtn = btn;
    }
    return _mLinkBtn;
}
@end
