/*
 
    File: AQPlayer.h
Abstract: Helper class for playing audio files via the AudioQueue
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

#include <AudioToolbox/AudioToolbox.h>
#import <CoreAudioKit/CoreAudioKit.h>
#include <Foundation/Foundation.h>

#define kNumberBuffers 3

@interface AudioPlayer : NSObject

+ (id)shareInstance;

- (void)addAudioData:(NSData *)d;
- (bool)initAudioQueue;
- (OSStatus)StartQueue;
- (OSStatus)StopQueue;
- (OSStatus)PauseQueue;

- (AudioQueueRef)Queue;
- (AudioStreamBasicDescription)DataFormat;
- (Boolean)IsRunning;
- (Boolean)IsInitialized;
//		CFStringRef	GetFilePath() const		{ return (mFilePath) ? mFilePath : CFSTR(""); }
- (Boolean)							IsLooping;

- (void) SetLooping:(Boolean)inIsLooping;
- (int) CreateQueueForFile:(CFStringRef) inFilePath;
- (void) DisposeQueue:(Boolean) inDisposeFile;


- (UInt32)				GetNumPacketsToRead;
- (SInt64)				GetCurrentPacket;
- (AudioFileID)			GetAudioFileID;
- (void)				SetCurrentPacket:(SInt64)inPacket;

- (void)SetupAudioFormat:(UInt32) inFormatID;
//		int					ComputeRecordBufferSize(const AudioStreamBasicDescription *format, float seconds);
- (void)setAudioRoute:(int) index;

@end