//
//  UPan_FileTableViewCell.m
//  pcKan
//
//  Created by admin on 2017/3/6.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_FileTableViewCell.h"

@interface UPan_FileTableViewCell ()
@property (nonatomic, strong) UIImageView *mIcon;
@property (nonatomic, strong) UILabel *mFileNameLabel;
@property (nonatomic, strong) UILabel *mCreateDateLabel;
@property (nonatomic, strong) UILabel *mPerPersentlabel;
@property (nonatomic, strong) UIView *mLine;
@property (nonatomic, strong) CALayer *mPersentLayer;
@property (nonatomic, strong) CALayer *mPersentBackLayer;
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
    
    if (mFile.fileType != UPan_FT_Dir) {
        self.accessoryType = UITableViewCellAccessoryDetailButton;
    }else{
        self.accessoryType = UITableViewCellAccessoryNone;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(filePersentNotify:)
                                                 name:kNotificationFileRecvPersent
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(filePersentNotify:)
                                                 name:kNotificationFileSendPersent
                                               object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//接收文件百分比以及速率
-(void)filePersentNotify:(NSNotification *)notify
{
    NSDictionary *dict = notify.object;
    NSInteger fileId = [dict[ptl_fileId] integerValue];
    if (fileId == self.mFile.fileId) {
        CGFloat persent = [dict[ptl_persent] floatValue];
        CGFloat speed = [dict[ptl_speed] floatValue];
        if (dict[ptl_seek]) {
            _mFile.fileSize = [dict[ptl_seek] longLongValue];
        }
        WeakSelf(weakSelf);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setFileDateAndSize];
            
            if (persent<100) {
                NSString *sizeperSec = [pSSCommodMethod exchangeSize:speed];
                weakSelf.mPerPersentlabel.text = [NSString stringWithFormat:@"%0.0f%%  %@/s", persent, sizeperSec];
                [weakSelf updatePersentLine:persent];
            }else{
                weakSelf.mPerPersentlabel.text = @"";
                [weakSelf.mPersentLayer removeFromSuperlayer];
                [weakSelf.mPersentBackLayer removeFromSuperlayer];
                
                [weakSelf.mFile knowFileType];
                if (weakSelf.mFile.fileType != UPan_FT_UnKnownFile) {
                    [weakSelf.tableView reloadData];
                }
            }
        });
    }
}

-(void)updatePersentLine:(CGFloat)persent
{
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
}

-(void)setFileDateAndSize
{
    CGFloat fileSize = _mFile.fileSize;
    NSString *muString = [NSString stringWithFormat:@"%@  %@", _mFile.createDate, [pSSCommodMethod exchangeSize:fileSize]];
    
    self.mCreateDateLabel.text = muString;
}

-(CALayer *)mPersentBackLayer
{
    if (!_mPersentBackLayer) {
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = Color_828282.CGColor;
        [self.contentView.layer addSublayer:layer];
        _mPersentBackLayer = layer;
    }
    return _mPersentBackLayer;
}

-(CALayer *)mPersentLayer
{
    if (!_mPersentLayer) {
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = Color_Main.CGColor;
        [self.contentView.layer addSublayer:layer];
        _mPersentLayer = layer;
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
