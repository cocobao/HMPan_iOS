//
//  pssAudioQueue.m
//  pinut
//
//  Created by admin on 2017/2/10.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssAudioQueue.h"
#import <AVFoundation/AVFoundation.h>

#define kNumberBuffers 3

@interface pssAudioQueue ()
{
    AudioQueueRef					mQueue;
    AudioStreamBasicDescription	mDataFormat;
    UInt32							mNumPacketsToRead;
    AudioQueueBufferRef				mBuffers[kNumberBuffers];
}

@property(nonatomic, assign) BOOL mIsRunning;
@property(nonatomic, assign) BOOL mIsInitialized;
@property (nonatomic, strong) NSLock *mPlayerLock;
@property (nonatomic, strong) NSMutableArray *audioDatas;
@end

@implementation pssAudioQueue
__strong static id sharedInstance = nil;
+ (id)shareInstance
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

void CalculateBytesForTime (AudioStreamBasicDescription *inDesc, UInt32 inMaxPacketSize, Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets)
{
    // we only use time here as a guideline
    // we're really trying to get somewhere between 16K and 64K buffers, but not allocate too much if we don't need it
    static const int maxBufferSize = 10000;//0x10000; // limit size to 64K
    static const int minBufferSize = 5000;//0x4000; // limit size to 16K
    
    if (inDesc->mFramesPerPacket) {
        Float64 numPacketsForTime = inDesc->mSampleRate / inDesc->mFramesPerPacket * 2/5;//inSeconds;//在inSeconds时间内支持的Packets数量
        *outBufferSize = numPacketsForTime * inMaxPacketSize;
    } else {
        // if frames per packet is zero, then the codec has no predictable packet == time
        // so we can't tailor this (we don't know how many Packets represent a time period
        // we'll just return a default buffer size
        *outBufferSize = maxBufferSize > inMaxPacketSize ? maxBufferSize : inMaxPacketSize;
    }
    
    // we're going to limit our size to our default
    if (*outBufferSize > maxBufferSize && *outBufferSize > inMaxPacketSize)
        *outBufferSize = maxBufferSize;
    else {
        // also make sure we're not too small - we don't want to go the disk for too small chunks
        if (*outBufferSize < minBufferSize)
            *outBufferSize = minBufferSize;
    }
    *outNumPackets = *outBufferSize / inMaxPacketSize;
}


-(instancetype)init
{
    if (self = [super init]) {
        _mPlayerLock = [[NSLock alloc] init];
        _mPlayerLock.name = @"AudioPlayer lock";
        
        AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
        NSError *error;
        bool success = [sessionInstance setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (!success)
            NSLog(@"initAVAudioSession:Error setting AVAudioSession category! %@\n", [error localizedDescription]);
    }
    return self;
}

- (void)dealloc
{
    [self DisposeQueue:true];
}

- (bool)initAudioQueue{
    
    if(_mIsInitialized)
        return true;

    if (0 == mDataFormat.mFormatID) {
        mDataFormat.mFormatID = kAudioFormatLinearPCM;
    }
    [self SetupAudioFormat:mDataFormat.mFormatID];
    return [self SetupNewQueue:self :NULL];
}

- (void)SetupAudioFormat:(UInt32) inFormatID
{
    mDataFormat.mReserved = 0;
    mDataFormat.mFormatID = inFormatID;
    if (inFormatID == kAudioFormatLinearPCM)
    {
        mDataFormat.mSampleRate = 8000.0;
        mDataFormat.mChannelsPerFrame = 1;
        mDataFormat.mBitsPerChannel = 8 * 2;
        mDataFormat.mBytesPerPacket =
        mDataFormat.mBytesPerFrame = mDataFormat.mChannelsPerFrame * 2;
        mDataFormat.mFramesPerPacket = 1;

        mDataFormat.mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
    }
    else if ((inFormatID == kAudioFormatULaw) || (inFormatID == kAudioFormatALaw))
    {
        mDataFormat.mSampleRate = 8000;
        mDataFormat.mChannelsPerFrame = 1;
        mDataFormat.mFramesPerPacket = 16;
        mDataFormat.mBytesPerPacket = mDataFormat.mBytesPerFrame = mDataFormat.mChannelsPerFrame * sizeof(SInt16);
        mDataFormat.mFramesPerPacket = 1;
        mDataFormat.mFormatFlags =
        kLinearPCMFormatFlagIsBigEndian |
        kLinearPCMFormatFlagIsSignedInteger |
        kLinearPCMFormatFlagIsPacked;
    }
    else if (inFormatID == kAudioFormatMPEG4AAC)
    {
        mDataFormat.mSampleRate = 44100.0;
        mDataFormat.mChannelsPerFrame = 2;
        mDataFormat.mFramesPerPacket = 1024;
        mDataFormat.mFormatFlags = kMPEG4Object_AAC_LC;
    }
    else if (inFormatID == kAudioFormatAppleLossless)
    {
        mDataFormat.mSampleRate = 44100.0;
        mDataFormat.mChannelsPerFrame = 2;
        mDataFormat.mFramesPerPacket = 1024;
        mDataFormat.mFormatFlags = kMPEG4Object_AAC_LC;
    }
    else if (inFormatID == kAudioFormatAppleIMA4)
    {
        mDataFormat.mSampleRate = 44100.0;
        mDataFormat.mChannelsPerFrame = 2;
        mDataFormat.mFramesPerPacket = 1024;
        mDataFormat.mFormatFlags = kMPEG4Object_AAC_LC;
    }
    else if (inFormatID == kAudioFormatiLBC)
    {
        mDataFormat.mSampleRate = 44100.0;
        mDataFormat.mChannelsPerFrame = 2;
        mDataFormat.mFramesPerPacket = 1024;
        mDataFormat.mFormatFlags = kMPEG4Object_AAC_LC;
    }
}

- (int)SetupNewQueue:(id)ins :(AudioQueueOutputCallback) cbFun
{
    //实例化回放音频队列
    int ret = AudioQueueNewOutput(&mDataFormat,     //需要播放的音频数据格式类型
                                  AQBufferCallback, //某块Buffer被使用之后的回调
                                  (__bridge void *)self, //上下文对象
                                  NULL,             //需要在的哪个RunLoop上被回调，如果传入NULL的话就会再AudioQueue的内部RunLoop中被回调
                                  NULL,             //RunLoop模式，如果传入NULL就相当于kCFRunLoopCommonModes
                                  0,                //inFlags是保留字段，目前没作用，传0
                                  &mQueue);         //返回生成的AudioQueue实例
    //返回值用来判断是否成功创建（OSStatus == noErr）
    if(ret) return ret;
    
    UInt32 size = sizeof(mDataFormat);
    ret = AudioQueueGetProperty(mQueue, kAudioQueueProperty_StreamDescription,	&mDataFormat, &size);
    if(ret) return ret;
    
    UInt32 bufferByteSize = 0;
    CalculateBytesForTime (&mDataFormat, 2, .4, &bufferByteSize, &mNumPacketsToRead);
    
    //监听当前AudioQueue是否在运
    ret = AudioQueueAddPropertyListener(mQueue, kAudioQueueProperty_IsRunning, isRunningProc, (__bridge void *)self);
    if(ret) return ret;

    for (int i = 0; i < kNumberBuffers; ++i) {
        AudioQueueAllocateBufferWithPacketDescriptions(mQueue, bufferByteSize, 0, &mBuffers[i]);
    }
    
    // set the volume of the queue
    ret = AudioQueueSetParameter(mQueue, kAudioQueueParam_Volume, 1.0);//设置音量
    if(ret) return ret;

    _mIsInitialized = true;
    return ret;
}

-(void)addAudioData:(NSData *)data
{
    if (nil == _audioDatas) {
        _audioDatas = [NSMutableArray arrayWithCapacity:10];
    }
    
    [_mPlayerLock lock];
    [_audioDatas addObject:data];
    [_mPlayerLock unlock];
    
    if (!_mIsRunning) {
        [self StartQueue];
    }
}

- (OSStatus)StartQueue
{
    _mIsRunning = YES;
    
    [self initAudioQueue];
    for (int i = 0; i < kNumberBuffers; i++) {
        AQBufferCallback((__bridge void *)self,mQueue,mBuffers[i]);
    }
    //开始播放
    int ret =  AudioQueueStart(mQueue, NULL);
    NSLog(@"AQPlayer::StartQueue : %d", ret);
    if (ret)
    {
        _mIsRunning = false;
        return false;
    }
    
    return true;
}

void AQBufferCallback(void *					inUserData,
                      AudioQueueRef			inAQ,
                      AudioQueueBufferRef		inBuffer)
{
    pssAudioQueue *THIS = (__bridge pssAudioQueue *)inUserData;

    inBuffer->mAudioDataByteSize = inBuffer->mAudioDataBytesCapacity;//这里不填会有很大的杂音
    memset(inBuffer->mAudioData, 0, inBuffer->mAudioDataBytesCapacity);
    
    [THIS.mPlayerLock lock];
    if (THIS.audioDatas.count)
    {
        NSData *d = [THIS.audioDatas firstObject];
        [THIS.audioDatas removeObjectIdenticalTo:d];
        
        inBuffer->mAudioDataByteSize = (UInt32)d.length;
        memcpy(inBuffer->mAudioData,[d bytes], inBuffer->mAudioDataByteSize);//此处的数据是在PlayBuffer填充的
    }
    [THIS.mPlayerLock unlock];
    
    if (inBuffer->mAudioDataByteSize > 0)
    {
        //插入Buffer
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
}

void isRunningProc (  void *              inUserData,
                    AudioQueueRef           inAQ,
                    AudioQueuePropertyID    inID)
{
    pssAudioQueue *THIS = (__bridge pssAudioQueue *)inUserData;
    UInt32 run = 0;
    UInt32 size = sizeof(run);
    AudioQueueGetProperty (inAQ, kAudioQueueProperty_IsRunning, &run, &size);//Any nonzero value means running, and 0 means stopped.
    THIS.mIsRunning = run;
}

- (void)DisposeQueue:(Boolean) inDisposeFile
{
    if (mQueue)
    {
        AudioQueueDispose(mQueue, false);
        mQueue = NULL;
    }
    _mIsInitialized = false;
}

- (OSStatus)StopQueue
{
    if (!_mIsRunning) {
        return 0;
    }
    //	AudioSessionSetActive(false);
    AudioQueueFlush(mQueue);
    OSStatus result = AudioQueueStop(mQueue, true);//When playing back, a playback audio queue callback should call this function when there is no more audio to play
    NSLog(@"AQPlayer::StopQueue:ret=%d\n",result);
    if (result) {
        _mIsRunning = false;
        [self DisposeQueue:true];
    }
    
    [_mPlayerLock lock];
    [_audioDatas removeAllObjects];
    [_mPlayerLock unlock];
    return result;
}
@end
