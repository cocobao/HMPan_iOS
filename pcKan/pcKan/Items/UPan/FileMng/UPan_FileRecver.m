//
//  UPan_FileRecver.m
//  pcKan
//
//  Created by admin on 2017/3/9.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_FileRecver.h"

@interface UPan_FileRecver ()
{
    CGFloat lastPostPersent;
}
@property (nonatomic, strong) NSFileHandle *fileHandle;
@end

@implementation UPan_FileRecver
-(instancetype)initWithFileId:(NSInteger)fileId filePath:(NSString *)filePath fileSize:(NSInteger)fileSize
{
    self = [super init];
    if (self) {
        _fileId = fileId;
        _filePath = filePath;
        _fileSize = fileSize;
        _seek = 0;
        _persent = 0;
        lastPostPersent = 0;
        _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    }
    return self;
}

-(void)writeFileData:(NSData *)data
{
    [_fileHandle seekToEndOfFile];
    [_fileHandle writeData:data];
    
    _seek += data.length;
    if (_seek >= _fileSize) {
        _persent = 100;
        [_fileHandle closeFile];
        if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(didRecvFileFinish:)]) {
            [self.m_delegate didRecvFileFinish:self.fileId];
        }
        usleep(300000);
    }else{
        _persent = ((double)_seek/_fileSize)*100;
    }
    if ((_persent - lastPostPersent > 1) || _persent >= 100) {
        lastPostPersent = _persent;
        NSNotificationCenter *nofity = [NSNotificationCenter defaultCenter];
        [nofity postNotificationName:kNotificationFileRecvPersent
                              object:@{ptl_fileId:@(_fileId), ptl_persent:@(_persent), ptl_seek:@(_seek)}];
    }
}
@end
