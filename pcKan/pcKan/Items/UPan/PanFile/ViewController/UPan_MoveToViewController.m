//
//  UPan_MoveToViewController.m
//  pcKan
//
//  Created by admin on 2017/3/16.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_MoveToViewController.h"
#import "UPan_FileMng.h"
#import "EHSuspensionFrameTextFieldView.h"

@interface UPan_MoveToViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIView *mHeadView;
@property (nonatomic, strong) UIView *mFootView;
@property (nonatomic, strong) UIButton *mCancelBtn;
@property (nonatomic, strong) UIButton *mBackBtn;
@property (nonatomic, strong) UIButton *mNewFoldBtn;
@property (nonatomic, strong) UIButton *mMoveBtn;

@property (nonatomic, strong) NSString *mMoveFile;
@property (nonatomic, strong) NSString *mCurPath;
@property (nonatomic, strong) UITableView *mTableView;
@property (nonatomic, strong) NSMutableArray *mDataSource;
@property (nonatomic, strong) NSMutableArray *mPathsSource;
@end

@implementation UPan_MoveToViewController
-(instancetype)initWithFilePath:(NSString *)filePath
{
    if (self = [super init]) {
        _mMoveFile = filePath;
        
        _mDataSource = [NSMutableArray array];
        _mPathsSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat height = kTopBarHeight-40;
    self.mHeadView.frame = CGRectMake(0, 0, kScreenWidth, NAVBAR_H);
    self.mCancelBtn.frame = CGRectMake(kScreenWidth-60, height, 60, 40);
    self.mBackBtn.frame = CGRectMake(10, height, 60, 40);
    
    CGFloat width = (kScreenWidth-40)/2;
    height = kToolBarHeight-6;
    self.mFootView.frame = CGRectMake(0, kScreenHeight-kToolBarHeight, kScreenWidth, kToolBarHeight);
    self.mNewFoldBtn.frame = CGRectMake(15, 3, width, height);
    self.mMoveBtn.frame = CGRectMake(kScreenWidth-width-15, 3, width, height);
    self.mTableView.frame = CGRectMake(0, NAVBAR_H, kScreenWidth, kScreenHeight-NAVBAR_H-kToolBarHeight);
    
    _mCurPath = [UPan_FileMng hmPath];
    [self foldOfNowFold];
}

-(void)backAction:(UIButton *)sender
{
    _mCurPath = [_mCurPath stringByDeletingLastPathComponent];
    [self foldOfNowFold];
}

-(void)moveAction:(UIButton *)sender
{
    NSString *fileName = [_mMoveFile lastPathComponent];
    NSString *toPath = [_mCurPath stringByAppendingPathComponent:fileName];
    [UPan_FileMng moveFile:_mMoveFile toPath:toPath];
    [self cancelAction:nil];
    if (_didMoveFile) {
        _didMoveFile();
    }
}

-(void)cancelAction:(UIButton *)sender
{
    [self dismiss];
}

-(void)newFoldAction:(UIButton *)sender
{
    NSString *placeholder = @"新建文件夹";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", placeholder];
    NSArray *arrTmp = [_mDataSource filteredArrayUsingPredicate:predicate];
    if (arrTmp.count > 0) {
        placeholder = [NSString stringWithFormat:@"%@%zd", placeholder, arrTmp.count];
    }
    
    EHSuspensionFrameTextFieldView *view = [[EHSuspensionFrameTextFieldView alloc] initWithTitle:@"新建文件夹" placeholder:placeholder];
    [view show];
    WeakSelf(weakSelf);
    view.didSelectButton = ^(NSInteger index, NSString *text){
        if (index == 1 && text.length > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", text];
            NSArray *arrTmp = [weakSelf.mDataSource filteredArrayUsingPredicate:predicate];
            if (arrTmp.count > 0){
                [weakSelf addHub:@"文件夹已存在" hide:YES];
                return;
            }
            
            if (![UPan_FileMng createDir:[weakSelf.mCurPath stringByAppendingPathComponent:text]]) {
                [weakSelf addHub:@"创建文件夹失败" hide:YES];
                return;
            }
            
            //刷新文件信息以及显示信息
            [weakSelf foldOfNowFold];
        }
    };
}

-(void)foldOfNowFold
{
    [_mDataSource removeAllObjects];
    [_mPathsSource removeAllObjects];
    
    if ([_mCurPath isEqualToString:[UPan_FileMng hmPath]]) {
        self.mBackBtn.hidden = YES;
    }else{
        self.mBackBtn.hidden = NO;
    }
    
    //获取路径下所有文件
    NSArray *arr = [UPan_FileMng ContentOfPath:_mCurPath];
    if (arr.count == 0) {
        [self.mTableView reloadData];
        return;
    }
    
    for (NSString *file in arr) {
        NSString *filePath = [_mCurPath stringByAppendingPathComponent:file];
        
        //实例化文件对象类
        NSDictionary *fileAtts = [UPan_FileMng fileAttriutes:filePath];
        NSString *attsFileType = fileAtts[NSFileType];
        if ([attsFileType isEqualToString:NSFileTypeDirectory]) {
            [_mDataSource addObject:file];
            [_mPathsSource addObject:filePath];
        }
    }
    [self.mTableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mDataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_identify"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_identify"];
    }
    cell.imageView.image = [UIImage imageNamed:@"fold"];
    cell.textLabel.text = [_mDataSource objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _mCurPath = [_mPathsSource objectAtIndex:indexPath.row];
    [self foldOfNowFold];
}

-(UITableView *)mTableView
{
    if (!_mTableView) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        view.delegate = self;
        view.dataSource = self;
        view.separatorStyle = UITableViewCellSeparatorStyleNone;
        view.rowHeight = 40;
        [self.view addSubview:view];
        _mTableView = view;
    }
    return _mTableView;
}

-(UIButton *)mNewFoldBtn
{
    if (!_mNewFoldBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor whiteColor];
        btn.titleLabel.font = kFont(15);
        btn.layer.cornerRadius = 5;
        [btn setTitle:@"新建文件夹" forState:UIControlStateNormal];
        [btn setTitleColor:ColorFromHex(0x434142) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(newFoldAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mFootView addSubview:btn];
        _mNewFoldBtn = btn;
    }
    return _mNewFoldBtn;
}

-(UIButton *)mMoveBtn
{
    if (!_mMoveBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = Color_Main;
        btn.titleLabel.font = kFont(15);
        btn.layer.cornerRadius = 5;
        [btn setTitle:@"移动到这" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(moveAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mFootView addSubview:btn];
        _mMoveBtn = btn;
    }
    return _mMoveBtn;
}

-(UIView *)mFootView
{
    if (!_mFootView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = ColorFromHex(0x434142);
        [self.view addSubview:view];
        _mFootView = view;
    }
    return _mFootView;
}

-(UIView *)mHeadView
{
    if (!_mHeadView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = Color_Main;
        [self.view addSubview:view];
        _mHeadView = view;
    }
    return _mHeadView;
}

-(UIButton *)mCancelBtn
{
    if (!_mCancelBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = kFont(18);
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mHeadView addSubview:btn];
        _mCancelBtn = btn;
    }
    return _mCancelBtn;
}

-(UIButton *)mBackBtn
{
    if (!_mBackBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = kFont(18);
        [btn setTitle:@"返回" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mHeadView addSubview:btn];
        _mBackBtn = btn;
    }
    return _mBackBtn;
}
@end
