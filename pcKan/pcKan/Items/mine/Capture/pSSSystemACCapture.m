//
//  pSSSystemACCapture.m
//  pinut
//
//  Created by admin on 2016/12/28.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSSystemACCapture.h"
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface pSSSystemACCapture ()<AVCaptureVideoDataOutputSampleBufferDelegate>
//视频会话
@property (nonatomic, strong) AVCaptureSession *capSession;
//输入
@property (nonatomic, strong) AVCaptureDeviceInput *capInput;
//视频输出
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

@property (nonatomic, strong) AVCaptureDevice *fontCam;//前置摄像头
@property (nonatomic, strong) AVCaptureDevice *backCam;//后置摄像头

//预览
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation pSSSystemACCapture
-(void)onInit
{
    [self createCamDevice];
    [self createOutput];
    [self createCaptureSession];
    [self createPreview];
}

-(void)createCamDevice
{
    _fontCam = [self camDeviceWithPosition:AVCaptureDevicePositionFront];
    _backCam = [self camDeviceWithPosition:AVCaptureDevicePositionBack];
    
    NSError *error;
    //默认设置前置摄像头为输入设备
    _capInput = [[AVCaptureDeviceInput alloc] initWithDevice:_fontCam error:&error];
    if (error) {
        NSLog(@"init AVCaptureDeviceInput fail!");
    }
}

-(void)createOutput
{
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    //设置采样输出代理,以及线程
    [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    //丢弃延时帧
    _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    [_videoDataOutput setVideoSettings:@{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:
                                             @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)}];
}

-(void)createCaptureSession
{
    _capSession = [[AVCaptureSession alloc] init];
    
    //开始配置会话
    [_capSession beginConfiguration];
    //添加视频输入设备
    if ([_capSession canAddInput:_capInput]) {
        [_capSession addInput:_capInput];
    }
    //添加视频输出设备
    if ([_capSession canAddOutput:_videoDataOutput]) {
        [_capSession addOutput:_videoDataOutput];
    }
    //设置预览分辨率
    //这个分辨率有一个值得注意的点：
    //iphone4录制视频时 前置摄像头只能支持 480*640 后置摄像头不支持 540*960 但是支持 720*1280
    //诸如此类的限制，所以需要写一些对分辨率进行管理的代码。
    //目前的处理是，对于不支持的分辨率会抛出一个异常
    //但是这样做是不够、不完整的，最好的方案是，根据设备，提供不同的分辨率。
    //如果必须要用一个不支持的分辨率，那么需要根据需求对数据和预览进行裁剪，缩放。
    if (![_capSession canSetSessionPreset:self.sessionPreset]) {
        @throw [NSException exceptionWithName:@"Not supported captureSessionPreset"
                                       reason:[NSString stringWithFormat:@"captureSessionPreset is [%@]", self.sessionPreset]
                                     userInfo:nil];
    }
    _capSession.sessionPreset = self.sessionPreset;
    [_capSession commitConfiguration];
    [_capSession startRunning];
}

-(void)destroySession
{
    if (_capSession) {
        [_capSession stopRunning];
        [_capSession removeInput:_capInput];
        [_capSession removeOutput:_videoDataOutput];
    }
    _capSession = nil;
}

//预览控件配置
-(void)createPreview
{
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.capSession];
    _previewLayer.frame = self.preView.frame;
    [self.preView.layer addSublayer:_previewLayer];
}

//获取摄像头设备
-(AVCaptureDevice *)camDeviceWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *arr = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in arr) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

//切换摄像头
-(void) switchCamera
{
    AVCaptureDevice *dev = nil;

    if (_capInput.device == _fontCam) {
        dev = _backCam;
    }else{
        dev = _fontCam;
    }
    [_capSession beginConfiguration];
    [_capSession removeInput:_capInput];
    AVCaptureDeviceInput *devInput = [AVCaptureDeviceInput deviceInputWithDevice:dev error:nil];
    if ([_capSession canAddInput:devInput]) {
        [_capSession addInput:devInput];
        _capInput = devInput;
    }else{
        [_capSession addInput:_capInput];
        NSLog(@"切换失败");
    }
    [_capSession commitConfiguration];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
}
@end
