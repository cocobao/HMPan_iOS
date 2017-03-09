//
//  pSSDecoder.m
//  pinut
//
//  Created by admin on 2017/1/7.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSDecoder.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"


static void avStreamFPSTimeBase(AVStream *st, CGFloat defaultTimeBase, CGFloat *pFPS, CGFloat *pTimeBase)
{
    CGFloat fps, timebase;
    
    if (st->time_base.den && st->time_base.num)
        timebase = av_q2d(st->time_base);
    else if(st->codec->time_base.den && st->codec->time_base.num)
        timebase = av_q2d(st->codec->time_base);
    else
        timebase = defaultTimeBase;
    
    if (st->codec->ticks_per_frame != 1) {
        NSLog(@"WARNING: st.codec.ticks_per_frame=%d", st->codec->ticks_per_frame);
        //timebase *= st->codec->ticks_per_frame;
    }
    
    if (st->avg_frame_rate.den && st->avg_frame_rate.num)
        fps = av_q2d(st->avg_frame_rate);
    else if (st->r_frame_rate.den && st->r_frame_rate.num)
        fps = av_q2d(st->r_frame_rate);
    else
        fps = 1.0 / timebase;
    
    if (pFPS)
        *pFPS = fps;
    if (pTimeBase)
        *pTimeBase = timebase;
}

@interface pSSDecoder ()
{
    AVFormatContext     *_formatCtx;
    AVCodecContext      *_videoCodecCtx;
    AVCodecContext      *_audioCodecCtx;
    AVCodecContext      *_subtitleCodecCtx;
    AVFrame             *_videoFrame;
    AVFrame             *_audioFrame;
    AVStream            *_videoStream;
    AVStream            *_audioStream;
    CGFloat             _minDuration;
    CGFloat             _videoTimeBase;
    CGFloat             _audioTimeBase;
    BOOL                isGlobelInit;
    pssMovieConfig      *_mvConfig;
    struct SwsContext   *_swsContext;
    BOOL                _pictureValid;
    AVPicture           _picture;
}

@end

@implementation pSSDecoder
- (CGFloat) duration
{
    if (!_formatCtx)
        return 0;
    if (_formatCtx->duration == AV_NOPTS_VALUE)
        return MAXFLOAT;
    return (CGFloat)_formatCtx->duration / AV_TIME_BASE;
}

- (BOOL) validVideo
{
    return _videoStream != NULL;
}

-(void)setMvConfig:(pssMovieConfig *)cfg
{
    _mvConfig = cfg;
}

-(NSUInteger)frameWidth
{
    return _videoCodecCtx?_videoCodecCtx->width:0;
}

-(NSUInteger)frameHeight
{
    return _videoCodecCtx?_videoCodecCtx->height:0;
}

-(void)setPosition:(CGFloat)position
{
    _position = position;
    _isEOF = NO;
    
    if (_videoStream != NULL) {
        int64_t ts = (int64_t)(position/_videoTimeBase);
        avformat_seek_file(_formatCtx, _videoStream->index, ts, ts, ts, AVSEEK_FLAG_FRAME);
        avcodec_flush_buffers(_videoCodecCtx);
    }
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self globelInit];
    }
    return self;
}

-(void)globelInit
{
    if (isGlobelInit) {
        return;
    }
//    av_log_set_callback();
    av_register_all();
    avformat_network_init();
    isGlobelInit = YES;
}

//是否为网络路径
-(BOOL)isNetworkPath:(NSString *)path
{
    NSRange r = [path rangeOfString:@":"];
    if (r.location == NSNotFound) {
        return NO;
    }
    NSString *scheme = [path substringToIndex:r.length];
    if ([scheme isEqualToString:@"file"])
        return NO;
    return YES;
}

//打开本地文件
-(BOOL)openFile:(NSURL *)url
{
    NSAssert(!_formatCtx, @"already open");
    if (url == nil) {
        return NO;
    }
    
    NSString *path = [url isFileURL]?[url path]:[url absoluteString];
    
    _isNetwork = [self isNetworkPath:path];
    _minDuration = _isNetwork?.0f:0.1f;
    
    const char *v = av_version_info();
    NSLog(@"ffmpeg verion info, %s", v);
    
    kxMovieError ret = [self openInput:path];
    if (ret != kxMovieErrorNone) goto openFail;
    
    ret = [self openMedia:AVMEDIA_TYPE_VIDEO];
    if (ret != kxMovieErrorNone) goto openFail;
    
//    ret = [self openMedia:AVMEDIA_TYPE_AUDIO];
//    if (ret != kxMovieErrorNone) goto openFail;
    
    return YES;
openFail:
    [self closeFile];
    return NO;
}

//打开视频文件
-(kxMovieError)openInput:(NSString *)path
{
    AVFormatContext *formatCtx = NULL;
    
    formatCtx = avformat_alloc_context();
    if (formatCtx == NULL) {
        return kxMovieErrorOpenFile;
    }
    
    //打开视频文件
    int ret = avformat_open_input(&formatCtx, [path cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL);
    if (ret < 0) {
        avformat_free_context(formatCtx);
        return kxMovieErrorOpenFile;
    }
    
    //查找文件流信息
    ret = avformat_find_stream_info(formatCtx, NULL);
    if (ret < 0) {
        avformat_close_input(&formatCtx);
        return kxMovieErrorStreamInfoNotFound;
    }
    
    //dump只是个调试函数，输出文件的音、视频流的基本信息了，帧率、分辨率、音频采样等等
    av_dump_format(formatCtx, 0, [path.lastPathComponent cStringUsingEncoding: NSUTF8StringEncoding], false);
    _formatCtx = formatCtx;
    return kxMovieErrorNone;
}

-(kxMovieError )openMedia:(NSInteger)mediaType
{
    for (int i = 0; i < _formatCtx->nb_streams; i++) {
        enum AVMediaType type = _formatCtx->streams[i]->codec->codec_type;
        if (type == mediaType) {
            switch (mediaType) {
                case AVMEDIA_TYPE_VIDEO:
                {
                    int pos = _formatCtx->streams[i]->disposition;
                    if ((pos & AV_DISPOSITION_ATTACHED_PIC) == 0) {
                        kxMovieError ret = [self openVideoStream:_formatCtx->streams[i]];
                        if (ret != kxMovieErrorNone) {
                            return ret;
                        }
                    }
                }
                    break;
                case AVMEDIA_TYPE_AUDIO:
                    break;
                case AVMEDIA_TYPE_SUBTITLE:
                    break;
                default:
                    break;
            }
        }
    }
    return kxMovieErrorNone;
}

//打开视频流
-(kxMovieError)openVideoStream:(AVStream *)avStream
{
    // get a pointer to the codec context for the video stream
    AVCodecContext *codecCtx = avStream->codec;
    
    //根据AVCodecID 查找支持该视频格式的解码器
    AVCodec *codec = avcodec_find_decoder(codecCtx->codec_id);
    if (codec == NULL) {
        return kxMovieErrorCodecNotFound;
    }
    
    //打开解码器
    if (avcodec_open2(codecCtx, codec, NULL) < 0) {
        return kxMovieErrorOpenCodec;
    }
    //申请帧缓存
    _videoFrame = av_frame_alloc();
    if (!_videoFrame) {
        avcodec_close(codecCtx);
        return kxMovieErrorAllocateFrame;
    }
    
    avStreamFPSTimeBase(avStream, 0.04, &_fps, &_videoTimeBase);
    _videoCodecCtx = codecCtx;
    _videoStream = avStream;
    NSLog(@"width:%d, height:%d", codecCtx->width, codecCtx->height);
    return kxMovieErrorNone;
}

//打开音频流
-(kxMovieError)openAudioStream:(AVStream *)avStream
{
    // get a pointer to the codec context for the audio stream
    AVCodecContext *codecCtx = avStream->codec;
    
    //根据AVCodecID 查找解码器
    AVCodec *codec = avcodec_find_decoder(codecCtx->codec_id);
    if (codec == NULL) {
        return kxMovieErrorCodecNotFound;
    }
    //打开解码器
    if (avcodec_open2(codecCtx, codec, NULL) < 0) {
        return kxMovieErrorOpenCodec;
    }
    
    _audioFrame = av_frame_alloc();
    if (!_audioFrame) {
        avcodec_close(codecCtx);
        return kxMovieErrorAllocateFrame;
    }
    
    _audioStream = avStream;
    _audioCodecCtx = codecCtx;
    avStreamFPSTimeBase(_audioStream, 0.025, 0, &_audioTimeBase);
    NSLog(@"audio codec smr: %.d fmt: %d chn: %d tb: %f ",
                _audioCodecCtx->sample_rate,
                _audioCodecCtx->sample_fmt,
                _audioCodecCtx->channels,
                _audioTimeBase);
    return kxMovieErrorNone;
}

-(BOOL)audioCodecIsSupported:(AVCodecContext *)audio
{
    if (audio->sample_fmt == AV_SAMPLE_FMT_S16) {
        
    }
    return NO;
}

-(void)closeFile
{
    [self closeVideoStream];
    [self closeAudioStream];
}

-(void)closeAudioStream
{
    
}

//关闭视频流
-(void)closeVideoStream
{
    if (_videoCodecCtx) {
        avcodec_close(_videoCodecCtx);
        _videoCodecCtx = NULL;
    }
    
    _videoStream = NULL;
    
    if (_formatCtx) {
        _formatCtx->interrupt_callback.opaque = NULL;
        _formatCtx->interrupt_callback.callback = NULL;
        avformat_close_input(&_formatCtx);
        _formatCtx = NULL;
    }
}

#pragma mark - public
//设置视频帧格式
-(BOOL)setupVideoFrameFormat:(KxVideoFrameFormat)format
{
    if (format == KxVideoFrameFormatYUV &&
        _videoCodecCtx &&
        (_videoCodecCtx->pix_fmt == AV_PIX_FMT_YUV420P ||
         _videoCodecCtx->pix_fmt == AV_PIX_FMT_YUVJ420P)) {
        _frameFormat = KxVideoFrameFormatYUV;
        return YES;
    }
    _frameFormat = KxVideoFrameFormatRGB;
    return _frameFormat == format;
}

//解码数据帧
-(NSArray *) decoderFrame:(CGFloat)minDuration
{
    if(_videoStream == NULL) return nil;
    
    NSMutableArray *result = [NSMutableArray array];
    
    AVPacket packet;
    CGFloat decodedDuration = 0;
    
    BOOL finish = NO;
    do {
        if (av_read_frame(_formatCtx, &packet) < 0) {
            _isEOF = YES;
            break;
        }
        if (packet.stream_index == _videoStream->index) {
            int pktSize = packet.size;
            while (pktSize > 0) {
                int gotFrame = 0;
                //解码视频帧
                int len = avcodec_decode_video2(_videoCodecCtx, _videoFrame, &gotFrame, &packet);
                if (len < 0) {
                    break;
                }
                
                if (gotFrame) {
                    if (!_mvConfig.MovieDisableDeinterlacing && _videoFrame->interlaced_frame) {
                        avpicture_deinterlace((AVPicture*)_videoFrame,
                                              (AVPicture*)_videoFrame,
                                              _videoCodecCtx->pix_fmt,
                                              _videoCodecCtx->width,
                                              _videoCodecCtx->height);
                    }
                    
                    KxVideoFrame *frame = [self handleVideoFrame];
                    if (frame) {
                        [result addObject:frame];
                        
                        //记录当前帧位置
                        _position = frame.position;
                        decodedDuration += frame.duration;
                        if (decodedDuration > _minDuration) {
                            finish = YES;
                        }
                    }
                }
                
                if (0 == len) {
                    break;
                }
                pktSize -= len;
            }
        }
//        else{
//            NSLog(@"stream_index invalid:%zd, _videoStream->index:%zd", packet.stream_index, _videoStream->index);
//        }
    } while (!finish);
    
    return result;
}

-(KxVideoFrame *)handleVideoFrame
{
    if (!_videoFrame->data[0]) {
        return nil;
    }
    
    KxVideoFrame *frame;
    
    //拷贝视频YUV数据
    if (_frameFormat == KxVideoFrameFormatYUV) {
        KxVideoFrameYUV *yuvFrame = [[KxVideoFrameYUV alloc] init];
        yuvFrame.luma = copyFrameData(_videoFrame->data[0],
                                      _videoFrame->linesize[0],
                                      _videoCodecCtx->width,
                                      _videoCodecCtx->height);
        yuvFrame.chromaB = copyFrameData(_videoFrame->data[1],
                                         _videoFrame->linesize[1],
                                         _videoCodecCtx->width/2,
                                         _videoCodecCtx->height/2);
        yuvFrame.chromaR = copyFrameData(_videoFrame->data[2],
                                         _videoFrame->linesize[2],
                                         _videoCodecCtx->width/2,
                                         _videoCodecCtx->height/2);
        frame = yuvFrame;
    }else{
        if (!_swsContext &&[self setupScaler]) {
            NSLog(@"fail setup video scaler");
            return nil;
        }
        
        sws_scale(_swsContext,
                  (const uint8_t **)_videoFrame->data,
                  _videoFrame->linesize,
                  0,
                  _videoCodecCtx->height,
                  _picture.data,
                  _picture.linesize);
        KxVideoFrameRGB *rgbFrame = [[KxVideoFrameRGB alloc] init];
        rgbFrame.linesize = _picture.linesize[0];
        rgbFrame.rgb = [NSData dataWithBytes:_picture.data[0] length:rgbFrame.linesize*_videoCodecCtx->height];
        frame = rgbFrame;
    }
    
    frame.width = _videoCodecCtx->width;
    frame.height = _videoCodecCtx->height;
    frame.position = av_frame_get_best_effort_timestamp(_videoFrame) * _videoTimeBase;
    
    const int64_t frameDuration = av_frame_get_pkt_duration(_videoFrame);
    if (frameDuration) {
        frame.duration = frameDuration * _videoTimeBase;
        frame.duration += _videoFrame->repeat_pict * _videoTimeBase * 0.5;
    }else{
        frame.duration = 1.0/_fps;
    }
    return frame;
}

-(BOOL)setupScaler
{
    [self closeScaler];
    
    _pictureValid = avpicture_alloc(&_picture, PIX_FMT_RGB24, _videoCodecCtx->width, _videoCodecCtx->height);
    
    if (!_pictureValid) {
        return NO;
    }
    
    _swsContext = sws_getCachedContext(_swsContext,
                                       _videoCodecCtx->width,
                                       _videoCodecCtx->height,
                                       _videoCodecCtx->pix_fmt,
                                       _videoCodecCtx->width,
                                       _videoCodecCtx->height,
                                       PIX_FMT_RGB24,
                                       SWS_FAST_BILINEAR,
                                       NULL, NULL, NULL);
    return _swsContext != NULL;
}

-(void)closeScaler
{
    if (_swsContext) {
        sws_freeContext(_swsContext);
    }
    
    if (_pictureValid) {
        avpicture_free(&_picture);
        _pictureValid = NO;
    }
}

- (void) dealloc
{
    [self closeFile];
}
@end


