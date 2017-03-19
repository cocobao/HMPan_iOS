//
//  UPan_FileSender.h
//  pcKan
//
//  Created by admin on 2017/3/10.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pssLinkObj+Api.h"

@protocol picFileSenderDelegate <NSObject>
-(void)didSendFinish:(NSString *)threadName;
@end

@interface UPan_FileSender : NSObject
@property (nonatomic, assign) NSInteger mUid;
@property (nonatomic, strong) NSString *threadName;
@property (nonatomic, weak) id<picFileSenderDelegate> m_delegate;

-(instancetype)initWithFilePath:(NSString *)filePath fileId:(NSInteger)fileId;
-(instancetype)initWithFileData:(NSData *)fileData fileId:(NSInteger)fileId fileName:(NSString *)fileName;

-(void)cancel;
@end
