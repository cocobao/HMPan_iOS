//
//  UPan_CurrentPathFileMng.h
//  pcKan
//
//  Created by ws on 2017/4/8.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPan_File.h"

#define CurPathFile [UPan_CurrentPathFileMng shareInstance]

@interface UPan_CurrentPathFileMng : NSObject
@property (nonatomic, copy) NSString *mNowPath;
@property (nonatomic, weak) NSMutableArray *mFileSource;;
+ (instancetype)shareInstance;
-(UPan_File *)fileWithFileId:(NSInteger)fileId;
@end
