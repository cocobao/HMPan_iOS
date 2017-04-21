//
//  pSSAlbumTableViewCell.h
//  picSimpleSend
//
//  Created by admin on 2016/10/10.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSBaseTableViewCell.h"
#import "pSSAlbumModel.h"

#define CELL_HEIGHT 90

@interface pSSAlbumTableViewCell : pSSBaseTableViewCell
@property (nonatomic,strong) ALAssetsGroup *mAssetGroup;
@end
