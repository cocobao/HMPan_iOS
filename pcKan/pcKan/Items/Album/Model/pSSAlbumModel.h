//
//  pSSAlbumModel.h
//  picSimpleSend
//
//  Created by admin on 2016/10/10.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface pSSAlbumModel : NSObject
@property (nonatomic,strong) ALAsset *asset;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong,readonly) NSString *assetType;
@property (nonatomic) BOOL isSelect;
-(instancetype)initAlbumModel:(ALAsset *)asset;
@end
