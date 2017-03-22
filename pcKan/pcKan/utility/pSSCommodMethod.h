//
//  pSSCommodMethod.h
//  picSimpleSend
//
//  Created by admin on 2016/10/10.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface pSSCommodMethod : NSObject
//验证是否有访问相册权限
+(BOOL)sysPhotoLibraryIsAuthok;
//获取系统版本
+ (float)getSystemVersion;
+ (float)getNavBarHight;
//json转本地结构
+ (id)jsonObjectWithJsonData:(NSData *)jsonData;
//字典转Json数据
+(NSData *)dictionaryToJsonData:(NSDictionary *)dict;
+(NSString *)dictionaryToString:(NSDictionary *)dict;

+ (CGFloat)adjustGapW:(CGFloat)gap;
+ (CGFloat)adjustGapH:(CGFloat)gap;

+(BOOL)isKindOfNumString:(NSString *)str;

//获取本地IP地址
+ (NSString *)localIPAdress;

+ (NSString *)inet_ntoa:(unsigned int)addr;

+(NSString *)dateToString:(NSDate *)date;

+(UIImage *)imageOfPath:(NSString *)filePath;

//获取图片的缩略图
+(UIImage *)imageShotcutOfPath:(NSString *)filePath w:(NSInteger)w h:(NSInteger)h;
+(UIImage *)imageShotcutOfImage:(UIImage *)image w:(NSInteger)w h:(NSInteger)h;

//获取视频的预览图
+(UIImage*)thumbnailImageForVideo:(NSURL *)videoURL;

//转换字节型大小为B/M/G/T形式的大小
+(NSString *)exchangeSize:(double)size;

//获取图片数据的图片格式
+ (NSString *)contentTypeForImageData:(NSData *)data;

//获取图片的容量大小
+(NSInteger)imageDataSize:(UIImage *)image;

//获取图片资源的名字
+(NSString *)nameOfAsset:(ALAsset *)asset;

//获取图片资源的数据
+(NSData *)dataOfAsset:(ALAsset *)asset;
@end
