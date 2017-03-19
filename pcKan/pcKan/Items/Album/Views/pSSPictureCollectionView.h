//
//  pSSPictureCollectionView.h
//  pcKan
//
//  Created by admin on 17/3/19.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PictureCollectionViewDelegate <NSObject>
-(NSArray *)PictureCollection_DataSource;
@optional
-(void)PictureCollection_didSelectionWithIndexPath:(NSIndexPath *)indexPath;
-(void)nowDisplayCellIndex:(NSIndexPath *)indexPath;
@end

@interface pSSPictureCollectionView : UICollectionView
@property (nonatomic, assign) id<PictureCollectionViewDelegate> m_delegate;
@end
