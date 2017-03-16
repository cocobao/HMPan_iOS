//
//  UPan_FileMng.h
//  pcKan
//
//  Created by admin on 2017/3/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPan_FileMng : NSObject
+(NSString *)hmPath;

+(NSString *)dirDocument;

+(NSString *)dirHome;

//获取Library目录
+(NSString *)dirLib;

//获取Cache目录
+(NSString *)dirCache;

//获取Tmp目录
+(NSString *)dirTmp;

+(NSArray *)ContentOfPath:(NSString *)path;

+(NSArray *)DocumentPathSource;

+(NSArray *)CachePathSource;

//文件属性
+(NSDictionary *)fileAttriutes:(NSString *)file;

+(BOOL)createDir:(NSString *)path;

//创建文件
+(void)createFile:(NSString *)path;

//删除文件
+(void)deleteFile:(NSString *)path;

//读文件数据
+(NSData *)readFile:(NSString *)path;

//写数据到文件
+(void)writeFile:(NSString *)path data:(NSData *)data;

//根据路径提取文件名称
+(NSString *)fileNameByPath:(NSString *)path;

+(BOOL)isFileExist:(NSString *)filePath;

//文件重命名
+(BOOL)renameFileName:(NSString *)oldName toNewName:(NSString *)newName atPath:(NSString *)path;
@end
