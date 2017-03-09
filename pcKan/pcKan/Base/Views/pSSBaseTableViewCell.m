//
//  pSSBaseTableViewCell.m
//  picSimpleSend
//
//  Created by admin on 2016/10/10.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSBaseTableViewCell.h"
UITableViewCellStyle cellStyle;

@implementation pSSBaseTableViewCell

-(UITableView *)tableView
{
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version > 7.0) {
        return (UITableView *)self.superview.superview;
    }else{
        return (UITableView *)self.superview;
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:cellStyle reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    if (tableView == nil) {
        return [[self alloc] init];
    }
    cellStyle = UITableViewCellStyleDefault;
    NSString *className = NSStringFromClass([self class]);
    NSString *identifier = [className stringByAppendingString:@"CellID"];
    [tableView registerClass:[self class] forCellReuseIdentifier:identifier];
    return [tableView dequeueReusableCellWithIdentifier:identifier];
}

+(instancetype)cellWithTableView:(UITableView *)tableView style:(UITableViewCellStyle)style
{
    if (tableView == nil) {
        return [[self alloc] init];
    }
    cellStyle = style;
    NSString *className = NSStringFromClass([self class]);
    NSString *identifier = [className stringByAppendingString:@"CellID"];
    [tableView registerClass:[self class] forCellReuseIdentifier:identifier];
    return [tableView dequeueReusableCellWithIdentifier:identifier];
}

+(instancetype)cellWithTableView:(UITableView *)tableView style:(UITableViewCellStyle)style indexPath:(NSIndexPath *)indexPath
{
    if (tableView == nil) {
        return [[self alloc] init];
    }
    cellStyle = style;
    NSString *className = NSStringFromClass([self class]);
    NSString *identifier = [className stringByAppendingString:[NSString stringWithFormat:@"CellID_%ld", indexPath.section]];
    [tableView registerClass:[self class] forCellReuseIdentifier:identifier];
    return [tableView dequeueReusableCellWithIdentifier:identifier];
}
@end
