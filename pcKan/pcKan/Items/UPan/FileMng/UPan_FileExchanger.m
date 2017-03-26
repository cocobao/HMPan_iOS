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
#import "MBProgressHUD.h"
#import "pSSAlbumModel.h"
#import "UPan_AssetSender.h"

@interface UPan_FileExchanger ()<NetTcpCallback, FileRecverDelegate, picFileSenderDelegate>
@property (nonatomic, strong) NSMutableDictionary *muFileSendExchanger;
@property (nonatomic, strong) NSMutableDictionary *muFileRecvExchanger;
@property (nonatomic, strong) NSMutableArray *mArrWaitingSendQueue;
@property (nonatomic, strong) NSMutableArray *mAssetWaitSendQueue;
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
        _muFileSendExchanger = [NSMutableDictionary dictionary];
        _muFileRecvExchanger = [NSMutableDictionary dictionary];
        _mAssetWaitSendQueue = [NSMutableArray arrayWithCapacity:30];
        [pssLink addTcpDelegate:self];
    }
    return self;
}

//添加文件接收者
-(void)addFileRecver:(UPan_File *)file fileSize:(NSInteger)fileSize
{
    UPan_FileRecver *fr = [[UPan_FileRecver alloc] initWithFileId:file.fileId filePath:file.filePath fileSize:fileSize];
    fr.m_delegate = self;
    NSString *key = [NSString stringWithFormat:@"%zd", file.fileId];
    self.muFileRecvExchanger[key] = fr;
}

//添加文件发送者
-(void)addSendingFilePath:(NSString *)filePath fileId:(NSInteger)fileId
{
    UPan_FileSender *fs = [[UPan_FileSender alloc] initWithFilePath:filePath fileId:fileId];
    fs.m_delegate = self;
    self.muFileSendExchanger[fs.threadName] = fs;
    [fs start];
    NSLog(@"add file sending:%@", filePath);
}

//添加数据发送者
-(void)addSendingFileData:(NSData *)fileData fileId:(NSInteger)fileId fileName:(NSString *)fileName
{
    UPan_AssetSender *fs = [[UPan_AssetSender alloc] initWithFileData:fileData fileId:fileId fileName:fileName];
    fs.m_delegate = self;
    self.muFileSendExchanger[fs.threadName] = fs;
    [fs start];
    NSLog(@"add file sending:%@", fileName);
}

-(void)loopAssetSender
{
    if (_muFileSendExchanger.allKeys.count > 0 ||
        _mAssetWaitSendQueue.count == 0) {
        return;
    }
    
    pSSAlbumModel *one = [_mAssetWaitSendQueue firstObject];
    [_mAssetWaitSendQueue removeObjectAtIndex:0];
    
    //获取资源图片的详细资源信息
    ALAssetRepresentation* representation = [one.asset defaultRepresentation];
    
    NSString* filename = [representation filename];
    
    //UIImage图片转为NSDate数据
    CGImageRef cgImage = [representation fullResolutionImage];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    NSData *imageData = UIImagePNGRepresentation(image);
    
    WeakSelf(weakSelf);
    [pssLink NetApi_ApplyRecvFile:@{ptl_fileName:filename,ptl_fileSize:@(imageData.length)}
                            block:^(NSDictionary *message, NSError *error) {
                                if (error) {
                                    [weakSelf loopAssetSender];
                                    return;
                                }
                                NSInteger code = [message[ptl_status] integerValue];
                                if (code != _SUCCESS_CODE) {
                                    NSLog(@"%@", message);
                                    [weakSelf loopAssetSender];
                                    return;
                                }
                                NSInteger fileId = [message[ptl_fileId] integerValue];
                                
                                [FileExchanger addSendingFileData:imageData fileId:fileId fileName:filename];
                            }];
}

//添加资源发送队列数据,系统图库文件等,由于没办法用url读出数据
-(void)addSendingAssets:(NSArray *)assets
{
    WeakSelf(weakSelf);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakSelf.mAssetWaitSendQueue addObjectsFromArray:assets];
        [weakSelf loopAssetSender];
    });
}

//生成文件
-(UPan_File *)createFile:(NSString *)fileName
{
    NSArray *arrSrcFile = [UPan_FileMng ContentOfPath:_mNowPath];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", fileName];
    NSArray *arrTmp = [arrSrcFile filteredArrayUsingPredicate:predicate];
    if (arrTmp.count > 0) {
        //创建副本文件
        NSString *noExtenName = [fileName stringByDeletingPathExtension];
        NSString *exten = [fileName pathExtension];
        fileName = [NSString stringWithFormat:@"%@-副本%zd%@%@", noExtenName, arrTmp.count, (exten.length>0)?@".":@"",exten];
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
    if (self.muFileRecvExchanger[key]) {
        UPan_FileRecver *fr = self.muFileRecvExchanger[key];
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
    if (self.muFileRecvExchanger[key]){
        [self.muFileRecvExchanger removeObjectForKey:key];
    }
    NSLog(@"file:%zd recv finish", fileId);
}

#pragma mark - picFileSenderDelegate
-(void)didSendFinish:(NSString *)threadName
{
    if (self.muFileSendExchanger[threadName]) {
        UPan_FileSender *fs = self.muFileSendExchanger[threadName];
        [self.muFileSendExchanger removeObjectForKey:threadName];
        [fs cancel];
        
        if (_muFileSendExchanger.count > 0) {
            
        }
        
        if (_mAssetWaitSendQueue.count > 0) {
            WeakSelf(weakSelf);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [weakSelf loopAssetSender];
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showMessage:@"发送完毕"];
        });
    }
}
@end
