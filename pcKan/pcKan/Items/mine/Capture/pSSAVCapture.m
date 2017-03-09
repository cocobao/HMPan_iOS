//
//  pSSAVCapture.m
//  pinut
//
//  Created by admin on 2016/12/28.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSAVCapture.h"
#import <AVFoundation/AVFoundation.h>

@implementation pSSAVCapture
-(instancetype)initWithVideoCfg:(pSSVideoConfig *)videoCfg
{
    if (self = [super init]) {
        _videoCfg = videoCfg;
        
        [self onInit];
    }
    return self;
}

-(void)onInit{}

-(void) switchCamera{}

-(UIView *)preView
{
    if (!_preView) {
        UIView *view = [[UIView alloc] init];
        view.frame = [UIScreen mainScreen].bounds;
        _preView = view;
    }
    return _preView;
}

//设置帧率
-(void)setfps:(NSInteger)fps
{
    NSArray *arr = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in arr) {
        CGFloat maxRate = [(AVFrameRateRange *)[device.activeFormat.videoSupportedFrameRateRanges objectAtIndex:0] maxFrameRate];
        if (maxRate >= fps) {
            NSError *error;
            [device lockForConfiguration:&error];
            if (!error) {
                device.activeVideoMinFrameDuration= CMTimeMake(10, (int)(fps * 10));
                device.activeVideoMaxFrameDuration= device.activeVideoMinFrameDuration;
            }
            [device unlockForConfiguration];
        }
    }
}

-(NSString *)sessionPreset
{
    NSString *preset = @"";
    if (self.videoCfg.width == 540 && self.videoCfg.height == 960) {
        preset = AVCaptureSessionPresetiFrame960x540;
    }else if (self.videoCfg.width == 720 && self.videoCfg.height == 1280){
        preset = AVCaptureSessionPreset1280x720;
    }else if (self.videoCfg.width == 480 && self.videoCfg.height == 640){
        preset = AVCaptureSessionPreset640x480;
    }
    return preset;
}
@end
