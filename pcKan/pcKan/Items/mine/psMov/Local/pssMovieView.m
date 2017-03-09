//
//  pssMovieView.m
//  pinut
//
//  Created by admin on 2017/1/17.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssMovieView.h"
#import "pSSDecoder.h"
#import "pssGLView.h"
#import "pssMovieConfig.h"
#import "KxAudioManager.h"

#define LOCAL_MIN_BUFFERED_DURATION   0.2
#define LOCAL_MAX_BUFFERED_DURATION   0.4
#define NETWORK_MIN_BUFFERED_DURATION 2.0
#define NETWORK_MAX_BUFFERED_DURATION 4.0

@interface pssMovieView ()
{
    pSSDecoder *_mDecoder;
    pssGLView *_mGlView;
    UIImageView    *_imageView;
    dispatch_queue_t _dispatchQueue;
    NSMutableArray *_videoFrames;
    NSMutableArray *_audioFrames;
    CGFloat         _bufferedDuration;
    CGFloat         _maxBufferedDuration;
    CGFloat         _minBufferedDuration;
    BOOL            _buffered;
    CGFloat         _moviePosition;
    NSTimeInterval  _tickCorrectionTime;
    NSTimeInterval  _tickCorrectionPosition;
}
@property (nonatomic, strong) NSURL *fileUrl;
@property (nonatomic, assign) BOOL decoding;
@end

@implementation pssMovieView
- (instancetype)initWithFrame:(CGRect)frame urlPath:(NSURL *)urlPath
{
    self = [super initWithFrame:frame];
    if (self) {
        _fileUrl = urlPath;
        
        id<KxAudioManager> audioManager = [KxAudioManager audioManager];
        [audioManager activateAudioSession];
        
        [self setUpDecoder];
        [self setupView];
    }
    return self;
}

//设置解码器
-(void)setUpDecoder
{
    _dispatchQueue = dispatch_queue_create("movieDispatchQueue", NULL);
    _videoFrames = [NSMutableArray array];
    _audioFrames = [NSMutableArray array];
    
    pSSDecoder *decoder = [[pSSDecoder alloc] init];
    [decoder setMvConfig:[self setMovieConfig]];
    [decoder openFile:_fileUrl];
    [decoder setupVideoFrameFormat:KxVideoFrameFormatYUV];
    _mDecoder = decoder;
    
    if (_mDecoder.isNetwork) {
        _minBufferedDuration = NETWORK_MIN_BUFFERED_DURATION;
        _maxBufferedDuration = NETWORK_MAX_BUFFERED_DURATION;
    } else {
        _minBufferedDuration = LOCAL_MIN_BUFFERED_DURATION;
        _maxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION;
    }
    if (_maxBufferedDuration < _minBufferedDuration)
        _maxBufferedDuration = _minBufferedDuration * 2;
    
    self.backgroundColor = [UIColor clearColor];
}

//设置GL视图
-(void)setupView
{
    self.backgroundColor = [UIColor blackColor];
    self.tintColor = [UIColor blackColor];
    
    pssGLView *glView = nil;
    if (_mDecoder.validVideo) {
        glView = [[pssGLView alloc] initWithFrame:self.bounds format:_mDecoder.frameFormat];
    }
    UIView *frameView = nil;
    if (glView != nil) {
        [glView setFrameWidth:_mDecoder.frameWidth height:_mDecoder.frameHeight];
        frameView = glView;
        _mGlView = glView;
    }else{
        [_mDecoder setupVideoFrameFormat:KxVideoFrameFormatRGB];
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [UIColor blackColor];
        frameView = _imageView;
    }
    
    frameView.contentMode = UIViewContentModeScaleAspectFit;
    frameView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                UIViewAutoresizingFlexibleTopMargin |
                                UIViewAutoresizingFlexibleRightMargin |
                                UIViewAutoresizingFlexibleLeftMargin |
                                UIViewAutoresizingFlexibleHeight |
                                UIViewAutoresizingFlexibleBottomMargin;
    
    frameView.userInteractionEnabled = YES;
    
    [self insertSubview:frameView atIndex:0];
}

//视频配置
-(pssMovieConfig *)setMovieConfig
{
    pssMovieConfig *mvConfig = [[pssMovieConfig alloc] init];
    
    //iphone手机平台
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        mvConfig.MovieDisableDeinterlacing = YES;
    }
    
    NSString *path = [_fileUrl absoluteString];
    if ([path.pathExtension isEqualToString:@"wmv"]) {
        mvConfig.MovieMinBufferedDuration = 5.0f;
    }
    return mvConfig;
}

-(void)restorePlay
{
    [self play];
}

//开始播放
- (void)play
{
    if(_playing) return;
    
    if(!_mDecoder.validVideo) return;
    
    _playing = YES;
    
    [self asynvDecodeFrames];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self tick];
    });
}

-(void)asynvDecodeFrames
{
    if(_decoding) return;
    
    _decoding = YES;
    
    WeakSelf(weakSelf);
    __weak pSSDecoder *weakDecoder = _mDecoder;
    const CGFloat duration = weakDecoder.isNetwork ? .0f : 0.1f;
    
    dispatch_async(_dispatchQueue, ^{
        {
            StrongSelf(strongSelf, weakSelf);
            if (!strongSelf.playing) return;
        }
        
        BOOL good = YES;
        do {
            @autoreleasepool {
                __strong pSSDecoder *decoder = weakDecoder;
                if (decoder && decoder.validVideo) {
                    NSArray *frames = [decoder decoderFrame:duration];
                    if (frames.count) {
                        StrongSelf(strongSelf, weakSelf);
                        if (strongSelf) {
                            good = [strongSelf addFrames:frames];
                        }
                    }
                }
            }
        } while (good);
        
        {
            StrongSelf(strongSelf, weakSelf);
            strongSelf.decoding = NO;
        }
    });
}

-(BOOL)addFrames:(NSArray *)frames
{
    if (_mDecoder.validVideo) {
        @synchronized (_videoFrames) {
            for (KxMovieFrame *frame in frames) {
                if (frame.type == KxMovieFrameTypeVideo) {
                    [_videoFrames addObject:frame];
                    _bufferedDuration += frame.duration;
                }
            }
        }
    }
    
    return self.playing && _bufferedDuration < _maxBufferedDuration;
}

-(void)tick
{
    CGFloat interval = 0;
    if (!_buffered) {
        interval = [self presentFrame];
    }
    
    if (self.playing) {
        const NSUInteger leftFrame = (_mDecoder.validVideo?_videoFrames.count:0);
        
        if (0 == leftFrame) {
            if (_mDecoder.isEOF) {
                [self pause];
                return;
            }
        }
        
        if (!leftFrame || (_bufferedDuration > _minBufferedDuration)) {
            [self asynvDecodeFrames];
        }
        
        const NSTimeInterval correction = [self tickCorrection];
        const NSTimeInterval time = MAX(interval + correction, 0.01);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self tick];
        });
    }
}

- (CGFloat) tickCorrection
{
    if (_buffered)
        return 0;
    
    const NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (!_tickCorrectionTime) {
        
        _tickCorrectionTime = now;
        _tickCorrectionPosition = _moviePosition;
        return 0;
    }
    
    NSTimeInterval dPosition = _moviePosition - _tickCorrectionPosition;
    NSTimeInterval dTime = now - _tickCorrectionTime;
    NSTimeInterval correction = dPosition - dTime;
    
    if (correction > 1.f || correction < -1.f) {
        NSLog(@"tick correction reset %.2f", correction);
        correction = 0;
        _tickCorrectionTime = 0;
    }
    
    return correction;
}

-(CGFloat)presentFrame
{
    CGFloat interval = 0;
    
    if (_mDecoder.validVideo) {
        KxVideoFrame *frame;
        
        @synchronized (_videoFrames) {
            if (_videoFrames.count > 0) {
                frame = _videoFrames[0];
                [_videoFrames removeObjectAtIndex:0];
                _bufferedDuration -= frame.duration;
            }
        }
        
        if (frame) {
            interval = [self presentVideoFrame:frame];
        }
    }
    
    return interval;
}

-(CGFloat)presentVideoFrame:(KxVideoFrame *)frame
{
    if (_mGlView) {
        [_mGlView render:frame];
    }else{
        KxVideoFrameRGB *rgbFrame = (KxVideoFrameRGB *)frame;
        _imageView.image = [rgbFrame asImage];
    }
    
    _moviePosition = frame.position;
    return frame.duration;
}

-(void)pause
{
    if (!self.playing) {
        return;
    }
    self.playing = NO;
}
@end
