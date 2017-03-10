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
    UPan_FT_Dir,
    UPan_FT_Img,
    UPan_FT_Mov,
} UPan_FileType;

@interface UPan_File : NSObject
@property (nonatomic, assign) NSInteger fileId;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) NSInteger fileType;
@property (nonatomic, assign) unsigned long long fileSize;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *createDate;
@property (nonatomic, strong) UIImage *mIcon;

-(instancetype)initWithPath:(NSString *)path Atts:(NSDictionary *)atts;
-(void)ifMediaType;
@end
