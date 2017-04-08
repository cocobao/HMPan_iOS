//
//  pSSAvPlayerModule.m
//  pcKan
//
//  Created by admin on 17/4/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSAvPlayerModule.h"
#import "UPan_CurrentPathFileMng.h"

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

-(instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFileNotify:) name:kNotificationDeleteFile object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvFileFinishNotify:) name:kNotificationFileRecvFinish object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//播放文件
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

//添加音频文件
-(void)addAudioFile:(UPan_File *)file
{
    if (file.fileType != UPan_FT_Mus || ![self isPlaying]) {
        return;
    }
    for (pSSAvMode *mode in _mAudiosSource) {
        if (mode.mFile.fileId == file.fileId) {
            return;
        }
    }
    pSSAvMode *mode = [[pSSAvMode alloc] initWithFile:file];
    [_mAudiosSource addObject:mode];
    
    MITLog(@"添加了音乐文件, %@", file.fileName);
}

//删除音频文件
-(void)removeAudioFile:(UPan_File *)file
{
    if (file.fileType != UPan_FT_Mus || ![self isPlaying]) {
        return;
    }
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
        if (_mAudiosSource.count <= i) {
            return;
        }
        
        if (i == _currentIndex) {
            [self stop];
            [_mAudiosSource removeAllObjects];
        }else{
            [_mAudiosSource removeObjectAtIndex:i];
            MITLog(@"删除了音乐文件, %@", file.fileName);
        }
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
//播放完毕
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

#pragma mark - notify
//删除文件通知
-(void)deleteFileNotify:(NSNotification *)notify
{
    UPan_File *file = (UPan_File *)notify.object;
    [self removeAudioFile:file];
}

//接收文件通知
-(void)recvFileFinishNotify:(NSNotification *)notify
{
    UPan_File *file = notify.object;
    [self addAudioFile:file];
}
@end
