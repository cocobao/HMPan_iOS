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
#import "UPan_CurrentPathFileMng.h"
#import "utility.h"

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFileNotify:) name:kNotificationDeleteFile object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//添加文件接收者
-(void)addFileRecver:(UPan_File *)file fileSize:(NSInteger)fileSize pcFilePath:(NSString *)pcFilePath
{
    UPan_FileRecver *fr = [[UPan_FileRecver alloc] initWithFileId:file.fileId filePath:file.filePath pcFilePath:pcFilePath fileSize:fileSize];
    fr.m_delegate = self;
    NSString *key = [NSString stringWithFormat:@"%zd", file.fileId];
    self.muFileRecvExchanger[key] = fr;
    
    [fr reApply];
}

//添加文件发送者
-(void)addSendingFilePath:(UPan_File *)file pcFileId:(NSInteger)pcFileId
{
    UPan_FileSender *fs = [[UPan_FileSender alloc] initWithFilePath:file.filePath fileId:pcFileId];
    fs.m_delegate = self;
    self.muFileSendExchanger[fs.threadName] = fs;
    [fs start];
    file.exchangingState = EXCHANGE_ING;
    MITLog(@"add file sending:%@", file.filePath);
}

//添加数据发送者
-(void)addSendingFileData:(NSData *)fileData fileId:(NSInteger)fileId fileName:(NSString *)fileName
{
    UPan_AssetSender *fs = [[UPan_AssetSender alloc] initWithFileData:fileData fileId:fileId fileName:fileName];
    fs.m_delegate = self;
    self.muFileSendExchanger[fs.threadName] = fs;
    [fs start];
    MITLog(@"add file sending:%@", fileName);
}

//移除接受者
-(void)removeFileRecver:(NSInteger)fileId
{
    NSString *key = [NSString stringWithFormat:@"%zd", fileId];
    
    if (self.muFileRecvExchanger[key]) {
        [self.muFileRecvExchanger removeObjectForKey:key];
        
        MITLog(@"remove file recver, key:%@", key);
    }
}

//删除文件通知
-(void)deleteFileNotify:(NSNotification *)notify
{
    UPan_File *file = (UPan_File *)notify.object;
    [self removeFileRecver:file.fileId];
}

//文件是否在传输中
-(BOOL)isFileExchanging:(NSInteger)fileId
{
    NSArray *arrKeys = [_muFileRecvExchanger allKeys];
    if (arrKeys.count == 0) {
        return NO;
    }
    
    for (NSString *key in arrKeys) {
        UPan_FileRecver *fr = _muFileRecvExchanger[key];
        if (fr.fileId == fileId) {
            if (!fr.isSuspend) {
                return YES;
            }
            break;
        }
    }
    return NO;
}

-(void)recoverAllRecver
{
    NSArray *allKey = [self.muFileRecvExchanger allKeys];
    for (NSString *key in allKey) {
        UPan_FileRecver *fr = self.muFileRecvExchanger[key];
        fr.isSuspend = NO;
        [fr reApply];
        
        MITLog(@"recover recver, key:%@", key);
    }
}

//恢复接收传输
-(void)recoverRecver:(NSDictionary *)infoDict
{
    NSString *key = [NSString stringWithFormat:@"%zd", [infoDict[ptl_fileId] integerValue]];
    UPan_FileRecver *fr = nil;
    if (self.muFileRecvExchanger[key]) {
        fr = self.muFileRecvExchanger[key];
        fr.isSuspend = NO;
    }else{
        fr = [[UPan_FileRecver alloc] initWithInfoDict:infoDict];
        self.muFileRecvExchanger[key] = fr;
    }
    [fr reApply];
}

//暂停接收传输
-(void)puseRecver:(NSInteger)fileId
{
    NSString *key = [NSString stringWithFormat:@"%zd", fileId];
    
    if (self.muFileRecvExchanger[key]){
        UPan_FileRecver *fr = self.muFileRecvExchanger[key];
        fr.isSuspend = YES;
    }
}

//遍历Asset资源发送
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
                                    MITLog(@"%@", message);
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
        //已存在该文件，重命名为副本
        NSString *noExtenName = [fileName stringByDeletingPathExtension];
        NSString *exten = [fileName pathExtension];
        fileName = [NSString stringWithFormat:@"%@-副本%zd%@%@", noExtenName, arrTmp.count, (exten.length>0)?@".":@"",exten];
    }
    //创建文件
    NSString *createPath = [_mNowPath stringByAppendingPathComponent:fileName];
    [UPan_FileMng createFile:createPath];
    NSDictionary *fileAtts = [UPan_FileMng fileAttriutes:createPath];
    if (!fileAtts) {
        return nil;
    }
    
    //创建保存传输信息文件
    NSString *infoFile = [NSString stringWithFormat:@"%@/%@.hmf", _mNowPath, fileName];
    [UPan_FileMng createFile:infoFile];
    
    //创建文件结构对象
    UPan_File *uFile = [[UPan_File alloc] initWithPath:createPath Atts:fileAtts];
    uFile.exchangingState = EXCHANGE_ING;
    return uFile;
}

#pragma mark - NetTcpCallback
//接收文件数据
- (void)NetRecvFileData:(NSData *)data fileId:(unsigned long long)fileId
{
//    MITLog(@"file size:%zd, fileId:%zd", data.length, fileId);
    NSString *key = [NSString stringWithFormat:@"%zd", fileId];
    if (self.muFileRecvExchanger[key]) {
        UPan_FileRecver *fr = self.muFileRecvExchanger[key];
        [fr writeFileData:data];
    }else{
        MITLog(@"file recver has been remove");
    }
}

//接收到指令处理
- (void)NetTcpCallback:(NSDictionary *)receData error:(NSError *)error
{
    NSInteger comType = [receData[PSS_CMD_TYPE] integerValue];
    if (comType == emPssProtocolType_ApplySendFile) {
        NSString *fileName = receData[ptl_fileName];
        NSString *filePath = receData[ptl_filePath];
        NSInteger fileSize = [receData[ptl_fileSize] integerValue];
        NSString *strSize = [pSSCommodMethod exchangeSize:fileSize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示"
                                                           message:[NSString stringWithFormat:@"请求接收文件:%@,大小:%@", fileName, strSize]
                                                          delegate:nil
                                                 cancelButtonTitle:@"取消"
                                                 otherButtonTitles:@"确定", nil];
            WeakSelf(weakSelf);
            [view setCompleteBlock:^(UIAlertView *alertView, NSInteger btnIndex) {
                if (btnIndex == 1) {
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        //内存空间判断
                        if (fileSize/1024 > [utility availableMemory]-50) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [MBProgressHUD showMessage:@"内存空间不足"];
                            });
                            return;
                        }
                        
                        //生成文件
                        UPan_File *uFile = [weakSelf createFile:fileName];
                        
                        if (!uFile) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [MBProgressHUD showMessage:@"创建文件失败"];
                            });
                            return;
                        }
                        //通知新建文件
                        NSNotificationCenter *ntf = [NSNotificationCenter defaultCenter];
                        [ntf postNotificationName:kNotificationFileCreate object:uFile];

                        MITLog(@"create fileId:%zd, fileSize:%zd", uFile.fileId, fileSize);
                        [weakSelf addFileRecver:uFile fileSize:fileSize pcFilePath:filePath];
    //                    [pssLink NetApi_ApplySendFileAck:filePath fileId:uFile.fileId];
                    });
                }
            }];
        
            [view show];
        });
    }
}

#pragma mark - FileRecverDelegate
//文件接收成功
-(void)didRecvFileFinish:(NSInteger)fileId
{
    NSString *key = [NSString stringWithFormat:@"%zd", fileId];
    if (self.muFileRecvExchanger[key]){
        [self.muFileRecvExchanger removeObjectForKey:key];
        
        UPan_File *file = [CurPathFile fileWithFileId:fileId];
        if (!file) {
            return;
        }
        file.exchangingState = EXCHANGE_COM;
        file.exchangeInfo = nil;
        [file knowFileType];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFileRecvFinish object:file];
    }
    MITLog(@"file:%zd recv finish", fileId);
}

#pragma mark - picFileSenderDelegate
//文件发送完成
-(void)didSendFinish:(NSString *)threadName
{
    if (self.muFileSendExchanger[threadName]) {
        UPan_FileSender *fs = self.muFileSendExchanger[threadName];
        [self.muFileSendExchanger removeObjectForKey:threadName];
        [fs cancel];
        
        UPan_File *file = [CurPathFile fileWithFileId:fs.mFileId];
        if (file) {
            file.exchangingState = EXCHANGE_COM;
        }
        
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
