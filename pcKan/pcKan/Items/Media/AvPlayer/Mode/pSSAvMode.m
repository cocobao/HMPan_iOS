//
//  pSSAvMode.m
//  pcKan
//
//  Created by admin on 17/4/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSAvMode.h"
#import <AVFoundation/AVFoundation.h>

@implementation pSSAvMode
-(instancetype)initWithFile:(UPan_File *)file
{
    if (self = [super init]) {
        _mFile = file;
        
        _mURL = [NSURL fileURLWithPath:file.filePath];
        [self parseAudioAsset:[AVURLAsset URLAssetWithURL:_mURL options:nil]];
    }
    return self;
}

//解析音频文件信息
-(void)parseAudioAsset:(AVURLAsset *)audioAsset
{
    _mMime = nil;
    _mTitle = nil;
    _mArtwork = nil;
    _mAlbum = nil;
    for (NSString *format in [audioAsset availableMetadataFormats]){
        for (AVMetadataItem *metadataItem in [audioAsset metadataForFormat:format]) {
            if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                //                _mMime = [(NSDictionary *)metadataItem.value objectForKey:@"MIME"];
            }
            else if([metadataItem.commonKey isEqualToString:@"title"])
            {
                _mTitle = (NSString *)metadataItem.value;
            }
            else if([metadataItem.commonKey isEqualToString:@"artist"])
            {
                _mArtwork = (NSString *)metadataItem.value;
            }
            else if([metadataItem.commonKey isEqualToString:@"albumName"])
            {
                _mAlbum = (NSString *)metadataItem.value;
            }
        }
    }
    
    if (!_mTitle) {
        _mTitle = [_mURL lastPathComponent];
    }
    if (!_mArtwork) {
        _mArtwork = @"";
    }
    if (!_mAlbum) {
        _mAlbum = @"";
    }
}
@end
