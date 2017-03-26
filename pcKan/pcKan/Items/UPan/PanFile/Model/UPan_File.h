//
//  UPan_File.h
//  pcKan
//
//  Created by admin on 2017/3/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    UPan_FT_UnKnownFile,
    
    //文件夹类型
    UPan_FT_Dir,
    
    //媒体类型
    UPan_FT_Img,
    UPan_FT_Mov,
    
    //文档类型
    UPan_FT_Word,
    UPan_FT_Ppt,
    UPan_FT_Pdf,
    UPan_FT_Txt,
    UPan_FT_Xls,
    UPan_FT_H,
    UPan_FT_M,
    UPan_FT_Xml,
    UPan_FT_Html,
    UPan_FT_Psd,
    
    //压缩类型
    UPan_FT_Zip,
    UPan_FT_Rar,
} UPan_FileType;

@interface UPan_File : NSObject
@property (nonatomic, assign) NSInteger fileId;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) NSInteger fileType;
@property (nonatomic, assign) unsigned long long fileSize;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *createDate;
@property (nonatomic, strong) UIImage *mIcon;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) NSFileAttributeType attsFileType;

-(instancetype)initWithPath:(NSString *)path Atts:(NSDictionary *)atts;

-(void)knowFileType;
@end
