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
#import "pssLinkObj.h"
#import "pssLinkObj+Api.h"
#import "UPan_FileExchanger.h"
#import "EHScSetDefendView.h"
#import "EHSuspensionFrameTextFieldView.h"
#import "UPan_MoveToViewController.h"
#import "pssDocReaderViewController.h"
#import "SARUnArchiveANY.h"
#import "LZMAExtractor.h"
#import "UIImageView+MJWebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

#import "pSSAvPlayerViewController.h"
#import "pSSAvPlayerViewController.h"
#import "pSSAvPlayerModule.h"
#import "UPan_CurrentPathFileMng.h"
#import "UIAlertView+RWBlock.h"
#import "pssVLCPlayerViewController.h"

@interface UPan_PanFileViewController ()
<UPanFileDelegate,
NetTcpCallback>
@property (nonatomic, strong) UPan_FileTableView *mTableView;
@property (nonatomic, strong) NSMutableArray *mDataSource;
/*当前路径*/
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
    
    if ([self.mCurDir isEqualToString:[UPan_FileMng hmPath]]) {
        self.title = @"文件";
    }else{
        self.title = [self.mCurDir lastPathComponent];
    }
    
    _mDataSource = [NSMutableArray array];

    self.mTableView.frame = CGRectMake(0, 0, kScreenWidth, kViewHeight-NAVBAR_H);
    WeakSelf(weakSelf);
    [self.mTableView headerRereshing:YES rereshingBlock:^{
        [weakSelf setupFileSource];
    }];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.mCreateFoldBtn];
    self.navigationItem.rightBarButtonItem = leftItem;
    [self.navigationController.navigationBar addSubview:self.mLinkBtn];
    
    [self addHub:@"加载中" hide:NO];
    //获取当前路径的文件资源
    [self setupFileSource];
    [self removeHub];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyLogoutNotify:)
                                                 name:kNotificationLogout
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //当前的网络状态显示
    tcpConnectState state = [pssLink tcpLinkStatus];
    [self setLinkStateImg:state];
    
    if (![CurPathFile.mNowPath isEqualToString:self.mCurDir]) {
        //添加tcp代理
        [pssLink addTcpDelegate:self];

        //注册通知接口
        NSNotificationCenter *ntf = [NSNotificationCenter defaultCenter];
        [ntf addObserver:self selector:@selector(ntfCreateNewFile:) name:kNotificationFileCreate object:nil];
        
        [FileExchanger setMNowPath:self.mCurDir];
        CurPathFile.mNowPath = self.mCurDir;
        CurPathFile.mFileSource = _mDataSource;
    }
}

-(void)notifyLogoutNotify:(NSNotification *)notify
{
    WeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf setLinkStateImg:[pssLink tcpLinkStatus]];
    });
}

//文件资源准备好
-(void)setupFileSource
{
    //生成主路径
    NSString *rootPath = self.mCurDir;
    [_mDataSource removeAllObjects];
    
    //获取路径下所有文件
    NSArray *arr = [UPan_FileMng ContentOfPath:rootPath];
    if (arr.count == 0) {
        [self.mTableView reloadData];
        return;
    }
    
    NSMutableArray *arrInfoSource = [NSMutableArray array];
    //读出传输信息文件
    for (NSString *file in arr) {
        if ([file hasSuffix:@".hmf"]) {
            NSData *data = [UPan_FileMng readFile:[rootPath stringByAppendingPathComponent:file]];
            NSDictionary *dict = [pSSCommodMethod jsonObjectWithJsonData:data];
            if (dict)
                [arrInfoSource addObject:dict];
        }
    }
    
    //读出所有文件
    NSMutableArray *arrO = [NSMutableArray arrayWithCapacity:arr.count];
    for (NSString *file in arr) {
        if ([file hasSuffix:@".hmf"]) continue;
        
        NSString *path = [rootPath stringByAppendingPathComponent:file];

        //实例化文件对象类
        NSDictionary *fileAtts = [UPan_FileMng fileAttriutes:path];
        UPan_File *uFile = [[UPan_File alloc] initWithPath:path Atts:fileAtts];
        
        //是否有传输信息
        for (NSDictionary *chanInfoDict in arrInfoSource) {
            NSInteger fileId = [chanInfoDict[ptl_fileId] integerValue];
            if (fileId == uFile.fileId) {
                if ([FileExchanger isFileExchanging:fileId]) {
                    uFile.exchangingState = EXCHANGE_ING;
                }else{
                    uFile.exchangingState = EXCHANGE_PUSE;
                }
                
                uFile.exchangeInfo = [NSMutableDictionary dictionaryWithDictionary:chanInfoDict];
                
                //这里必须更新路径，iphone每次启动文件路径都会变化
                [uFile.exchangeInfo setValue:uFile.filePath forKey:ptl_filePath];
                
                break;
            }
        }
        
        [arrO addObject:uFile];
    }
    
    //把文件夹类排到前面
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fileType = %d", UPan_FT_Dir];
    NSArray *arrD = [arrO filteredArrayUsingPredicate:predicate];
    [arrO removeObjectsInArray:arrD];
    
    //添加文件夹类
    if (arrD.count > 0) {
        [_mDataSource addObjectsFromArray:arrD];
    }
    //添加普通文件类
    if (arrO.count > 0) {
        [_mDataSource addObjectsFromArray:arrO];
    }
    
    [self.mTableView reloadData];
}

//创建了新文件被通知
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
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.mDataSource.count-1 inSection:0];
//        [weakSelf.mTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.mTableView reloadData];
    });
}

//请求pc端接收文件
-(void)applyRecvFile:(UPan_File *)file
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:[NSString stringWithFormat:@"发送文件%@到电脑", file.fileName]
                                                   delegate:nil
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    [alert show];
    [alert setCompleteBlock:^(UIAlertView *alertView, NSInteger btnIndex) {
        if (btnIndex == 1) {
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD showMessage:[NSString stringWithFormat:@"发送失败,%@", message[@"msg"]]];
                    });
                    return;
                }
                NSInteger fileId = [message[ptl_fileId] integerValue];
                [FileExchanger addSendingFilePath:file pcFileId:fileId];
            }];
        }
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

-(void)linkBtnAction:(UIButton *)sender
{
//    EHSuspensionFrameTextFieldView *view = [[EHSuspensionFrameTextFieldView alloc] initWithTitle:@"输入IP地址" placeholder:@"192.168."];
//    [view show];
//
//    view.didSelectButton = ^(NSInteger index, NSString *text){
//        if (index == 1 && text.length > 0) {
//            [pssLink NetApi_BoardCastIp:text];
//        }
//    };
    [pssLink NetApi_BoardCastIp:@"255.255.255.255"];
}

-(void)setLinkStateImg:(tcpConnectState)state
{
    if (state == tcpConnect_ConnectOk) {
        [self.mLinkBtn setImage:[UIImage imageNamed:@"icon_electrify"] forState:UIControlStateNormal];
    }else{
        [self.mLinkBtn setImage:[UIImage imageNamed:@"icon_cutout"] forState:UIControlStateNormal];
    }
}

#pragma mark - NetTcpCallback
//网络状态改变
- (void)NetStatusChange:(tcpConnectState)state
{
    WeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf setLinkStateImg:state];
    });
}

#pragma mark - UPanFileDelegate
-(NSArray *)UPanFileDataSource
{
    return _mDataSource;
}

//删除文件
-(void)didDeleteFile:(UPan_File *)file
{
    //删除资源
    [UPan_FileMng deleteFile:file.filePath];
    
    NSString *infoFile = [NSString stringWithFormat:@"%@.hmf", file.filePath];
    [UPan_FileMng deleteFile:infoFile];
    
    [self.mDataSource removeObject:file];
    
    //发送通知文件被删除
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDeleteFile object:file];
}

//查看文件
-(void)didSelectFile:(NSIndexPath *)indexPath
{
    UPan_File *file = [self.mDataSource objectAtIndex:indexPath.row];
    if (file.exchangingState != EXCHANGE_COM &&
        file.fileType != UPan_FT_Mov) {
        return;
    }
    
    UIViewController *vc = nil;
    switch (file.fileType) {
        case UPan_FT_Dir:
        {
            //文件夹类型，跳转到下一集目录展示
            vc = [[UPan_PanFileViewController alloc] initWithPath:file.filePath];
            
            //页面消息的时候，注销tcp代理,以及通知，交给下一个页面
            [pssLink removeTcpDelegate:self];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
            break;
        case UPan_FT_Img:
        {
            //照片预览
            UITableViewCell *cell = [self.mTableView cellForRowAtIndexPath:indexPath];
            
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL fileURLWithPath:file.filePath];
            photo.srcImageView = [cell viewWithTag:View_tag_ImageView];
            MJPhotoBrowser *photoBrowser = [[MJPhotoBrowser alloc] init];
            photoBrowser.photos = @[photo];
            photoBrowser.currentPhotoIndex = 0;
            [photoBrowser show];
        }
            break;
        case UPan_FT_Mov:
        {
            if ([PSS_AVPLAYER isPlaying]) {
                [PSS_AVPLAYER stop];
            }
            
            //本地视频观看
            vc = [[pssVLCPlayerViewController alloc] initWithFilePath:file.filePath];
        }
            break;
        case UPan_FT_Word:
        case UPan_FT_Pdf:
        case UPan_FT_Ppt:
        case UPan_FT_Xls:
        case UPan_FT_Txt:
        case UPan_FT_H:
        case UPan_FT_M:
        {
            //浏览文档
            vc = [[pssDocReaderViewController alloc] initWithUrl:[NSURL fileURLWithPath:file.filePath]];
        }
            break;
        case UPan_FT_Rar:
        case UPan_FT_Zip:
        {
            //文件解压
            [self decompressFile:file];
        }
            break;
        case UPan_FT_Mus:
        {
            //本地音频播放
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fileType = %d", UPan_FT_Mus];
            NSArray *arrMus = [self.mDataSource filteredArrayUsingPredicate:predicate];
            vc = [[pSSAvPlayerViewController alloc] initWithFiles:arrMus playFile:file];
        }
            break;
        default:
            break;
    }
    
    if (vc) {
        [self pushVc:vc];
    }
}

//点击更多操作
-(void)accessButtonWithIndex:(NSIndexPath *)indexPath
{
    NSArray *arrItems = @[@"重命名", @"发送到电脑", @"移动到", @"取消"];
    
    EHScSetDefendView *view = [[EHScSetDefendView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)
                                                                   arr:arrItems];
    [view show];
    WeakSelf(weakSelf);
    view.didSelectIndex = ^(NSInteger index){
        if (index == arrItems.count - 1) {
            //取消
            return;
        }
        UPan_File *file = [_mDataSource objectAtIndex:indexPath.row];
        if (index == 0) {
            [weakSelf reNameFile:file indexPath:indexPath];
        }else if (index == 1) {
            if ([pssLink tcpLinkStatus] != tcpConnect_ConnectOk) {
                [weakSelf addHub:@"请先连接电脑客户端" hide:YES];
                return;
            }
            [weakSelf applyRecvFile:file];
        }else if (index == 2){
            UPan_MoveToViewController *vc = [[UPan_MoveToViewController alloc] initWithFilePath:file.filePath];
            [weakSelf presentVc:vc];
            vc.didMoveFile = ^(){
                [weakSelf setupFileSource];
            };
        }
    };
}

#pragma mark - Decompress
-(void)decompressFile:(UPan_File *)file
{
    NSArray *arrItems = @[@"直接解压", @"密码解压", @"取消"];
    
    EHScSetDefendView *view = [[EHScSetDefendView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)
                                                                   arr:arrItems];
    [view show];
    WeakSelf(weakSelf);
    view.didSelectIndex = ^(NSInteger index){
        StrongSelf(strongSelf, weakSelf);
        if (index == arrItems.count - 1) return;
        
        if (index == 0) {
            [strongSelf unArchive:file.filePath andPassword:nil destinationPath:weakSelf.mCurDir];
        }else if(index == 1){
            EHSuspensionFrameTextFieldView *view = [[EHSuspensionFrameTextFieldView alloc] initWithTitle:@"解压密码" placeholder:@""];
            [view show];
            view.didSelectButton = ^(NSInteger index, NSString *text){
                if (index == 0) return;
                
                [strongSelf unArchive:file.filePath andPassword:text destinationPath:strongSelf.mCurDir];
            };
        }
    };
}

//解压文件
- (void)unArchive: (NSString *)filePath andPassword:(NSString*)password destinationPath:(NSString *)destPath{
    NSAssert(filePath, @"can't find filePath");
    SARUnArchiveANY *unarchive = [[SARUnArchiveANY alloc] initWithPath:filePath];
    if (password != nil && password.length > 0) {
        unarchive.password = password;
    }
    
    if (destPath != nil)
        unarchive.destinationPath = destPath;
    
    WeakSelf(weakSelf);
    [weakSelf addHub:@"解压中" hide:NO];
    //解压成功
    unarchive.completionBlock = ^(NSArray *filePaths){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf removeHub];
            [weakSelf addHub:@"解压成功" hide:YES];
            [weakSelf setupFileSource];
        });
    };
    //解压失败
    unarchive.failureBlock = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf removeHub];
            [weakSelf addHub:@"解压失败" hide:YES];
        });
    };
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [unarchive decompress];
    });
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
        btn.frame = CGRectMake(kScreenWidth-60-30, kTabBarHeight-42, 30, 30);
        [btn addTarget:self action:@selector(linkBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _mLinkBtn = btn;
    }
    return _mLinkBtn;
}

-(UIButton *)mCreateFoldBtn
{
    if (!_mCreateFoldBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"global_ic_add"] forState:UIControlStateNormal];
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
