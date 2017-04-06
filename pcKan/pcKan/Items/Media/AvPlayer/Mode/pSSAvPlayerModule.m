//
//  pSSAvPlayerModule.m
//  pcKan
//
//  Created by admin on 17/4/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSAvPlayerModule.h"

@implementation pSSAvPlayerModule
__strong static id sharedInstance = nil;
+ (instancetype)shareInstance
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(void)startWithMode:(NSInteger)index
{
    pSSAvMode *mode = [_mAudiosSource objectAtIndex:index];
    //如果当前播放就是选择的，不做处理
    if (_mAvMode && mode.mFile.fileId == _mAvMode.mFile.fileId) {
        return;
    }
    _mAvMode = mode;
    _currentIndex = index;
    
    [self stop];
    [self play];
}

//是否正在播放
-(BOOL)isPlaying
{
    if (!_audioPlayer) {
        return NO;
    }
    return [self.audioPlayer isPlaying];
}

//开始播放
-(void)play
{
    [self.audioPlayer play];
}

//停止播放
-(void)stop
{
    if (_audioPlayer) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
}

//暂停播放
-(void)pause
{
    [self.audioPlayer pause];
}

//音频时长
-(NSTimeInterval)duration
{
    return self.audioPlayer.duration;
}

//当前播放时间
-(NSTimeInterval)currentTime
{
    return self.audioPlayer.currentTime;
}

-(void)addAudioFile:(UPan_File *)file
{
    pSSAvMode *mode = [[pSSAvMode alloc] initWithFile:file];
    [_mAudiosSource addObject:mode];
}

-(void)removeAudioFile:(UPan_File *)file
{
    BOOL isFound = NO;
    NSInteger i = 0;
    for (pSSAvMode *mode in _mAudiosSource) {
        if (mode.mFile.fileId == file.fileId) {
            isFound = YES;
            break;
        }
        i++;
    }
    if (YES) {
        [_mAudiosSource removeObjectAtIndex:i];
    }
}

-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSError *error=nil;
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:_mAvMode.mURL error:&error];
        //设置播放器属性
        _audioPlayer.numberOfLoops=0;//设置为0不循环
        _audioPlayer.delegate=self;
        [_audioPlayer prepareToPlay];//加载音频文件到缓存
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
        
        //后台播放
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
        [audioSession setActive:YES error:&error];
    }
    return _audioPlayer;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    _currentIndex++;
    if (_currentIndex >= _mAudiosSource.count) {
        _currentIndex = 0;
    }
    _mAvMode = [_mAudiosSource objectAtIndex:_currentIndex];
    [self stop];
    [self play];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMusicNext object:nil];
}
@end
