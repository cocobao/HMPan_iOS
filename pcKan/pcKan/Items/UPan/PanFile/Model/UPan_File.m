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
        AVAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@", _filePath]]
                                             options:nil];
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        if ([tracks count] > 0) {
            _fileType = UPan_FT_Mov;
        }
    }
}
@end
