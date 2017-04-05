//
//  pSSAvPlayerViewController.h
//  pcKan
//
//  Created by admin on 17/4/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSBaseViewController.h"
#import "UPan_File.h"

@interface pSSAvPlayerViewController : pSSBaseViewController
-(instancetype)initWithFiles:(NSArray *)files playFile:(UPan_File *)playFile;
@end
