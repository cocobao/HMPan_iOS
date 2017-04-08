//
//  UPan_CurrentPathFileMng.m
//  pcKan
//
//  Created by ws on 2017/4/8.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_CurrentPathFileMng.h"

@interface UPan_CurrentPathFileMng ()

@end

@implementation UPan_CurrentPathFileMng
__strong static id sharedInstance = nil;
+ (instancetype)shareInstance
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(UPan_File *)fileWithFileId:(NSInteger)fileId
{
    if (_mFileSource == nil) {
        return nil;
    }
    for (UPan_File *file in _mFileSource) {
        if (file.fileId == fileId) {
            return file;
        }
    }
    return nil;
}

@end
