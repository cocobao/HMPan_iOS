//
//  UPan_FileRecver.h
//  pcKan
//
//  Created by admin on 2017/3/9.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FileRecverDelegate <NSObject>
-(void)didRecvFileFinish:(NSInteger)fileId;
@end

@interface UPan_FileRecver : NSObject
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) NSInteger fileId;
@property (nonatomic, assign) NSInteger fileSize;
@property (nonatomic, assign) CGFloat persent;
@property (nonatomic, assign) unsigned long long seek;
@property (nonatomic, weak) id<FileRecverDelegate> m_delegate;
-(void)writeFileData:(NSData *)data;
-(instancetype)initWithFileId:(NSInteger)fileId filePath:(NSString *)filePath fileSize:(NSInteger)fileSize;
@end
