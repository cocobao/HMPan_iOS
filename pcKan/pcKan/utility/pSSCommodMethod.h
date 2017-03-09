//
//  pSSCommodMethod.h
//  picSimpleSend
//
//  Created by admin on 2016/10/10.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface pSSCommodMethod : NSObject
+(BOOL)sysPhotoLibraryIsAuthok;
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

+(UIImage *)imageShotcutOfPath:(NSString *)filePath w:(NSInteger)w h:(NSInteger)h;
+(UIImage *)imageShotcutOfImage:(UIImage *)image w:(NSInteger)w h:(NSInteger)h;

+(UIImage*)thumbnailImageForVideo:(NSURL *)videoURL;

+(NSString *)exchangeSize:(double)size;

+ (NSString *)contentTypeForImageData:(NSData *)data;
@end
