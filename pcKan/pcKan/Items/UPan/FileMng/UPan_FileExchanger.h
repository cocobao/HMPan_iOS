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

-(void)addSendingFilePath:(UPan_File *)file;
//添加数据发送者
-(void)addSendingFileData:(NSData *)fileData fileId:(NSInteger)fileId fileName:(NSString *)fileName;

//添加资源发送队列数据,系统图库文件等,由于没办法用url读出数据
-(void)addSendingAssets:(NSArray *)assets;

-(void)removeFileRecver:(NSInteger)fileId;

-(BOOL)isFileExchanging:(NSInteger)fileId;

//恢复所有接收传输
-(void)recoverAllRecver;

//恢复接收传输
-(void)recoverRecver:(NSDictionary *)infoDict;

//暂停接收传输
-(void)puseRecver:(NSInteger)fileId;
@end
