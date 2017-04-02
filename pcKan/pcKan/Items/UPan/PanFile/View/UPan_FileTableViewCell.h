//
//  UPan_FileTableViewCell.h
//  pcKan
//
//  Created by admin on 2017/3/6.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSBaseTableViewCell.h"
#import "UPan_CellMode.h"

#define CELL_HEIGHT MarginW(35)

@interface UPan_FileTableViewCell : pSSBaseTableViewCell
@property (nonatomic, strong) NSIndexPath *mIndexPath;
@property (nonatomic, weak) UPan_File *mFile;
@property (nonatomic, strong) UPan_CellMode *mMode;

-(void)setMMode:(UPan_CellMode *)mMode file:(UPan_File *)mFile;
@end
