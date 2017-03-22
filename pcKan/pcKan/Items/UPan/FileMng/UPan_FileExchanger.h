//
//  UPan_FileRecvMgr.h
//  pcKan
//
//  Created by admin on 2017/3/9.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPan_File.h"

#define FileExchanger [UPan_FileExchanger shareInstance]

@interface UPan_FileExchanger : NSObject
@property (nonatomic, strong) NSString *mNowPath;
+ (id)shareInstance;
-(void)addFileRecver:(UPan_File *)file fileSize:(NSInteger)fileSize;
-(void)addSendingFilePath:(NSString *)filePath fileId:(NSInteger)fileId;
//添加数据发送者
-(void)addSendingFileData:(NSData *)fileData fileId:(NSInteger)fileId fileName:(NSString *)fileName;

//添加资源发送队列数据,系统图库文件等,由于没办法用url读出数据
-(void)addSendingAssets:(NSArray *)assets;
@end
