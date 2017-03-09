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
    if (mFile.fileType == UPan_FT_Dir) {
        self.mCreateDateLabel.text = mFile.createDate;
        self.mIcon.image = [UIImage imageNamed:@"fold"];
    }else{
        [self setFileDateAndSize];
        
        if (mFile.mIcon) {
            self.mIcon.image = mFile.mIcon;
        }else{
            self.mIcon.image = [UIImage imageNamed:@"file"];
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(filePersentNotify:)
                                                 name:kNotificationFilePersent
                                               object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)filePersentNotify:(NSNotification *)notify
{
    NSDictionary *dict = notify.object;
    NSInteger fileId = [dict[ptl_fileId] integerValue];
    if (fileId == self.mFile.fileId) {
        CGFloat persent = [dict[ptl_persent] floatValue];
//        NSLog(@"file persent:%0.3f", persent);
        _mFile.fileSize = [dict[ptl_seek] longLongValue];
        WeakSelf(weakSelf);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (persent<100) {
                weakSelf.mPerPersentlabel.text = [NSString stringWithFormat:@"%0.0f%%", persent];
                [weakSelf updatePersentLine:persent];
            }else{
                weakSelf.mPerPersentlabel.text = @"";
                weakSelf.mPersentLayer.backgroundColor = [UIColor clearColor].CGColor;
            }
            [weakSelf setFileDateAndSize];
        });
    }
}

-(void)updatePersentLine:(CGFloat)persent
{
    CGFloat width = persent/100*CGRectGetWidth(self.mCreateDateLabel.frame);
    if (!_mPersentLayer) {
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
        _mIcon = view;
    }
    return _mIcon;
}

@end
