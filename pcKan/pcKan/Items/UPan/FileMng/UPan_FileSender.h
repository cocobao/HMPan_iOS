//
//  UPan_FileSender.h
//  pcKan
//
//  Created by admin on 2017/3/10.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_FileBaseSender.h"


@interface UPan_FileSender : UPan_FileBaseSender
@property (nonatomic, assign) NSInteger mUid;

-(instancetype)initWithFilePath:(NSString *)filePath fileId:(NSInteger)fileId;

@end
