//
//  pSSAlbumAsset.m
//  picSimpleSend
//
//  Created by admin on 2016/10/10.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSAlbumAsset.h"

@implementation pSSAlbumAsset
+(pSSAlbumAsset *)shareInstance
{
    static pSSAlbumAsset *_album = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _album = [[pSSAlbumAsset alloc] init];
        _album.assetsLibrary = [[ALAssetsLibrary alloc] init];
        _album.assstsFilter = [ALAssetsFilter allAssets];
    });
    return _album;
}

-(void)setupAlbumGroups:(albumGroupsBlock)albumGroups
{
    NSMutableArray *groups = @[].mutableCopy;
    ALAssetsLibraryGroupsEnumerationResultsBlock resultBlock = ^(ALAssetsGroup *group, BOOL *stop){
        if (group) {
            [group setAssetsFilter:self.assstsFilter];
            NSInteger groupType = [[group valueForProperty:ALAssetsGroupPropertyType] integerValue];
            if (groupType == ALAssetsGroupSavedPhotos) {
                [groups insertObject:group atIndex:0];
            }
            else
            {
                if (group.numberOfAssets>0) {
                    [groups addObject:group];
                }
            }
        }
        else
        {
            _groups = groups;
            if (albumGroups) {
                albumGroups(groups);
            }
        }
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        _groups = groups;
        if (albumGroups) {
            albumGroups(groups);
        }
    };
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:resultBlock failureBlock:failureBlock];
}

-(void)setupAlbumAssets:(ALAssetsGroup *)group withAssets:(albumAssetsBlock)albumAssets
{
    NSMutableArray *assets = @[].mutableCopy;
    [group setAssetsFilter:self.assstsFilter];
    //相册内资源总数
    NSInteger assetCount = [group numberOfAssets];
    ALAssetsGroupEnumerationResultsBlock resultBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset) {
            pSSAlbumModel *model = [[pSSAlbumModel alloc] initAlbumModel:asset];
            [assets addObject:model];
//            NSString *assetType = [model.asset valueForProperty:ALAssetPropertyType];
//            if ([assetType isEqualToString:ALAssetTypePhoto]) {
//                
//            }
//            else if ([assetType isEqualToString:ALAssetTypeVideo]) {
//                
//            }
        }
        else if (assets.count >= assetCount)
        {
            _assets = assets;
            if (albumAssets) {
                albumAssets(assets);
            }
        };
    };
    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:resultBlock];
}

+(UIImage *)assetsForImageWithPath:(NSString *)path
{
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    __block UIImage *assetImage = nil;
    [lib assetForURL:[NSURL URLWithString:path] resultBlock:^(ALAsset *asset){
        //获取资源图片的详细资源信息
        ALAssetRepresentation* representation = [asset defaultRepresentation];
        
        //获取资源图片的高清图
        CGImageRef cgImage = [representation fullResolutionImage];
        assetImage = [UIImage imageWithCGImage:cgImage];
    }
    failureBlock:^(NSError *error)
    {
        NSLog(@"%@", error);
    }
    ];
    return assetImage;
}
@end
