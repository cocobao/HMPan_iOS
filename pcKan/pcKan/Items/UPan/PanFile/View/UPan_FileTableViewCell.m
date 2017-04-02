//
//  UPan_FileTableViewCell.m
//  pcKan
//
//  Created by admin on 2017/3/6.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_FileTableViewCell.h"
#import "UPan_FileMng.h"
#import "UPan_FileExchanger.h"

@interface UPan_FileTableViewCell ()
@property (nonatomic, strong) UIImageView *mIcon;
@property (nonatomic, strong) UILabel *mFileNameLabel;
@property (nonatomic, strong) UILabel *mCreateDateLabel;
@property (nonatomic, strong) UILabel *mPerPersentlabel;
@property (nonatomic, strong) UIView *mLine;
@property (nonatomic, strong) CALayer *mPersentLayer;
@property (nonatomic, strong) CALayer *mPersentBackLayer;
@property (nonatomic, strong) UIButton *iBtn;
@end

@implementation UPan_FileTableViewCell

-(void)setMMode:(UPan_CellMode *)mMode file:(UPan_File *)mFile
{
    _mMode = mMode;
    _mFile = mFile;
    
    self.mIcon.frame = mMode.F_Icon;
    self.mFileNameLabel.frame = mMode.F_FileName;
    self.mCreateDateLabel.frame = mMode.F_CreateDate;
    self.mLine.frame = mMode.F_Line;
    self.mPerPersentlabel.frame = mMode.F_Persent;
    self.mFileNameLabel.text = mFile.fileName;
    
    self.mPerPersentlabel.text = @"";
    
    if (mFile.mIcon) {
        self.mIcon.image = mFile.mIcon;
    }else{
        self.mIcon.image = [UIImage imageNamed:@"file"];
    }
    
    if (mFile.fileType == UPan_FT_Dir) {
        self.mCreateDateLabel.text = mFile.createDate;
    }else{
        [self setFileDateAndSize];
    }
    
    if (mFile.fileType != UPan_FT_Dir && mFile.exchangingState == EXCHANGE_COM) {
        self.accessoryType = UITableViewCellAccessoryDetailButton;
    }else{
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (mFile.exchangingState != EXCHANGE_COM) {
        if (mFile.exchangingState == EXCHANGE_ING) {
            [self.iBtn setTitle:@"暂停" forState:UIControlStateNormal];
        }else{
            [self.iBtn setTitle:@"继续" forState:UIControlStateNormal];
        }
        [self updatePersentLine];
        
        [self registerNotifyInterface];
    }

    [self removePersentLayer];
}

-(void)removePersentLayer
{
    if (_mFile.exchangingState == EXCHANGE_COM) {
        if (_mPersentLayer) {
            WeakSelf(weakSelf);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.mPersentLayer removeFromSuperlayer];
                weakSelf.mPerPersentlabel.text = @"";
                weakSelf.mPersentLayer = nil;
            });
        }
        
        if (_mPersentBackLayer) {
            WeakSelf(weakSelf);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.mPersentBackLayer removeFromSuperlayer];
                weakSelf.mPerPersentlabel.text = @"";
                weakSelf.mPersentLayer = nil;
            });
        }
        
        if (_iBtn) {
            [_iBtn removeFromSuperview];
            _iBtn = nil;
        }
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)iBtnAction:(UIButton *)sender
{
    if (_mFile.exchangingState == EXCHANGE_ING) {
        _mFile.exchangingState = EXCHANGE_PUSE;
        [sender setTitle:@"继续" forState:UIControlStateNormal];
        
        [FileExchanger puseRecver:_mFile.fileId];
        
        [self updatePersentLine];
    }else{
        if (!UserInfo.isLogin) {
            [MBProgressHUD showMessage:@"请先连接客户端" toView:self.tableView.superview];
            return;
        }
        
        //恢复文件接收传输
        _mFile.exchangingState = EXCHANGE_ING;
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        
        [FileExchanger recoverRecver:_mFile.exchangeInfo];
        
        [self updatePersentLine];
        _mPerPersentlabel.text = [NSString stringWithFormat:@"%@  0/s", _mPerPersentlabel.text];
    }
}

-(void)notifyLogoutNotify:(NSNotification *)notify
{
    WeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.mPerPersentlabel.text = @"";
        weakSelf.mFile.exchangingState = EXCHANGE_ING;
        [weakSelf iBtnAction:weakSelf.iBtn];
    });
}

//接收文件百分比以及速率
-(void)filePersentNotify:(NSNotification *)notify
{
    [self removePersentLayer];
    if (_mFile.exchangingState != EXCHANGE_ING)
        return;
    
    NSDictionary *dict = notify.object;
    NSInteger fileId = [dict[ptl_fileId] integerValue];
    if (fileId == self.mFile.fileId) {
        //当前百分比
        CGFloat persent = [dict[ptl_persent] floatValue];
        //当前速率
        CGFloat speed = [dict[ptl_speed] floatValue];
        if (dict[ptl_seek]) {
            _mFile.fileSize = [dict[ptl_seek] longLongValue];
            [_mFile.exchangeInfo setValue:@(_mFile.fileSize) forKey:ptl_seek];
        }
        
        WeakSelf(weakSelf);
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新当前的文件大小
            [weakSelf setFileDateAndSize];
            //更新当前的传输进度条
            [weakSelf updatePersentLine];
            
            if (persent<100) {
                if (speed > 0) {
                    //更新当前的进度百分比以及速率
                    NSString *sizeperSec = [pSSCommodMethod exchangeSize:speed];
                    weakSelf.mPerPersentlabel.text = [NSString stringWithFormat:@"%0.0f%%  %@/s", persent, sizeperSec];
                }
            }else{
                //传输完成,清除进度，百分比，速度等
                weakSelf.mFile.exchangingState = EXCHANGE_COM;
                weakSelf.mFile.exchangeInfo = nil;
                [weakSelf.mFile knowFileType];

                [weakSelf.tableView reloadRowsAtIndexPaths:@[_mIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        });
    }
}

//更新文件传输进度
-(void)updatePersentLine
{
    NSDictionary *dict = _mFile.exchangeInfo;
    if (!dict) {
        NSData *data = [UPan_FileMng readFile:[NSString stringWithFormat:@"%@.hmf", _mFile.filePath]];
        if (data) {
            dict = [pSSCommodMethod jsonObjectWithJsonData:data];
        }
        
        if (dict) {
            _mFile.exchangeInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
        }
    }
    
    if (dict) {
        NSInteger seek = [dict[ptl_seek] integerValue];
        NSInteger fileSize = [dict[ptl_fileSize] integerValue];
        
        CGFloat persent = ((double)seek/fileSize)*100;
        
        CGFloat width = persent/100*CGRectGetWidth(self.mCreateDateLabel.frame);
        if (!_mPersentLayer) {
            self.mPersentBackLayer.frame = CGRectMake(CGRectGetMinX(self.mCreateDateLabel.frame),
                                                      CGRectGetMaxY(self.mCreateDateLabel.frame)+3,
                                                      CGRectGetWidth(self.mCreateDateLabel.frame), 1);
            self.mPersentLayer.frame = CGRectMake(CGRectGetMinX(self.mCreateDateLabel.frame),
                                                  CGRectGetMaxY(self.mCreateDateLabel.frame)+3,
                                                  width, 1);
        }else{
            CGRect frame = self.mPersentLayer.frame;
            frame.size.width = width;
            self.mPersentLayer.frame = frame;
        }
        
        _mPerPersentlabel.text = [NSString stringWithFormat:@"%0.0f%%", persent];
    }
}

//显示当前文件size以及时间
-(void)setFileDateAndSize
{
    CGFloat fileSize = _mFile.fileSize;
    NSString *muString = [NSString stringWithFormat:@"%@  %@", _mFile.createDate, [pSSCommodMethod exchangeSize:fileSize]];
    
    self.mCreateDateLabel.text = muString;
}

-(void)registerNotifyInterface
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(filePersentNotify:)
                                                 name:kNotificationFileRecvPersent
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(filePersentNotify:)
                                                 name:kNotificationFileSendPersent
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyLogoutNotify:)
                                                 name:kNotificationLogout
                                               object:nil];
}

-(UIButton *)iBtn
{
    if (!_iBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(kScreenWidth-60, 0, 45, 25);
        btn.center = CGPointMake(btn.center.x, _mMode.cell_height/2-10);
        btn.layer.cornerRadius = 5;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = Color_Main.CGColor;
        btn.titleLabel.font = kFont(12);
        [btn setTitleColor:Color_Main forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(iBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn];
        _iBtn = btn;
    }
    return _iBtn;
}

-(CALayer *)mPersentBackLayer
{
    if (!_mPersentBackLayer) {
        CALayer *view = [CALayer layer];
        view.backgroundColor = Color_828282.CGColor;
        [self.contentView.layer addSublayer:view];
        _mPersentBackLayer = view;
    }
    return _mPersentBackLayer;
}

-(CALayer *)mPersentLayer
{
    if (!_mPersentLayer) {
        CALayer *view = [CALayer layer];
        view.backgroundColor = Color_Main.CGColor;
        [self.contentView.layer addSublayer:view];
        _mPersentLayer = view;
    }
    return _mPersentLayer;
}

-(UILabel *)mPerPersentlabel
{
    if (!_mPerPersentlabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = kFont(12);
        label.textColor = Color_828282;
        [self.contentView addSubview:label];
        _mPerPersentlabel = label;
    }
    return _mPerPersentlabel;
}

-(UIView *)mLine
{
    if (!_mLine) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = Color_Line;
        [self.contentView addSubview:view];
        _mLine = view;
    }
    return _mLine;
}

-(UILabel *)mCreateDateLabel
{
    if (!_mCreateDateLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = kFont(12);
        label.textColor = Color_828282;
        [self.contentView addSubview:label];
        _mCreateDateLabel = label;
    }
    return _mCreateDateLabel;
}

-(UILabel *)mFileNameLabel
{
    if (!_mFileNameLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = kFont(15);
        label.textColor = Color_5a5a5a;
        label.numberOfLines = 0;
        [self.contentView addSubview:label];
        _mFileNameLabel = label;
    }
    return _mFileNameLabel;
}

-(UIImageView *)mIcon
{
    if (!_mIcon) {
        UIImageView *view = [[UIImageView alloc] init];
        [self.contentView addSubview:view];
        view.tag = View_tag_ImageView;
        _mIcon = view;
    }
    return _mIcon;
}

@end
