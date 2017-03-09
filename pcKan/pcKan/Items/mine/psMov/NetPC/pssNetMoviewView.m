//
//  pssNetMoviewView.m
//  pinut
//
//  Created by admin on 2017/2/6.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssNetMoviewView.h"
#import "pSSNetDecoder.h"
#import "pssGLView.h"
#import "pssLinkObj.h"
#import "RCETimmerHandler.h"
#import "pssAudioQueue.h"
#import <AVFoundation/AVFoundation.h>
#import "AQPlayer.h"

@interface pssNetMoviewView ()<pssMvDelegate>
{
    BOOL isFirst;
    NSInteger _fps;
    NSInteger _duration;
}
@property (nonatomic, strong) pSSNetDecoder *mDecoder;
@property (nonatomic, strong) pssGLView *glView;
@property (nonatomic, strong) RCETimmerHandler *mRenderTimer;
@property (nonatomic, strong) NSMutableArray *mArrFrames;

@end

@implementation pssNetMoviewView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mDecoder = [[pSSNetDecoder alloc] init];
        [self setupView];
        
        isFirst = YES;
        [pssLink setMvDataDelegate:self];
        
        _mArrFrames = [NSMutableArray arrayWithCapacity:100];
        
//        pssAudioQueue *audioQueue = [pssAudioQueue shareInstance];
//        [audioQueue SetupAudioFormat:kAudioFormatLinearPCM];
        AudioPlayer *audioQueue = [AudioPlayer shareInstance];
        [audioQueue SetupAudioFormat:kAudioFormatMPEG4AAC];
    }
    return self;
}

-(void)setFps:(NSInteger)fps
     duration:(NSInteger)duration
    mvCodecId:(NSInteger)mvCodecId
{
    _fps = fps;
    _duration = duration;

    [_mDecoder initVideoDecoderWithId:mvCodecId];
    
    
    NSLog(@"fps:%zd, duration:%zd, mvCodecId:%zd", fps, duration, mvCodecId);
}

-(void)setAudioInfo:(NSInteger)avCodecId
          sampleFmt:(NSInteger)sampleFmt
         sampleRate:(NSInteger)sampleRate
           channels:(NSInteger)channels
{
    [_mDecoder initAudioDecoderWithId:avCodecId sampleFmt:sampleFmt sampleRate:sampleRate channels:channels];
}

-(void)dealloc
{
    [pssLink setMvDataDelegate:nil];
}

-(void)cancelMv
{
    if (_mRenderTimer) {
        [_mRenderTimer cancel];
    }
    
    [_mArrFrames removeAllObjects];
    
    pssAudioQueue *audioQueue = [pssAudioQueue shareInstance];
    [audioQueue StopQueue];
}

//设置GL视图
-(void)setupView
{
    self.backgroundColor = [UIColor blackColor];
    self.tintColor = [UIColor blackColor];
    
    _glView = [[pssGLView alloc] initWithFrame:self.bounds format:KxVideoFrameFormatYUV];
    
    _glView.contentMode = UIViewContentModeScaleAspectFit;
    _glView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleBottomMargin;
    
    _glView.userInteractionEnabled = YES;
    
    [self insertSubview:_glView atIndex:0];
}

-(void)setupRenderTimer
{
    if (_fps <= 0) {
        return;
    }
    
    CGFloat t = 1.0/_fps;

    WeakSelf(weakSelf);
    RCETimmerHandler *timer = [[RCETimmerHandler alloc] initWithFrequency:t handleBlock:^{
        if (weakSelf.mArrFrames.count <= 0) {
            return;
        }
        NSData *data = weakSelf.mArrFrames[0];
        @synchronized (weakSelf.mArrFrames) {
            [weakSelf.mArrFrames removeObjectAtIndex:0];
        }
        
        KxVideoFrame *decFrameBuf = [weakSelf.mDecoder decoderFrame:data];
        if (!decFrameBuf) {
            return;
        }
        if (isFirst) {
            isFirst = NO;
            [weakSelf.glView setFrameWidth:decFrameBuf.width height:decFrameBuf.height];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.glView render:decFrameBuf];
        });
    } cancelBlock:nil];
    [timer start];
    _mRenderTimer = timer;
}

-(void)recvVideoData:(NSData*)data
{
//    static NSInteger i = 0;
//    i++;
//    NSLog(@"recv frame count:%zd", i);
    
//    @synchronized (_mArrFrames) {
//        [_mArrFrames addObject:data];
//    }
//    
//    if (!_mRenderTimer) {
//        [self setupRenderTimer];
//    }
}

-(void)recvAudioData:(NSData*)data
{
    WeakSelf(weakSelf);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        KxAudioFrame *auFrame = [weakSelf.mDecoder decoderAudio:data];
        
        AudioPlayer *audioQueue = [AudioPlayer shareInstance];
        [audioQueue addAudioData:auFrame.samples];
//        pssAudioQueue *audioQueue = [pssAudioQueue shareInstance];
//        [audioQueue addAudioData:auFrame.samples];
    });
}
@end
