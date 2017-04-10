//
//  UPan_File.h
//  pcKan
//
//  Created by admin on 2017/3/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ICON_WIDTH MarginW(35)

typedef enum : NSUInteger {
    //未知类型
    UPan_FT_Ukn,
    
    //文件夹类型
    UPan_FT_Dir,
    
    //媒体类型
    UPan_FT_Img,
    UPan_FT_Mus,
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

typedef enum : NSUInteger {
    EXCHANGE_COM,
    EXCHANGE_ING,
    EXCHANGE_PUSE,
} EXCHANGE;

@interface UPan_File : NSObject
//文件ID， 系统唯一
@property (nonatomic, assign) NSInteger fileId;
//文件名
@property (nonatomic, copy) NSString *fileName;
//文件类型
@property (nonatomic, assign) NSInteger fileType;
//文件大小
@property (nonatomic, assign) unsigned long long fileSize;
//文件路径
@property (nonatomic, copy) NSString *filePath;
//文件创建时间
@property (nonatomic, copy) NSString *createDate;
//文件图标
@property (nonatomic, strong) UIImage *mIcon;
//文件当前是否可用
//@property (nonatomic, assign) BOOL enable;
//文件是否传输完整
@property (nonatomic, assign) EXCHANGE exchangingState;
//传输信息
@property (nonatomic, strong) NSMutableDictionary *exchangeInfo;
//文件属性
@property (nonatomic, assign) NSFileAttributeType attsFileType;

-(instancetype)initWithPath:(NSString *)path Atts:(NSDictionary *)atts;

-(void)knowFileType;
@end
