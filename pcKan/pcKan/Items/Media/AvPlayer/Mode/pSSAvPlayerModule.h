//
//  pSSAvPlayerModule.h
//  pcKan
//
//  Created by admin on 17/4/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "pSSAvMode.h"

#define PSS_AVPLAYER [pSSAvPlayerModule shareInstance]

@interface pSSAvPlayerModule : NSObject<AVAudioPlayerDelegate>
//播放器
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (nonatomic, strong) pSSAvMode *mAvMode;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *mAudiosSource;

+ (instancetype)shareInstance;

-(void)startWithMode:(NSInteger)index;

//是否正在播放
-(BOOL)isPlaying;

//开始播放
-(void)play;

//停止播放
-(void)stop;

//暂停播放
-(void)pause;

//音频时长
-(NSTimeInterval)duration;

//当前播放时间
-(NSTimeInterval)currentTime;

//添加音频文件
-(void)addAudioFile:(UPan_File *)file;

//删除音频文件
-(void)removeAudioFile:(UPan_File *)file;
@end
