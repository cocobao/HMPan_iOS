//
//  pSSAvMode.h
//  pcKan
//
//  Created by admin on 17/4/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "UPan_File.h"

@interface pSSAvMode : NSObject
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, copy) NSString *mArtwork;
@property (nonatomic, copy) NSString *mMime;
@property (nonatomic, copy) NSString *mAlbum;
@property (nonatomic, strong) NSURL *mURL;

@property (nonatomic, weak) UPan_File *mFile;

-(instancetype)initWithFile:(UPan_File *)file;
@end
