//
//  pSSAlbumDetailCollectionView.h
//  picSimpleSend
//
//  Created by admin on 2016/10/11.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AlbumDetailCollectionViewDelegate <NSObject>
@optional
-(NSArray *)AlbumDetail_DataSource;
-(void)AlbumDetail_didSelectionWithIndexPath:(NSIndexPath *)indexPath;
@end

@interface pSSAlbumDetailCollectionView : UICollectionView
@property (nonatomic, assign) id<AlbumDetailCollectionViewDelegate> m_delegate;
@property (nonatomic, assign) BOOL isSelectState;
@end
