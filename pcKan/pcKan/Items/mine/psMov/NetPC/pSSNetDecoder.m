//
//  pSSNetDecoder.m
//  pinut
//
//  Created by admin on 2017/2/5.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSNetDecoder.h"
#include "libavformat/avformat.h"
#include "g711.h"

@interface pSSNetDecoder ()
{
    AVCodecContext *_videoCodecCtx;
    AVCodecContext *_audioCodecCtx;
    AVPacket _mvpkt;
    AVPacket _avpkt;
    AVFrame *_videoFrame;
    AVFrame *_audioFrame;
}
@end

@implementation pSSNetDecoder
-(instancetype)init
{
    if (self = [super init]) {
        av_register_all();
    }
    return self;
}

-(void)dealloc
{
    if (_videoCodecCtx) {
        avcodec_close(_videoCodecCtx);
    }
    if (_videoFrame) {
        av_frame_free(&_videoFrame);
    }
}

-(void)initVideoDecoderWithId:(NSInteger)codecId
{
    //根据AVCodecID 查找支持该视频格式的解码器
    AVCodec *codec = avcodec_find_decoder((enum AVCodecID)codecId);
    if (codec == NULL) {
        return;
    }
    
    AVCodecContext *codecCtx = avcodec_alloc_context3(codec);
    if (codecCtx == NULL) {
        return;
    }
    avcodec_get_context_defaults3 (codecCtx, codec);
    //打开解码器
    if (avcodec_open2(codecCtx, codec, NULL) < 0) {
        avcodec_close(codecCtx);
        return;
    }
    
    _videoFrame = av_frame_alloc();
    if (!_videoFrame) {
        avcodec_close(codecCtx);
        return;
    }

    _videoCodecCtx = codecCtx;
}

-(void)initAudioDecoderWithId:(NSInteger)codecId
                    sampleFmt:(NSInteger)sampleFmt
                   sampleRate:(NSInteger)sampleRate
                      channels:(NSInteger)channels
{
    NSLog(@"codecId:%zd, fmt:%zd, rate:%zd, channels:%zd", codecId, sampleFmt, sampleRate, channels);
    
    enum AVCodecID avCodecId = (enum AVCodecID)codecId;
    AVCodec *codec = avcodec_find_decoder(avCodecId);
    if (codec == NULL) {
        NSLog(@"find av decoder fail");
        return;
    }
    AVCodecContext *codecCtx = avcodec_alloc_context3(codec);
    if (codecCtx == NULL) {
        return;
    }
    avcodec_get_context_defaults3 (codecCtx, codec);
    
    codecCtx->codec_type = AVMEDIA_TYPE_AUDIO;
    codecCtx->sample_fmt = AV_SAMPLE_FMT_S16;
    codecCtx->sample_rate = (int)sampleRate;
    codecCtx->channels = (int)channels;
    
    if (AV_CODEC_ID_ADPCM_G726 == codecId) {
        codecCtx->bit_rate = 32000;
        codecCtx->bits_per_coded_sample = 2;
    }
    else if (AV_CODEC_ID_AAC == codecId) {
        static uint8_t aac_config[2] = {0x14, 0x10};
        codecCtx->extradata = aac_config;
        codecCtx->extradata_size = 2;
        codecCtx->profile = FF_PROFILE_AAC_LOW;
    }
    
    if (avcodec_open2(codecCtx, codec, NULL) < 0) {
        avcodec_close(codecCtx);
        return;
    }
    _audioFrame = av_frame_alloc();
    if (!_videoFrame) {
        avcodec_close(codecCtx);
        return;
    }
    _audioCodecCtx = codecCtx;
}

-(KxVideoFrame *)decoderFrame:(NSData *)frameData
{
    if (_videoFrame == NULL) {
        NSLog(@"_videoFrame is null");
        return nil;
    }
    
    uint8_t *data = (uint8_t *)frameData.bytes;
    int length = (int)frameData.length;
    
    av_init_packet(&_mvpkt);
    _mvpkt.size = length;
    _mvpkt.data = data;
    
    int gotFrame = 0;
    int len = avcodec_decode_video2(_videoCodecCtx, _videoFrame, &gotFrame, &_mvpkt);
    if (len < 0) {
        NSLog(@"avcodec_decode_video2 fail!");
        return nil;
    }
    if (gotFrame) {
        return [self handleVideoFrame];
    }
    return nil;
}

-(KxAudioFrame *)decoderAudio:(NSData *)frameData
{
//    if (_audioFrame == NULL) {
//        NSLog(@"_audioFrame is null");
//        return nil;
//    }
    unsigned char *data = (unsigned char *)frameData.bytes;
    int length = (int)frameData.length;
//
//    av_init_packet(&_avpkt);
//    _avpkt.size = length;
//    _avpkt.data = data;
//    
//    int gotFrame = 0;
//    int len = avcodec_decode_audio4(_audioCodecCtx, _audioFrame, &gotFrame, &_avpkt);
//    if (len < 0) {
//        NSLog(@"avcodec_decode_video2 fail!");
//        return nil;
//    }
//    
//    const int bufSize = av_samples_get_buffer_size(_audioFrame->linesize,
//                                                   _audioCodecCtx->channels,
//                                                   _audioFrame->nb_samples,
//                                                   _audioCodecCtx->sample_fmt,
//                                                   0);

    char outPCM[4096] = {0};
    int dLen = 0;
    ALAW2PCM((unsigned char *)outPCM, &dLen, data, length);
    
    KxAudioFrame *auData = [[KxAudioFrame alloc] init];
    auData.samples = [NSData dataWithBytes:outPCM length:(NSUInteger)dLen];
    return auData;
}

//G711解码
int ALAW2PCM(unsigned char *pDst, int *iDstLen, unsigned char *pSrc, int iSrcLen)
{
    short temp  = 0;
    int index = 0;
    for (int i = 0; i < iSrcLen; i++)
    {
        temp = alaw2linear(pSrc[i]);
        pDst[index++] = temp;
        pDst[index++] = (temp >> 8);
    }
    *iDstLen = index;
    
    return index;
}

-(KxVideoFrame *)handleVideoFrame
{
    KxVideoFrame *frame;
    
    KxVideoFrameYUV *yuvFrame = [[KxVideoFrameYUV alloc] init];
    yuvFrame.luma = copyFrameData(_videoFrame->data[0],
                                  _videoFrame->linesize[0],
                                  _videoFrame->width,
                                  _videoFrame->height);
    yuvFrame.chromaB = copyFrameData(_videoFrame->data[1],
                                     _videoFrame->linesize[1],
                                     _videoFrame->width/2,
                                     _videoFrame->height/2);
    yuvFrame.chromaR = copyFrameData(_videoFrame->data[2],
                                     _videoFrame->linesize[2],
                                     _videoFrame->width/2,
                                     _videoFrame->height/2);
    frame = yuvFrame;
    
    frame.width = _videoFrame->width;
    frame.height = _videoFrame->height;
    return frame;
}
@end
