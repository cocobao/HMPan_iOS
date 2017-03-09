//
//  pssPCFileViewController.m
//  pinut
//
//  Created by admin on 2017/1/19.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssPCFileViewController.h"
#import "pssNetServiceHeaper.h"
#import "pSSMovieViewController.h"

@interface pssPCFileViewController ()
@property (nonatomic, strong) UILabel *mLinkStatus;
@property (nonatomic, strong) NSMutableArray *mArrDataSource;
@end

@implementation pssPCFileViewController

-(instancetype)init
{
    self = [super init];
    if (self) {
        _mArrDataSource = [NSMutableArray array];
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [pssLink removeTcpDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [pssLink addTcpDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mLinkStatus.frame = CGRectMake(0, 0, kScreenWidth, MarginH(30));
    self.tableView.frame = CGRectMake(0, MarginH(30), kScreenWidth, kScreenHeight-NAVBAR_H-MarginH(30));
    [self NetStatusChange:[pssLink tcpLinkStatus]];
    
    if ([pssLink tcpLinkStatus] != tcpConnect_ConnectOk) {
        [pssLink NetApi_BoardCastIp];
    }
}

-(UILabel *)mLinkStatus
{
    if (!_mLinkStatus) {
        UILabel *label = [[UILabel alloc] init];
        label.font = kFont(15);
        [self.view addSubview:label];
        _mLinkStatus = label;
    }
    return _mLinkStatus;
}

- (void)NetStatusChange:(tcpConnectState)state
{
    if ([[NSThread currentThread] isMainThread]) {
        if (state == tcpConnect_ConnectOk) {
            self.mLinkStatus.text = @"已连接";
            self.mLinkStatus.textColor = [UIColor greenColor];
            
            [self openDir:@"/"];
        }else{
            self.mLinkStatus.text = @"未连接";
            self.mLinkStatus.textColor = [UIColor redColor];
        }
    }else{
        WeakSelf(weakSelf);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf NetStatusChange:state];
        });
    }
}

-(void)openDir:(NSString *)dir
{
    [pssLink NetApi_OpenDir:dir block:^(NSDictionary *message, NSError *error) {
        if (error) {
            return;
        }
    }];
}

-(NSInteger)eh_numberOfRowsInSection:(NSInteger)section
{
    return _mArrDataSource.count;
}

-(CGFloat)eh_cellHeightAtIndexPath:(NSIndexPath *)indexPath
{
    return MarginH(50);
}

-(pSSBaseTableViewCell *)eh_cellAtIndexPath:(NSIndexPath *)indexPath
{
    pSSBaseTableViewCell *cell = [pSSBaseTableViewCell cellWithTableView:self.tableView];
    cell.imageView.image = [UIImage imageNamed:@"file"];
    cell.textLabel.text = _mArrDataSource[indexPath.row];
    return cell;
}

-(void)eh_didSelectCellAtIndexPath:(NSIndexPath *)indexPath cell:(pSSBaseTableViewCell *)cell
{
    NSString *file = _mArrDataSource[indexPath.row];
    
    if (file.length > 0) {
        [pssLink NetApi_OpenFile:file block:^(NSDictionary *message, NSError *error) {
            if (error) {
                return;
            }
        }];
    }
}

- (void)NetTcpCallback:(NSDictionary *)receData error:(NSError *)error
{
    NSInteger type = [receData[PSS_CMD_TYPE] integerValue];
    switch (type) {
        case emPssProtocolType_PushDir:
        {
            _mArrDataSource = receData[ptl_files];
        }
            break;
        case emPssProtocolType_VideoInfo:
        {
            int msgId = (int)[receData[ptl_msgId] integerValue];
            [pssLink NetApi_VideoInfoAckWithMsgId:msgId];
            
            NSInteger fps = [receData[ptl_fps] integerValue];
            NSInteger duration = [receData[ptl_duration] integerValue];
            NSInteger mvCodecId = [receData[ptl_mvCodecId] integerValue];
            NSInteger avCodecId = [receData[ptl_avCodecId] integerValue];
            NSInteger sampleFmt = [receData[ptl_sampleFmt] integerValue];
            NSInteger sampleRate = [receData[ptl_sampleRate] integerValue];
            NSInteger channels = [receData[ptl_channels] integerValue];
            
            WeakSelf(weakSelf);
            dispatch_async(dispatch_get_main_queue(), ^{
                StrongSelf(strongSelf, weakSelf);
                
                pSSMovieViewController *vc = [[pSSMovieViewController alloc] initNetPcType];
                [vc setNetPcFps:fps duration:duration mvCodecId:mvCodecId];
                [vc setNetPcSampleFmt:sampleFmt sampleRate:sampleRate channels:channels avCodecId:avCodecId];
                [strongSelf pushVc:vc];
            });
        }
        default:
            break;
    }
    
    WeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
    });
}
@end
