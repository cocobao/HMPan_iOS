//
//  pSSPictureCollectionView.m
//  pcKan
//
//  Created by admin on 17/3/19.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pSSPictureCollectionView.h"
#import "pSSPictureCollectionViewCell.h"

#define CEll_identify @"cell_identify"

@interface pSSPictureCollectionView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation pSSPictureCollectionView

-(instancetype)initWithFrame:(CGRect)frame
{
    CGFloat w = frame.size.width;
    CGFloat h = frame.size.height;
    UICollectionViewFlowLayout *flowLayout = [self flowLayoutWithItemSize:CGSizeMake(w, h)];
    
    self = [super initWithFrame:frame collectionViewLayout:flowLayout];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.dataSource = self;
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        [self registerClass:[pSSPictureCollectionViewCell class] forCellWithReuseIdentifier:CEll_identify];
    }
    return self;
}

-(UICollectionViewFlowLayout *)flowLayoutWithItemSize:(CGSize)itemSize
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = itemSize;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, -10, 0, -10);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    return layout;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(PictureCollection_DataSource)]) {
        NSArray *arr = [self.m_delegate PictureCollection_DataSource];
        return [arr count];
    }
    
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    pSSPictureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CEll_identify forIndexPath:indexPath];
    
    if (self.m_delegate) {
        if ([self.m_delegate respondsToSelector:@selector(PictureCollection_DataSource)]) {
            cell.mAssetModel = [[self.m_delegate PictureCollection_DataSource] objectAtIndex:indexPath.row];
        }
        
        if ([self.m_delegate respondsToSelector:@selector(nowDisplayCellIndex:)]) {
            [self.m_delegate nowDisplayCellIndex:indexPath];
        }
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(PictureCollection_didSelectionWithIndexPath:)]) {
        [self.m_delegate PictureCollection_didSelectionWithIndexPath:indexPath];
    }
}

@end
