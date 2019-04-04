//
//  pssVLCPlayerViewController.m
//  pcKan
//
//  Created by bz y on 2019/4/4.
//  Copyright © 2019 ybz. All rights reserved.
//

#import "pssVLCPlayerViewController.h"
#import "MRVLCPlayer.h"

@interface pssVLCPlayerViewController ()
@property (strong, nonatomic) NSString *filePath;
@end

@implementation pssVLCPlayerViewController


-(instancetype)initWithFilePath:(NSString *)filePath
{
    if (self = [super init]) {
        _filePath = filePath;
        
        NSURL *url=[NSURL fileURLWithPath:filePath];
        MRVLCPlayer *player = [[MRVLCPlayer alloc] init];
        player.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width / 16 * 9);
        player.center =  CGPointMake(self.view.center.x, self.view.center.y - NAVBAR_H);
        player.mediaURL = url;
        
        [player showInView:self.view];
    }
    return self;
}

-(void)backBtnPress
{
    [super backBtnPress];
    [self pop];
}

@end
