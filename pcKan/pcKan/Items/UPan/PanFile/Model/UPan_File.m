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
        _fileType = UPan_FT_UnKnownFile;
        _fileId = [atts[NSFileSystemFileNumber] integerValue];
        NSDate *date = atts[NSFileCreationDate];
        _createDate = [pSSCommodMethod dateToString:date];
        
        NSFileAttributeType type = atts[NSFileType];
        if (type == NSFileTypeDirectory) {
            _fileType = UPan_FT_Dir;
        }else{
            [self ifMediaType];
        }
    }
    return self;
}

-(void)ifMediaType
{
    HBImageType t = [HBImageTypeSizeUtil imageTypeOfFilePath:_filePath];
    if (t == HBImageTypeJPG ||
        t == HBImageTypePNG ||
        t == HBImageTypeBMP) {
        _fileType = UPan_FT_Img;
    }else{
        if ([_fileName hasSuffix:@".mov"] ||
            [_fileName hasSuffix:@".flv"] ||
            [_fileName hasSuffix:@".mp4"] ||
            [_fileName hasSuffix:@".mkv"]) {
            _fileType = UPan_FT_Mov;
        }
        else{
            //文件是否有视频轨道
            AVAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:_filePath] options:nil];
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            if ([tracks count] > 0) {
                _fileType = UPan_FT_Mov;
            }
        }
    }
}
@end
