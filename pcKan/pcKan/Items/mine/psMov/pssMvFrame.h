//
//  pssMvFrame.h
//  pinut
//
//  Created by admin on 2017/1/13.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>

NSData *copyFrameData(UInt8 *src, int linesize, int width, int height);

typedef enum {
    KxMovieFrameTypeAudio,
    KxMovieFrameTypeVideo,
    KxMovieFrameTypeArtwork,
    KxMovieFrameTypeSubtitle,
} KxMovieFrameType;

typedef enum {
    KxVideoFrameFormatRGB,
    KxVideoFrameFormatYUV,
} KxVideoFrameFormat;

@interface KxMovieFrame : NSObject
@property ( nonatomic) KxMovieFrameType type;
@property (nonatomic) CGFloat position;
@property (nonatomic) CGFloat duration;
@end

@interface KxVideoFrame : KxMovieFrame
@property (nonatomic) KxVideoFrameFormat format;
@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;
@end

@interface KxAudioFrame : KxMovieFrame
@property (nonatomic, strong) NSData *samples;
@end

@interface KxVideoFrameRGB : KxVideoFrame
@property (nonatomic) NSUInteger linesize;
@property (nonatomic, strong) NSData *rgb;
- (UIImage *) asImage;
@end

@interface KxVideoFrameYUV : KxVideoFrame
@property (nonatomic, strong) NSData *luma;     //Y 明亮度
@property (nonatomic, strong) NSData *chromaB;  //U Cb
@property (nonatomic, strong) NSData *chromaR;  //V Cr
@end

@interface KxArtworkFrame : KxMovieFrame
@property (nonatomic, strong) NSData *picture;
- (UIImage *) asImage;
@end

@interface KxSubtitleFrame : KxMovieFrame
@property (nonatomic, strong) NSString *text;
@end

