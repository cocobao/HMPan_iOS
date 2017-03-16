//
//  pSSAlbumDetailCollectionView.m
//  picSimpleSend
//
//  Created by admin on 2016/10/11.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pSSAlbumDetailCollectionView.h"
#import "pSSAlbumDetailCollectionViewCell.h"

#define CEll_identify @"cell_identify"

@interface pSSAlbumDetailCollectionView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation pSSAlbumDetailCollectionView

-(instancetype)initWithFrame:(CGRect)frame
{
    CGFloat w = frame.size.width/4;
    CGFloat h = w;
    UICollectionViewFlowLayout *flowLayout = [self flowLayoutWithItemSize:CGSizeMake(w, h)];
    
    self = [super initWithFrame:frame collectionViewLayout:flowLayout];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.dataSource = self;
        self.alwaysBounceVertical = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator   = NO;
        
        [self registerClass:[pSSAlbumDetailCollectionViewCell class] forCellWithReuseIdentifier:CEll_identify];
    }
    return self;
}

-(UICollectionViewFlowLayout *)flowLayoutWithItemSize:(CGSize)itemSize
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = itemSize;
    layout.minimumLineSpacing = 4;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, -4, -2, -4);
    return layout;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(AlbumDetail_DataSource)]) {
        NSArray *arr = [self.m_delegate AlbumDetail_DataSource];
        if (arr) {
            return [arr count];
        }
    }
    
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    pSSAlbumDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CEll_identify forIndexPath:indexPath];
    
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(AlbumDetail_DataSource)]) {
        cell.mMdel = [[self.m_delegate AlbumDetail_DataSource] objectAtIndex:indexPath.row];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(AlbumDetail_didSelectionWithIndexPath:)]) {
        [self.m_delegate AlbumDetail_didSelectionWithIndexPath:indexPath];
    }
}

@end
