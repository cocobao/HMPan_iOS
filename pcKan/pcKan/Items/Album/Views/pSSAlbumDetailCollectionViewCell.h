//
//  pSSAlbumDetailCollectionViewCell.h
//  picSimpleSend
//
//  Created by admin on 2016/10/11.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "pSSAlbumModel.h"

@interface pSSAlbumDetailCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) pSSAlbumModel *mMdel;
@property (nonatomic, assign) BOOL isSelect;
-(void)isSelectState:(BOOL)n;
@end
