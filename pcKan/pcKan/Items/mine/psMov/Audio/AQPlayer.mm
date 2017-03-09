/*
 
    File: AQPlayer.mm
Abstract: n/a
 Version: 2.4

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2009 Apple Inc. All Rights Reserved.

 
*/

#include "AQPlayer.h"
#include <AVFoundation/AVFoundation.h>

@interface AudioPlayer (){
    AudioQueueRef					mQueue;
    AudioQueueBufferRef				mBuffers[kNumberBuffers];
    Boolean							mIsInitialized;
    
    AudioFileID						mAudioFile;
    CFStringRef						mFilePath;
    AudioStreamBasicDescription		mDataFormat;
    
    UInt32							mNumPacketsToRead;
    SInt64							mCurrentPacket;
    Boolean							mIsLooping;
}

@property(nonatomic, assign)UInt32	 mIsRunning;
@property(nonatomic, assign) Boolean mIsDone;

@property (nonatomic, strong) NSMutableArray *audioDatas;
@property (nonatomic, strong) NSLock *mPlayerLock;

@end

@implementation AudioPlayer

__strong static id sharedInstance = nil;
+ (id)shareInstance
{
    static dispatch_once_t pred = 0;
    //    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init]; // or some other init method
    });
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone//其实alloc也是调用此方法，只是参数zone为nil而已
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            //            [sharedInstance initQueue];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return sharedInstance; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;//此处保证不会产生副本
}

void AQBufferCallback(void *					inUserData,
								AudioQueueRef			inAQ,
								AudioQueueBufferRef		inBuffer)
{
	AudioPlayer *THIS = (__bridge AudioPlayer *)inUserData;
	if (THIS.mIsDone) return;

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
		//inCompleteAQBuffer->mAudioDataByteSize = 6400;		//读取的数据量
		//inCompleteAQBuffer->mPacketDescriptionCount = THIS->mNumPacketsToRead;	//实际读取的数据包	
		AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);//添加到音频服务队列，以供播放
	//	THIS->mCurrentPacket = (THIS->GetCurrentPacket() + nPackets);//下次读取的起始位置，以数据包为起始量
	} 
/*	else 
	{
		static UInt8 count = 0;
		count++;
		if (count>= 5*kNumberBuffers) {
			count = 0;
			
			// stop
			THIS->mIsDone = true;
			AudioQueueStop(inAQ, true);//tops playing or recording audio.
			NSLog(@"inCompleteAQBuffer);  AudioQueueStop");
		}
//		else(THIS->IsLooping())
//		{
//			//THIS->mCurrentPacket = 0;
//			NSLog(@"inUserData, inAQ, inCompleteAQBuffer);//重新读取数据");
//			AQBufferCallback(inUserData, inAQ, inCompleteAQBuffer);//重新读取数据
//		}
	}*/
}

void isRunningProc (  void *              inUserData,
								AudioQueueRef           inAQ,
								AudioQueuePropertyID    inID)
{
	AudioPlayer *THIS = (__bridge AudioPlayer *)inUserData;
    UInt32 run = 0;
    UInt32 size = sizeof(run);
	OSStatus result = AudioQueueGetProperty (inAQ, kAudioQueueProperty_IsRunning, &run, &size);//Any nonzero value means running, and 0 means stopped.
    THIS.mIsRunning = run;
    //NSLog(@"isRunningProc--------%d---------", THIS->mIsRunning);
	if ((result == noErr) && (!run))//THIS->mIsRunning的值从音频队列服务中读取出来，如果为0表示已经停止
    {}
//		[[NSNotificationCenter defaultCenter] postNotificationName: @"playbackQueueStopped" object: nil];
}

void CalculateBytesForTime (AudioStreamBasicDescription & inDesc, UInt32 inMaxPacketSize, Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets)
{
	// we only use time here as a guideline
	// we're really trying to get somewhere between 16K and 64K buffers, but not allocate too much if we don't need it
	static const int maxBufferSize = 10000;//0x10000; // limit size to 64K
	static const int minBufferSize = 5000;//0x4000; // limit size to 16K
	
	if (inDesc.mFramesPerPacket) {
		Float64 numPacketsForTime = inDesc.mSampleRate / inDesc.mFramesPerPacket * 2/5;//inSeconds;//在inSeconds时间内支持的Packets数量
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

- (instancetype)init{
    self = [super init];
    mQueue = 0;
    mAudioFile=0;
    mFilePath=NULL;
    _mIsRunning=false;
    mIsInitialized=false;
    mNumPacketsToRead=0;
    mCurrentPacket=0;
    _mIsDone=false;
    mIsLooping=false;

    _mPlayerLock = [[NSLock alloc] init];
    _mPlayerLock.name = @"AudioPlayer lock";
    
	memset(mBuffers, 0, sizeof(mBuffers));
//	m_pCondition = [[NSCondition alloc] init];
	
    AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
    NSError *error;
    
	//黑屏回放
//	UInt32 allowMix = 1;
//	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: nil];
//	[sessionInstance setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//	AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMix), &allowMix);
//	[[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    bool success = [sessionInstance setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!success) NSLog(@"initAVAudioSession:Error setting AVAudioSession category! %@\n", [error localizedDescription]);
    [sessionInstance overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    return self;
}

- (void)dealloc
{
    [self DisposeQueue:true];
}

- (void)addAudioData:(NSData *)d{
    if (nil == _audioDatas) {
        _audioDatas = [NSMutableArray arrayWithCapacity:10];
    }
    
    [_mPlayerLock lock];
    [_audioDatas addObject:d];
    [_mPlayerLock unlock];
    
    if (!_mIsRunning) {
        [self StartQueue];
    }
}

- (bool)initAudioQueue{
	
	if(mIsInitialized) return true;
	_mIsDone = false;
    if (0 == mDataFormat.mFormatID) {
        mDataFormat.mFormatID = kAudioFormatLinearPCM;
    }
    [self SetupAudioFormat:mDataFormat.mFormatID];
    return [self SetupNewQueue:self :NULL];
}

- (void)setAudioRoute:(int) index{
    AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
    NSError *error;
    
	if(index){
        [sessionInstance overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
	}
	else {
		[sessionInstance overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
	}
}
	
- (OSStatus)StartQueue
{
	_mIsRunning = true;

    [self initAudioQueue];
	for (int i = 0; i < kNumberBuffers; i++) {
        AQBufferCallback((__bridge void *)self,mQueue,mBuffers[i]);
	}
//	 AudioQueuePrime(mQueue, 0, NULL);

	int ret =  AudioQueueStart(mQueue, NULL);
	NSLog(@"AQPlayer::StartQueue : %d", ret);
	if (ret) 
	{
		_mIsRunning = false;
		return false;
	}

	return true;
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

- (OSStatus)PauseQueue
{
	_mIsRunning	= false;
	OSStatus result = AudioQueuePause(mQueue);//Begins playing or recording audio.
	AudioQueueFlush(mQueue);//调用后会播放完Enqueu的所有buffer后重置解码器状态
	return result;
}

- (AudioQueueRef)					Queue					{ return mQueue; }
- (AudioStreamBasicDescription)		DataFormat		{ return mDataFormat; }
- (Boolean)							IsRunning		{ return (_mIsRunning) ? true : false; }
- (Boolean)							IsInitialized	{ return mIsInitialized; }
//		CFStringRef						GetFilePath() const		{ return (mFilePath) ? mFilePath : CFSTR(""); }
- (Boolean)							IsLooping		{ return mIsLooping; }

- (void) SetLooping:(Boolean)inIsLooping	{ mIsLooping = inIsLooping; }

- (int)CreateQueueForFile:(CFStringRef) inFilePath //打开一个音频文件
{	
	inFilePath = (__bridge CFStringRef)[NSTemporaryDirectory() stringByAppendingPathComponent: @"recordedFile.caf"];
	CFURLRef sndFile = NULL; 
				
		if (mFilePath == NULL)
		{
//			mIsLooping = false;
			sndFile = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, inFilePath, kCFURLPOSIXPathStyle, false);
			if (!sndFile) { return 1; }
			
			AudioFileOpenURL (sndFile, kAudioFileReadPermission, 0, &mAudioFile);
		
			UInt32 size = sizeof(mDataFormat);
			AudioFileGetProperty(mAudioFile,
										   kAudioFilePropertyDataFormat, &size, &mDataFormat);
			mFilePath = CFStringCreateCopy(kCFAllocatorDefault, inFilePath);
		}
//		SetupNewQueue(this, AQPlayer::AQBufferCallback);		

	if (sndFile)
		CFRelease(sndFile);
	return 0;
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
        //shizj        mRecordFormat.mFormatFlags = kAudioFormatFlagsCanonical;
        mDataFormat.mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
        
        // if we want pcm, default to signed 16-bit little-endian
        /*
         mRecordFormat.mFormatFlags =
         kLinearPCMFormatFlagIsBigEndian |
         kLinearPCMFormatFlagIsSignedInteger |
         kLinearPCMFormatFlagIsPacked;
         */
    }
    else if ((inFormatID == kAudioFormatULaw) || (inFormatID == kAudioFormatALaw))
    {
        mDataFormat.mSampleRate = 8000;//44100.0;
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
        //mRecordFormat.mBytesPerFrame = mRecordFormat.mChannelsPerFrame * sizeof(SInt16);
        mDataFormat.mFormatFlags = kMPEG4Object_AAC_LC;
    }
    
    // Below still need to test
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
//	CreateQueueForFile(NULL);
	
	//实例化回放音频队列
//	int ret = AudioQueueNewOutput(&mDataFormat, AQBufferCallback, (__bridge void *)self,  CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &mQueue);
    int ret = AudioQueueNewOutput(&mDataFormat, AQBufferCallback, (__bridge void *)self,  NULL, NULL, 0, &mQueue);
	if(ret) return ret;
	
	UInt32 size = sizeof(mDataFormat);
	ret = AudioQueueGetProperty(mQueue, kAudioQueueProperty_StreamDescription,	&mDataFormat, &size);
	if(ret) return ret;
	
    UInt32 bufferByteSize = 0;// = ComputeRecordBufferSize(&mDataFormat, .4);
	CalculateBytesForTime (mDataFormat, 2, .4, &bufferByteSize, &mNumPacketsToRead);
	
	// we need to calculate how many packets we read at a time, and how big a buffer we need
	// we base this on the size of the packets in the file and an approximate duration for each buffer
	// first check to see what the max size of a packet is - if it is bigger
	// than our allocation default size, that needs to become larger
	/*UInt32 maxPacketSize;
	UInt32 size = sizeof(maxPacketSize);
	//XThrowIfError(AudioFileGetProperty(mAudioFile,kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize), "couldn't get file's max packet size");
	
	// adjust buffer size to represent about a half second of audio based on this format
	CalculateBytesForTime (mDataFormat, maxPacketSize, .4, &bufferByteSize, &mNumPacketsToRead);

		//printf ("Buffer Byte Size: %d, Num Packets to Read: %d\n", (int)bufferByteSize, (int)mNumPacketsToRead);
	
	// (2) If the file has a cookie, we should get it and set it on the AQ
	size = sizeof(UInt32);
	OSStatus result = AudioFileGetPropertyInfo (mAudioFile, kAudioFilePropertyMagicCookieData, &size, NULL);
	
	if (!result && size) {
		char* cookie = new char [size];		
		XThrowIfError (AudioFileGetProperty (mAudioFile, kAudioFilePropertyMagicCookieData, &size, cookie), "get cookie from file");
		XThrowIfError (AudioQueueSetProperty(mQueue, kAudioQueueProperty_MagicCookie, cookie, size), "set cookie on queue");
		delete [] cookie;
	}
	
	// channel layout?
	result = AudioFileGetPropertyInfo(mAudioFile, kAudioFilePropertyChannelLayout, &size, NULL);
	if (result == noErr && size > 0) {
		AudioChannelLayout *acl = (AudioChannelLayout *)malloc(size);
		XThrowIfError(AudioFileGetProperty(mAudioFile, kAudioFilePropertyChannelLayout, &size, acl), "get audio file's channel layout");
		XThrowIfError(AudioQueueSetProperty(mQueue, kAudioQueueProperty_ChannelLayout, acl, size), "set channel layout on queue");
		free(acl);
	}
	*/
	/*
	UInt32 dataSize;
    CFStringRef currentRoute;
    currentRoute = NULL;
    dataSize = sizeof(CFStringRef);
    AudioSessionInitialize(NULL, NULL, NULL, (__bridge void*) self);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &dataSize, &currentRoute);
    if([(__bridge NSString *) currentRoute hasPrefix: @"Headphone"])//return @"Headphone" or @"Speaker" and so on.
    {
        //插入耳机后想执行的操作
    }
	ret = AudioQueueAddPropertyListener(mQueue, kAudioSessionProperty_AudioRouteChange, isRunningProc, (__bridge void *)self);
    AudioQueuePropertyID pid = kAudioSessionProperty_AudioRouteChange | kAudioSessionProperty_AudioInputAvailable | kAudioQueueProperty_IsRunning;
     */
    
	ret = AudioQueueAddPropertyListener(mQueue, kAudioQueueProperty_IsRunning, isRunningProc, (__bridge void *)self);
	if(ret) return ret;
//	bool isFormatVBR = (mDataFormat.mBytesPerPacket == 0 || mDataFormat.mFramesPerPacket == 0);
	for (int i = 0; i < kNumberBuffers; ++i) {
		//AudioQueueAllocateBuffer(mQueue, bufferByteSize, &mBuffers[i]);
		AudioQueueAllocateBufferWithPacketDescriptions(mQueue, bufferByteSize, 0, &mBuffers[i]);
	}	

	// set the volume of the queue
	ret = AudioQueueSetParameter(mQueue, kAudioQueueParam_Volume, 1.0);//设置音量
	if(ret) return ret;

//	UInt32 category = kAudioSessionCategory_MediaPlayback;
//	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);	
//	AudioSessionSetActive(true);
	
	mIsInitialized = true;
	return ret;
}

- (void)DisposeQueue:(Boolean) inDisposeFile
{
	if (mQueue)
	{
		AudioQueueDispose(mQueue, false);
		mQueue = NULL;
	}/*
	if (inDisposeFile)
	{
		if (mAudioFile)
		{		
			AudioFileClose(mAudioFile);
			mAudioFile = 0;
		}
		if (mFilePath)
		{
			CFRelease(mFilePath);
			mFilePath = NULL;
		}
	}*/

	mIsInitialized = false;
}

- (UInt32)				GetNumPacketsToRead				{ return mNumPacketsToRead; }
- (SInt64)				GetCurrentPacket					{ return mCurrentPacket; }
- (AudioFileID)			GetAudioFileID					{ return mAudioFile; }
- (void)				SetCurrentPacket:(SInt64) inPacket	{ mCurrentPacket = inPacket; }

@end

/*
AudioClassDescription requestedCodecs[2] = {
    {
        kAudioEncoderComponentType,
        kAudioFormatLinearPCM,
        kAppleHardwareAudioCodecManufacturer
    },
    {
        kAudioDecoderComponentType,
        kAudioFormatLinearPCM,
        kAppleHardwareAudioCodecManufacturer
    }
};

UInt32 successfulCodecs = 0;
int size = sizeof (successfulCodecs);
OSStatus result =   AudioFormatGetProperty (
											kAudioFormatProperty_HardwareCodecCapabilities,
											requestedCodecs,
											sizeof (requestedCodecs),
											&size,
											&successfulCodecs
											);
switch (successfulCodecs) {
    case 0:
        // aac hardware encoder is unavailable. aac hardware decoder availability
        // is unknown; could ask again for only aac hardware decoding
    case 1:
        // aac hardware encoder is available but, while using it, no hardware
        // decoder is available.
    case 2:
        // hardware encoder and decoder are available simultaneously
}

 1,检测音时的变化
 //	[[NSNotificationCenter defaultCenter] addObserver:self 
 //                                           selector:@selector(trackTheDeviceVolume:) 
 //                                             name:MPMusicPlayerControllerVolumeDidChangeNotification 
 //                                         object:nil];
 //	AVSystemController_SystemVolumeDidChangeNotification
 //	PMusicPlayerControllerVolumeDidChangeNotification
 //	UIATarget	*m_target; clickVolumeDown  holdVolumeUp
 
 2, 。.plist
 UIRequiresPersistentWiFi 在程序中弹出wifi选择的key（系统设置中需要将wifi提示打开）
 UIAppFonts 内嵌字体（http://www.minroad.com/?p=412 有详细介绍）
 UIApplicationExitsOnSuspend 程序是否在后台运行，自己在进入后台的时候exit(0)是很傻的办法
 UIBackgroundModes 后台运行时的服务，具体看iOS4的后台介绍
 UIDeviceFamily array类型（1为iPhone和iPod touch设备，2为iPad)
 UIFileSharingEnabled 开启itunes共享document文件夹
 UILaunchImageFile 相当于Default.png（更名而已）
 UIPrerenderedIcon icon上是否有高光
 UIRequiredDeviceCapabilities 设备需要的功能（具体点击这里查看）
 UIStatusBarHidden 状态栏隐藏（和程序内的区别是在于显示Default.png已经生效）
 UIStatusBarStyle 状态栏类型
 UIViewEdgeAntialiasing 是否开启抗锯齿
 CFBundleDisplayName app显示名
 CFBundleIconFile、CFBundleIconFiles 图标
 CFBundleName 与CFBundleDisplayName的区别在于这个是短名，16字符之内
 CFBundleVersion 版本
 CFBundleURLTypes 自定义url，用于利用url弹回程序
 CFBundleLocalizations 本地资源的本地化语言，用于itunes页面左下角显示本地话语种
 CFBundleDevelopmentRegion 也是本地化相关，如果用户所在地没有相应的语言资源，则用这个key的value来作为默认
 最后附上官方文档，所有的key都有，看英文原版才是正路：）
 
 3，检测耳机的插拔
 AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange, RouteChangeListener, self);
 void RouteChangeListener(void * inClientData,
 AudioSessionPropertyID        inID,
 UInt32 inDataSize,
 const void * inData){
 BookContentView2* This = (BookContentView2*)inClientData;
 
 if (inID == kAudioSessionProperty_AudioRouteChange) {
 
 CFDictionaryRef routeDict = (CFDictionaryRef)inData;
 NSNumber* reasonValue = (NSNumber*)CFDictionaryGetValue(routeDict, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
 
 int reason = [reasonValue intValue];
 
 if (reason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
 [This.player stop];
 }
 }
 }
 */
