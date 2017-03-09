//
//  pSSDecoder.h
//  pinut
//
//  Created by admin on 2017/1/7.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pssMvFrame.h"
#import "pssMovieConfig.h"

typedef enum {
    kxMovieErrorNone,
    kxMovieErrorOpenFile,
    kxMovieErrorStreamInfoNotFound,
    kxMovieErrorStreamNotFound,
    kxMovieErrorCodecNotFound,
    kxMovieErrorOpenCodec,
    kxMovieErrorAllocateFrame,
    kxMovieErroSetupScaler,
    kxMovieErroReSampler,
    kxMovieErroUnsupported,
} kxMovieError;

@interface pSSDecoder : NSObject
@property (readonly, nonatomic, assign) BOOL isNetwork;
@property (readonly, nonatomic, assign) KxVideoFrameFormat frameFormat;
@property (readonly, nonatomic, assign) CGFloat duration;
@property (readonly, nonatomic, assign) CGFloat fps;
@property (readonly, nonatomic, assign) CGFloat position;
@property (readonly, nonatomic, assign) BOOL isEOF;
@property (readonly, nonatomic, assign) NSUInteger frameWidth;
@property (readonly, nonatomic, assign) NSUInteger frameHeight;

-(BOOL)openFile:(NSURL *)url;
-(BOOL)setupVideoFrameFormat:(KxVideoFrameFormat)format;
-(BOOL)validVideo;
-(void)setMvConfig:(pssMovieConfig *)cfg;
-(NSArray *) decoderFrame:(CGFloat)minDuration;
@end
