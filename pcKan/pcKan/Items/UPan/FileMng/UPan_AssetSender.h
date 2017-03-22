//
//  UPan_AssetSender.h
//  pcKan
//
//  Created by admin on 17/3/22.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_FileBaseSender.h"

@interface UPan_AssetSender : UPan_FileBaseSender
-(instancetype)initWithFileData:(NSData *)fileData fileId:(NSInteger)fileId fileName:(NSString *)fileName;
@end
