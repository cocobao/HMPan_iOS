//
//  UPan_FileTableView.h
//  pcKan
//
//  Created by admin on 2017/3/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPan_File.h"

@protocol UPanFileDelegate <NSObject>
-(void)didDeleteFile:(UPan_File *)file;
-(void)accessButtonWithIndex:(NSIndexPath *)indexPath;
@optional
-(NSArray *)UPanFileDataSource;
-(void)didSelectFile:(UPan_File *)file;
@end

@interface UPan_FileTableView : UITableView
@property (nonatomic, weak) id<UPanFileDelegate> m_delegate;
- (void)headerRereshing:(BOOL)b rereshingBlock:(void (^)())block;
@end
