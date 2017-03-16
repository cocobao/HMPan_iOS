//
//  pSSAlbumModel.m
//  picSimpleSend
//
//  Created by admin on 2016/10/10.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSAlbumModel.h"

@implementation pSSAlbumModel
-(instancetype)initAlbumModel:(ALAsset *)asset
{
    self = [super init];
    if (self) {
        _asset = asset;
        _isSelect = NO;
        _assetType = [asset valueForProperty:ALAssetPropertyType];
    }
    return self;
}

@end
