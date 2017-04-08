//
//  pSSAudioListCell.m
//  pcKan
//
//  Created by admin on 17/4/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSAudioListCell.h"
#import "pSSAvPlayerModule.h"

@interface pSSAudioListCell ()
@property (nonatomic, strong) UIImageView *mIcon;
@property (nonatomic, strong) UILabel *mTitle;
@property (nonatomic, strong) UIView *mLine;
@end

@implementation pSSAudioListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.textColor = Color_5a5a5a;
        self.textLabel.font = kFont(15);
        
        self.mIcon.frame = CGRectMake(10, 0, 30, 30);
        self.mIcon.center = CGPointMake(_mIcon.center.x, CELL_HEIGHT/2);
        
        CGFloat minX = CGRectGetMaxX(_mIcon.frame)+10;
        self.mTitle.frame = CGRectMake(minX, 0, kScreenWidth-minX-15, 30);
        self.mTitle.center = CGPointMake(_mTitle.center.x, _mIcon.center.y);
    }
    return self;
}

-(void)setMMode:(pSSAvMode *)mMode
{
    _mMode = mMode;
    
    if (mMode.mFile.fileId == PSS_AVPLAYER.mAvMode.mFile.fileId) {
        self.backgroundColor = [UIColor whiteColor];
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
    
    NSMutableString *str = [NSMutableString stringWithString:mMode.mTitle];
    if (mMode.mArtwork.length > 0) {
        [str appendFormat:@" - %@", mMode.mArtwork];
    }
    
    self.mIcon.image = mMode.mFile.mIcon;
    self.mTitle.text = str;
}

-(UIView *)mLine
{
    if (!_mLine) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = Color_Line;
        _mLine = view;
    }
    return _mLine;
}

-(UILabel *)mTitle
{
    if (!_mTitle) {
        UILabel *label = [[UILabel alloc] init];
        label.font = kFont(15);
        label.textColor = Color_5a5a5a;
        [self addSubview:label];
        _mTitle = label;
    }
    return _mTitle;
}

-(UIImageView *)mIcon
{
    if (!_mIcon) {
        UIImageView *image = [[UIImageView alloc] init];
        [self.contentView addSubview:image];
        _mIcon = image;
    }
    return _mIcon;
}
@end
