//
//  UPan_FileRecvMgr.m
//  pcKan
//
//  Created by admin on 2017/3/9.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_FileRecvMgr.h"
#import "UPan_FileRecver.h"
#import "pssLinkObj.h"

@interface UPan_FileRecvMgr ()<NetTcpCallback, FileRecverDelegate>
@property (nonatomic, strong) NSMutableDictionary *muRecvers;
@end

@implementation UPan_FileRecvMgr
__strong static id sharedInstance = nil;
+ (id)shareInstance
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

-(instancetype)init
{
    self = [super init];
    if (self) {
        _muRecvers = [NSMutableDictionary dictionary];
        [pssLink addTcpDelegate:self];
    }
    return self;
}

-(void)addFileRecver:(UPan_File *)file fileSize:(NSInteger)fileSize
{
    UPan_FileRecver *fr = [[UPan_FileRecver alloc] initWithFileId:file.fileId filePath:file.filePath fileSize:fileSize];
    fr.m_delegate = self;
    NSString *key = [NSString stringWithFormat:@"%zd", file.fileId];
    self.muRecvers[key] = fr;
}

#pragma mark - NetTcpCallback
- (void)NetRecvFileData:(NSData *)data fileId:(unsigned long long)fileId
{
//    NSLog(@"file size:%zd, fileId:%zd", data.length, fileId);
    NSString *key = [NSString stringWithFormat:@"%zd", fileId];
    if (self.muRecvers[key]) {
        UPan_FileRecver *fr = self.muRecvers[key];
        [fr writeFileData:data];
    }
}

#pragma mark - FileRecverDelegate
-(void)didRecvFileFinish:(NSInteger)fileId
{
    NSString *key = [NSString stringWithFormat:@"%zd", fileId];
    if (self.muRecvers[key]){
        [self.muRecvers removeObjectForKey:key];
    }
    NSLog(@"file:%zd recv finish", fileId);
}
@end
