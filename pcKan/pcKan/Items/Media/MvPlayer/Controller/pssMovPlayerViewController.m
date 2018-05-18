//
//  pssAvPlayerViewController.m
//  pcKan
//
//  Created by SZ14122141M01 on 2018/5/16.
//  Copyright © 2018年 ybz. All rights reserved.
//

#import "pssMovPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface pssMovPlayerViewController ()
@property (nonatomic, strong) AVPlayer *player;//播放器对象

@property (strong, nonatomic)  UIView *container; //播放器容器
@property (strong, nonatomic)  UIButton *playOrPause; //播放/暂停按钮
@property (strong, nonatomic)  UIProgressView *progress;//播放进度

@property (strong, nonatomic) NSString *filePath;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@end

@implementation pssMovPlayerViewController

-(instancetype)initWithFilePath:(NSString *)filePath
{
    if (self = [super init]) {
        _filePath = filePath;
        
        NSURL *url=[NSURL fileURLWithPath:filePath];
        _playerItem=[AVPlayerItem playerItemWithURL:url];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.player play];
}

#pragma mark - 私有方法
-(void)setupUI{
    //创建播放器层
    AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth*9/16);
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.view.layer addSublayer:playerLayer];
}

-(AVPlayer *)player{
    if (!_player) {
        _player=[AVPlayer playerWithPlayerItem:_playerItem];
        [self addProgressObserver];
        [self addObserverToPlayerItem:_playerItem];
    }
    return _player;
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    MITLog(@"视频播放完成.");
    [_playerItem seekToTime:kCMTimeZero];
}

#pragma mark - 监控
/**
 *  给播放器添加进度更新
 */
-(void)addProgressObserver{
    AVPlayerItem *playerItem=self.player.currentItem;
    UIProgressView *progress=self.progress;
    //这里设置每秒执行一次
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([playerItem duration]);
        //        NSLog(@"当前已经播放%.2fs.",current);
        if (current) {
            [progress setProgress:(current/total) animated:YES];
        }
    }];
}

/**
 *  给AVPlayerItem添加监控
 *
 *  @param playerItem AVPlayerItem对象
 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [self addNotification];
}

-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
        }else if (status == AVPlayerStatusUnknown){
            MITLog(@"AVPlayerStatusUnknown");
        }else if (status == AVPlayerStatusFailed){
            MITLog(@"AVPlayerStatusFailed");
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        MITLog(@"共缓冲：%.2f",totalBuffer);
    }
}

-(void)dealloc{
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self removeNotification];
}

-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
