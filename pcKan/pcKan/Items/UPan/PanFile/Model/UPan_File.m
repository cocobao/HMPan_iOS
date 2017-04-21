//
//  UPan_File.m
//  pcKan
//
//  Created by admin on 2017/3/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_File.h"
#import <AVFoundation/AVFoundation.h>
#import "UPan_FileMng.h"
#import "HBImageTypeSizeUtil.h"

@implementation UPan_File
-(instancetype)initWithPath:(NSString *)path Atts:(NSDictionary *)atts
{
    self = [super init];
    if (self) {
        _fileName = [UPan_FileMng fileNameByPath:path];
        _filePath = path;
        _fileSize = [atts[NSFileSize] longLongValue];
        _fileType = UPan_FT_Ukn;
        _fileId = [atts[NSFileSystemFileNumber] integerValue];
        _attsFileType = atts[NSFileType];
        _exchangingState = EXCHANGE_COM;
        
        NSDate *date = [pSSCommodMethod GMTtoLocalData:atts[NSFileCreationDate]];
        _createDate = [pSSCommodMethod dateToString:date];
        
        [self knowFileType];
    }
    return self;
}

//文件类型分类
-(void)knowFileType
{
    do {
        if ([self ifDirType])       break;
        if ([self ifDocType])       break;
        if ([self ifCompressType])  break;
        if ([self ifImgType])       break;
        if ([self ifVideoType])     break;
        if ([self ifAudioType])     break;
    } while (0);
    
    [self setIcon];
}

//是否为文件夹类型
-(BOOL)ifDirType
{
    if (_attsFileType == NSFileTypeDirectory) {
        _fileType = UPan_FT_Dir;
        return YES;
    }
    return NO;
}

//是否为文档类型
-(BOOL)ifDocType
{
    if ([_fileName hasSuffix:@".doc"] ||
        [_fileName hasSuffix:@".docx"]) {
        _fileType = UPan_FT_Word;
        return YES;
    }
    
    if ([_fileName hasSuffix:@".ppt"]) {
        _fileType = UPan_FT_Ppt;
        return YES;
    }
    
    if ([_fileName hasSuffix:@".pdf"]) {
        _fileType = UPan_FT_Pdf;
        return YES;
    }
    
    if ([_fileName hasSuffix:@".xls"]) {
        _fileType = UPan_FT_Xls;
        return YES;
    }
    
    if ([_fileName hasSuffix:@".txt"]) {
        _fileType = UPan_FT_Txt;
        return YES;
    }
    
    if ([_fileName hasSuffix:@".h"]) {
        _fileType = UPan_FT_H;
        return YES;
    }
    
    if ([_fileName hasSuffix:@".m"]) {
        _fileType = UPan_FT_M;
        return YES;
    }
    
    if ([_fileName hasSuffix:@".psd"]) {
        _fileType = UPan_FT_Psd;
        return YES;
    }
    
    if ([_fileName hasSuffix:@".xml"]) {
        _fileType = UPan_FT_Xml;
        return YES;
    }
    
    if ([_fileName hasSuffix:@".html"]) {
        _fileType = UPan_FT_Html;
        return YES;
    }
    return NO;
}

//是否为压缩文件
-(BOOL)ifCompressType
{
    if (_fileSize > 10) {
        if ([_fileName hasSuffix:@".rar"] ||
            [_fileName hasSuffix:@".zip"]) {
            NSString *extend = [pSSCommodMethod fileHeadTypeWithFile:_filePath];
            
            if ([extend isEqualToString:@"rar"]) {
                _fileType = UPan_FT_Zip;
                return YES;
            }
            
            if ([extend isEqualToString:@"zip"]) {
                _fileType = UPan_FT_Rar;
                return YES;
            }
        }
    }
    
    return NO;
}

//是否为图片类型
-(BOOL)ifImgType
{
    //根据文件头信息来确定是否图片文件
    HBImageType t = [HBImageTypeSizeUtil imageTypeOfFilePath:_filePath];
    if (t == HBImageTypeJPG ||
        t == HBImageTypePNG ||
        t == HBImageTypeBMP) {
        _fileType = UPan_FT_Img;
        return YES;
    }
    return NO;
}

//是否为视频类型
-(BOOL)ifVideoType
{
    //文件是否有视频轨道，以此来判断是否视频文件
    AVAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:_filePath] options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if ([tracks count] > 0) {
        _fileType = UPan_FT_Mov;
        return YES;
    }else{
        if ([_fileName hasSuffix:@"flv"] ||
            [_fileName hasSuffix:@"FLV"] ||
            [_fileName hasSuffix:@"avi"] ||
            [_fileName hasSuffix:@"AVI"] ||
            [_fileName hasSuffix:@"rmvb"] ||
            [_fileName hasSuffix:@"RMVB"] ||
            [_fileName hasSuffix:@"MKV"] ||
            [_fileName hasSuffix:@"mkv"] ||
            [_fileName hasSuffix:@"mp4"]
            ) {
            _fileType = UPan_FT_Mov;
            return YES;
        }
    }
    
    return NO;
}

//是否为音频文件
-(BOOL)ifAudioType
{
    AVAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:_filePath] options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    if ([tracks count] > 0){
        _fileType = UPan_FT_Mus;
        return YES;
    }
    return NO;
}

//设置文件图标
-(void)setIcon
{
    UIImage *image = nil;
    switch (_fileType) {
        case UPan_FT_Dir:
            image = [UIImage imageNamed:@"fold"];
            break;
        case UPan_FT_Psd:
            image = [UIImage imageNamed:@"icon_psd"];
            break;
        case UPan_FT_Zip:
        case UPan_FT_Rar:
            image = [UIImage imageNamed:@"icon_compress"];
            break;
        case UPan_FT_Pdf:
            image = [UIImage imageNamed:@"icon_pdf"];
            break;
        case UPan_FT_Word:
            image = [UIImage imageNamed:@"icon_word"];
            break;
        case UPan_FT_Ppt:
            image = [UIImage imageNamed:@"UPan_FT_Ppt"];
            break;
        case UPan_FT_Xls:
            image = [UIImage imageNamed:@"icon_xls"];
            break;
        case UPan_FT_Xml:
            image = [UIImage imageNamed:@"icon_xml"];
            break;
        case UPan_FT_Html:
            image = [UIImage imageNamed:@"icon_html"];
            break;
        case UPan_FT_Img:
            image = [pSSCommodMethod imageShotcutOfPath:_filePath w:ICON_WIDTH h:ICON_WIDTH];
            break;
        case UPan_FT_Mov:
        {
            NSURL *url = [NSURL fileURLWithPath:_filePath];
            UIImage *imageTmp = [pSSCommodMethod thumbnailImageForVideo:url];
            if (imageTmp != nil) {
                image = [pSSCommodMethod imageShotcutOfImage:imageTmp w:ICON_WIDTH h:ICON_WIDTH];
            }else{
                image = [UIImage imageNamed:@"mov_icon"];
            }
        }
            break;
        case UPan_FT_Mus:
        {
            NSURL *url = [NSURL fileURLWithPath:_filePath];
            image = [pSSCommodMethod musicImageWithMusicURL:url];
            if (!image) {
                image = [UIImage imageNamed:@"file"];
            }
        }
            break;
        default:
            image = [UIImage imageNamed:@"file"];
            break;
    }
    
    _mIcon = image;
}
@end
