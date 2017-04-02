//
//  pSSCommodMethod.m
//  picSimpleSend
//
//  Created by admin on 2016/10/10.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSCommodMethod.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation pSSCommodMethod
+ (NSString *)inet_ntoa:(unsigned int)addr
{
    struct in_addr ipAddr = {0};
    ipAddr.s_addr = addr;
    return [NSString stringWithUTF8String:inet_ntoa(ipAddr)];
}

+ (NSString *)localIPAdress
{
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}

+(BOOL)sysPhotoLibraryIsAuthok
{
    BOOL isauthStatusOk = YES;

    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        isauthStatusOk = NO;
    }
    if (!isauthStatusOk) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"请在iPhone的(设置-隐私-相机)设置允许使用摄像机"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    
    return isauthStatusOk;
}

+ (float)getSystemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
    
}

+ (float)getNavBarHight
{
    if ([pSSCommodMethod getSystemVersion] >= 7.0) {
        return 64;
    }
    else{
        return 44;
    }
}

+ (id)jsonObjectWithJsonData:(NSData *)jsonData{
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization
                     JSONObjectWithData:jsonData
                     options:NSJSONReadingAllowFragments
                     error:&error];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }
    return nil;
}

+(NSData *)dictionaryToJsonData:(NSDictionary *)dict
{
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    }
    return nil;
}

+(NSString *)dictionaryToString:(NSDictionary *)dict
{
    if(dict == nil) return nil;
    
    NSError *error;
    NSData *strData = [NSJSONSerialization dataWithJSONObject: dict options: 0 error: &error];
    
    if (strData != nil && error == nil) {
        
        return [[NSString alloc] initWithData: strData encoding: NSUTF8StringEncoding];
    }
    
    return nil;
}

+ (CGFloat)adjustGapW:(CGFloat)gap{
    if (480 == kScreenHeight) {//4s及以前
        return gap *0.85;
    }
    else if (568 == kScreenHeight) {//5,5s,5s
        return gap *0.85;
    }
    else if (667 == kScreenHeight) {//6
        return gap;
    }
    else if (736 == kScreenHeight) {//6p
        return gap * 1.2;
    }
    return gap;
}

+ (CGFloat)adjustGapH:(CGFloat)gap{
    if (480 == kScreenHeight) {//4s及以前
        return gap *0.72;
    }
    else if (568 == kScreenHeight) {//5,5s,5s
        return gap *0.85;
    }
    else if (667 == kScreenHeight) {//6
        return gap;
    }
    else if (736 == kScreenHeight) {//6p
        return gap * 1.2;
    }
    return gap;
}

-(NSString *)asciiData2String:(NSData *)data
{
    if (data == nil) {
        return nil;
    }
    
    char *p = (char *)[data bytes];
    for (int i = 0; i < data.length; i++) {
        if (0x30 < p[i] && p[i] < 0x39) {
            
        }
    }
    return nil;
}

+(BOOL)isKindOfNumString:(NSString *)str
{
    for (int i = 0; i < str.length; i++) {
        char c = [str characterAtIndex:i];
        if (c < 0x30 || c > 0x39) {
            return NO;
        }
    }
    return YES;
}

+(NSDate *)GMTtoLocalData:(NSDate *)date
{
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone]; // 获取的是系统的时区
    NSInteger interval = [timeZone secondsFromGMTForDate: date];// local时间距离GMT的秒数
    return [date dateByAddingTimeInterval: interval];
}

+(NSString *)dateToString:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return[dateFormatter stringFromDate:date];
}

+(UIImage *)imageOfPath:(NSString *)filePath
{
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    if (!imageData) {
        return nil;
    }
    UIImage *image = nil;
    image = [UIImage imageWithData:imageData];
    return image;
}

//图片缩略图
+(UIImage *)imageShotcutOfPath:(NSString *)filePath w:(NSInteger)w h:(NSInteger)h
{
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    if (!imageData) {
        return nil;
    }
    UIImage *image = nil;
    image = [UIImage imageWithData:imageData];
    
    UIGraphicsBeginImageContext(CGSizeMake(w,h));
    [image drawInRect:CGRectMake(0, 0, w, h)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

//图片缩略图
+(UIImage *)imageShotcutOfImage:(UIImage *)image w:(NSInteger)w h:(NSInteger)h
{
    UIGraphicsBeginImageContext(CGSizeMake(w,h));
    [image drawInRect:CGRectMake(0, 0, w, h)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

//获取视频文件的一帧作为封面
+(UIImage*) thumbnailImageForVideo:(NSURL *)videoURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    if (!asset) {
        return nil;
    }
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = 0;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    CGImageRelease(thumbnailImageRef);
    return thumbnailImage;
}

//转换容量显示形式
+(NSString *)exchangeSize:(double)size
{
    NSString *sizeStr = nil;
    if (size < 1024) {
        sizeStr = [NSString stringWithFormat:@"%0.2fB", size];
    }else{
        size = size/1024;
        if (size < 1024) {
            sizeStr = [NSString stringWithFormat:@"%0.2fKB", size];
        }else{
            size = size/1024;
            if (size < 1024) {
                sizeStr = [NSString stringWithFormat:@"%0.2fMB", size];
            }else{
                size = size/1024;
                sizeStr = [NSString stringWithFormat:@"%0.2fGB", size];
            }
        }
    }
    return sizeStr;
}

+ (NSString *)contentTypeForImageData:(NSData *)data
{
    uint8_t c;
    
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
            if ([data length] < 12) {
                return nil;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            
            return nil;
    }
    return nil;
}

//获取图片的容量大小
+(NSInteger)imageDataSize:(UIImage *)image
{
    NSData *data = UIImagePNGRepresentation(image);
    return data.length;
}

+(NSString *)nameOfAsset:(ALAsset *)asset
{
    return [[asset defaultRepresentation] filename];
}

+(NSData *)dataOfAsset:(ALAsset *)asset
{
    //获取资源图片的详细资源信息
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    
    //UIImage图片转为NSDate数据
    CGImageRef cgImage = [representation fullResolutionImage];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    return UIImagePNGRepresentation(image);
}

static uint32_t randomMessageId;

+(void)initRandomId
{
    randomMessageId = 2 + arc4random() % 10000;
}

+(uint32_t)getRandomMessageID
{
    @synchronized(self) {
        randomMessageId += 2;
    }
    return randomMessageId;
}

//文件头信息，返回文件类型
+(NSString *)fileHeadTypeWithFile:(NSString *)filePath
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *headData = [fileHandle readDataOfLength:10];
    [fileHandle closeFile];
    if (!headData) {
        return @"";
    }
    uint8_t *b = (uint8_t *)[headData bytes];

    //Adobe Photoshop, psd文件, 38425053
    if (*b == 0x38 &&
        *(b+1) == 0x42 &&
        *(b+2) == 0x50 &&
        *(b+3) == 0x53) {
        return @"psd";
    }
    
    //XML (xml), 3C3F786D6C
    if (*b == 0x3C &&
        *(b+1) == 0x3F &&
        *(b+2) == 0x78 &&
        *(b+3) == 0x6D &&
        *(b+4) == 0x6C ) {
        return @"xml";
    }
    
    //HTML (html), 68746D6C3E
    if (*b == 0x68 &&
        *(b+1) == 0x74 &&
        *(b+2) == 0x6D &&
        *(b+3) == 0x6C &&
        *(b+4) == 0x3E ) {
        return @"html";
    }
    
    //Adobe Acrobat (pdf), 255044462D312E
    if (*b == 0x25 &&
        *(b+1) == 0x50 &&
        *(b+2) == 0x44 &&
        *(b+3) == 0x46 &&
        *(b+4) == 0x2D &&
        *(b+1) == 0x31 &&
        *(b+2) == 0x2E) {
        return @"pdf";
    }
    
    //ZIP Archive (zip), 504B0304
    if (*b == 0x50 &&
        *(b+1) == 0x4b &&
        *(b+2) == 0x03 &&
        *(b+3) == 0x04) {
        return @"zip";
    }
    
    //RAR Archive (rar)，文件头：52617221
    if (*b == 0x52 &&
        *(b+1) == 0x61 &&
        *(b+2) == 0x72 &&
        *(b+3) == 0x21) {
        return @"rar";
    }
    return @"";
}
@end
