//
//  pssSystemAVCapture.m
//  pcKan
//
//  Created by SZ14122141M01 on 2018/5/22.
//  Copyright © 2018年 ybz. All rights reserved.
//

#import "pssSystemAVCapture.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface pssSystemAVCapture() <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
//前后摄像头
@property (nonatomic, strong) AVCaptureDeviceInput *frontCamera;
@property (nonatomic, strong) AVCaptureDeviceInput *backCamera;
//当前使用的视频设备
@property (nonatomic, weak) AVCaptureDeviceInput *videoInputDevice;
//音频设备
@property (nonatomic, strong) AVCaptureDeviceInput *audioInputDevice;

//输出数据接收
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;

//会话
@property (nonatomic, strong) AVCaptureSession *captureSession;

//预览
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
//预览view
@property (nonatomic, strong) UIView *preview;

@property (nonatomic, unsafe_unretained) BOOL inBackground;
@end

@implementation pssSystemAVCapture
- (instancetype)initWithView:(UIView *)view
{
    if (self = [super init]) {
        self.preview = view;
        [self onInit];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

-(void)onInit{
    [self createCaptureDevice];
    [self createOutput];
    [self createCaptureSession];
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.frame = self.preview.bounds;
    [self.preview.layer addSublayer:self.previewLayer];
    //更新fps
    [self updateFps: 15];
}

//初始化视频设备
-(void) createCaptureDevice{
    //创建视频设备
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //初始化摄像头
    self.frontCamera = [AVCaptureDeviceInput deviceInputWithDevice:videoDevices.firstObject error:nil];
    self.backCamera =[AVCaptureDeviceInput deviceInputWithDevice:videoDevices.lastObject error:nil];
    
    //麦克风
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    self.audioInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    
    self.videoInputDevice = self.frontCamera;
}

-(void) createOutput{
    //创建数据获取线程
    dispatch_queue_t captureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //视频数据输出
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    //设置代理，需要当前类实现protocol：AVCaptureVideoDataOutputSampleBufferDelegate
    [self.videoDataOutput setSampleBufferDelegate:self queue:captureQueue];
    //抛弃过期帧，保证实时性
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    //设置输出格式为 yuv420
    [self.videoDataOutput setVideoSettings:@{
                                             (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
                                             }];
    //音频数据输出
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    //设置代理，需要当前类实现protocol：AVCaptureAudioDataOutputSampleBufferDelegate
    [self.audioDataOutput setSampleBufferDelegate:self queue:captureQueue];
}

//创建会话， // AVCaptureSession 创建逻辑很简单，它像是一个中介者，从音视频输入设备获取数据，处理后，传递给输出设备(数据代理/预览layer)
-(void) createCaptureSession{
    //初始化
    self.captureSession = [AVCaptureSession new];
    //修改配置
    [self.captureSession beginConfiguration];
    //加入视频输入设备
    if ([self.captureSession canAddInput:self.videoInputDevice]) {
        [self.captureSession addInput:self.videoInputDevice];
    }
    //加入音频输入设备
    if ([self.captureSession canAddInput:self.audioInputDevice]) {
        [self.captureSession addInput:self.audioInputDevice];
    }
    //加入视频输出
    if([self.captureSession canAddOutput:self.videoDataOutput]){
        [self.captureSession addOutput:self.videoDataOutput];
        [self setVideoOutConfig];
    }
    //加入音频输出
    if([self.captureSession canAddOutput:self.audioDataOutput]){
        [self.captureSession addOutput:self.audioDataOutput];
    }
    //设置预览分辨率
    //这个分辨率有一个值得注意的点：
    //iphone4录制视频时 前置摄像头只能支持 480*640 后置摄像头不支持 540*960 但是支持 720*1280
    //诸如此类的限制，所以需要写一些对分辨率进行管理的代码。
    //目前的处理是，对于不支持的分辨率会抛出一个异常
    //但是这样做是不够、不完整的，最好的方案是，根据设备，提供不同的分辨率。
    //如果必须要用一个不支持的分辨率，那么需要根据需求对数据和预览进行裁剪，缩放。
    if (![self.captureSession canSetSessionPreset:self.captureSessionPreset]) {
        @throw [NSException exceptionWithName:@"Not supported captureSessionPreset" reason:[NSString stringWithFormat:@"captureSessionPreset is [%@]", self.captureSessionPreset] userInfo:nil];
    }
    
    self.captureSession.sessionPreset = self.captureSessionPreset;
    //提交配置变更
    [self.captureSession commitConfiguration];
    //开始运行，此时，CaptureSession将从输入设备获取数据，处理后，传递给输出设备。
    [self.captureSession startRunning];
}

-(void) setVideoOutConfig{
    for (AVCaptureConnection *conn in self.videoDataOutput.connections) {
        if (conn.isVideoStabilizationSupported) {
            [conn setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
        }
        if (conn.isVideoOrientationSupported) {
            [conn setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }
        if (conn.isVideoMirrored) {
            [conn setVideoMirrored: YES];
        }
    }
}

//修改fps
-(void) updateFps:(NSInteger) fps{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *vDevice in videoDevices) {
        //获取当前支持的最大fps
        float maxRate = [(AVFrameRateRange *)[vDevice.activeFormat.videoSupportedFrameRateRanges objectAtIndex:0] maxFrameRate];
        if (maxRate >= fps) {
            if ([vDevice lockForConfiguration:NULL]) {
                vDevice.activeVideoMinFrameDuration = CMTimeMake(10, (int)(fps * 10));
                vDevice.activeVideoMaxFrameDuration = vDevice.activeVideoMinFrameDuration;
                [vDevice unlockForConfiguration];
            }
        }
    }
}

-(NSString *)captureSessionPreset{
    return AVCaptureSessionPreset1280x720;
}

-(void) willEnterForeground{
    self.inBackground = NO;
}

-(void) didEnterBackground{
    self.inBackground = YES;
}
@end
