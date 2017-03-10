//
//  UPan_FileRecvMgr.h
//  pcKan
//
//  Created by admin on 2017/3/9.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPan_File.h"

#define FileExchanger [UPan_FileExchanger shareInstance]

@interface UPan_FileExchanger : NSObject
@property (nonatomic, strong) NSString *mNowPath;
+ (id)shareInstance;
-(void)addFileRecver:(UPan_File *)file fileSize:(NSInteger)fileSize;
@end
