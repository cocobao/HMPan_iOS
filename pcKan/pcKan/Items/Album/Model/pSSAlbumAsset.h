//
//  pSSAlbumAsset.h
//  picSimpleSend
//
//  Created by admin on 2016/10/10.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pSSAlbumModel.h"

typedef void (^albumGroupsBlock)(NSMutableArray *groups);
typedef void (^albumAssetsBlock)(NSMutableArray *assets);

@interface pSSAlbumAsset : NSObject
@property (nonatomic,strong) ALAssetsGroup *assetsGroup;
@property (nonatomic,strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic,strong) ALAssetsFilter *assstsFilter;
@property (nonatomic,strong) NSMutableArray *groups;
@property (nonatomic,strong) NSMutableArray *assets;
+(pSSAlbumAsset *)shareInstance;
+(UIImage *)assetsForImageWithPath:(NSString *)path;
-(void)setupAlbumGroups:(albumGroupsBlock)albumGroups;
-(void)setupAlbumAssets:(ALAssetsGroup *)group withAssets:(albumAssetsBlock)albumAssets;
@end
