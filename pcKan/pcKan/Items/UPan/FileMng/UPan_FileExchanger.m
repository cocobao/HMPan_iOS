//
//  UPan_FileRecvMgr.m
//  pcKan
//
//  Created by admin on 2017/3/9.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_FileExchanger.h"
#import "UPan_FileRecver.h"
#import "UPan_FileSender.h"
#import "UIAlertView+RWBlock.h"
#import "UPan_FileMng.h"

@interface UPan_FileExchanger ()<NetTcpCallback, FileRecverDelegate, picFileSenderDelegate>
@property (nonatomic, strong) NSMutableDictionary *muFileExchangers;
@end

@implementation UPan_FileExchanger
__strong static id sharedInstance = nil;
+ (id)shareInstance
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _muFileExchangers = [NSMutableDictionary dictionary];
        [pssLink addTcpDelegate:self];
    }
    return self;
}

-(void)addFileRecver:(UPan_File *)file fileSize:(NSInteger)fileSize
{
    UPan_FileRecver *fr = [[UPan_FileRecver alloc] initWithFileId:file.fileId filePath:file.filePath fileSize:fileSize];
    fr.m_delegate = self;
    NSString *key = [NSString stringWithFormat:@"%zd", file.fileId];
    self.muFileExchangers[key] = fr;
}

-(void)addSendingFilePath:(NSString *)filePath fileId:(NSInteger)fileId
{
    UPan_FileSender *fs = [[UPan_FileSender alloc] initWithFilePath:filePath fileId:fileId];
    fs.m_delegate = self;
    self.muFileExchangers[fs.threadName] = fs;
    NSLog(@"add file sending:%@", filePath);
}

//生成文件
-(UPan_File *)createFile:(NSString *)fileName
{
    NSArray *arrSrcFile = [UPan_FileMng ContentOfPath:_mNowPath];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", fileName];
    NSArray *arrTmp = [arrSrcFile filteredArrayUsingPredicate:predicate];
    if (arrTmp.count > 0) {
        //创建副本文件
        fileName = [NSString stringWithFormat:@"%@-副本%zd", fileName, arrTmp.count];
    }
    
    NSString *createPath = [_mNowPath stringByAppendingPathComponent:fileName];
    [UPan_FileMng createFile:createPath];
    NSDictionary *fileAtts = [UPan_FileMng fileAttriutes:createPath];
    if (!fileAtts) {
        return nil;
    }
    
    UPan_File *uFile = [[UPan_File alloc] initWithPath:createPath Atts:fileAtts];
    return uFile;
}

#pragma mark - NetTcpCallback
- (void)NetRecvFileData:(NSData *)data fileId:(unsigned long long)fileId
{
//    NSLog(@"file size:%zd, fileId:%zd", data.length, fileId);
    NSString *key = [NSString stringWithFormat:@"%zd", fileId];
    if (self.muFileExchangers[key]) {
        UPan_FileRecver *fr = self.muFileExchangers[key];
        [fr writeFileData:data];
    }
}

- (void)NetTcpCallback:(NSDictionary *)receData error:(NSError *)error
{
    NSInteger comType = [receData[PSS_CMD_TYPE] integerValue];
    if (comType == emPssProtocolType_ApplySendFile) {
        NSString *fileName = receData[ptl_fileName];
        NSString *filePath = receData[ptl_filePath];
        NSInteger fileSize = [receData[ptl_fileSize] integerValue];
        NSString *strSize = [pSSCommodMethod exchangeSize:fileSize];
        
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示"
                                                       message:[NSString stringWithFormat:@"请求接收文件:%@,大小:%@", fileName, strSize]
                                                      delegate:nil
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"确定", nil];
        WeakSelf(weakSelf);
        [view setCompleteBlock:^(UIAlertView *alertView, NSInteger btnIndex) {
            if (btnIndex == 1) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    //这里待实现内存空间判断
                    
                    //生成文件
                    UPan_File *uFile = [weakSelf createFile:fileName];
                    NSNotificationCenter *ntf = [NSNotificationCenter defaultCenter];
                    [ntf postNotificationName:kNotificationFileCreate object:uFile];
                    
                    if (!uFile) {
                        return;
                    }

                    NSLog(@"create fileId:%zd, fileSize:%zd", uFile.fileId, fileSize);
                    [weakSelf addFileRecver:uFile fileSize:fileSize];
                    [pssLink NetApi_ApplySendFileAck:filePath fileId:uFile.fileId];
                });
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [view show];
        });
    }
}

#pragma mark - FileRecverDelegate
-(void)didRecvFileFinish:(NSInteger)fileId
{
    NSString *key = [NSString stringWithFormat:@"%zd", fileId];
    if (self.muFileExchangers[key]){
        [self.muFileExchangers removeObjectForKey:key];
    }
    NSLog(@"file:%zd recv finish", fileId);
}

#pragma mark - picFileSenderDelegate
-(void)didSendFinish:(NSString *)threadName
{
    if (self.muFileExchangers[threadName]) {
        UPan_FileSender *fs = self.muFileExchangers[threadName];
        [self.muFileExchangers removeObjectForKey:threadName];
        
        [fs cancel];
    }
}
@end
