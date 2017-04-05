//
//  pSSAudioListView.h
//  pcKan
//
//  Created by admin on 17/4/3.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol audioListDelegate <NSObject>
-(NSArray *)audioDataSource;
-(void)didSelectWithIndex:(NSInteger)index;
@end

@interface pSSAudioListView : UITableView
@property (nonatomic, weak) id<audioListDelegate> m_delegate;
@end
