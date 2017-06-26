//
//  AJMPMediaPreviewerImagePlayerView.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/21.
//  Copyright © 2017年 AJ. All rights reserved.
//

#define AJMPMediaPreviewerImagePlayerCellIdentifier @"AJMPMediaPreviewerImagePlayerCell"

#import "AJMPMediaPreviewerImagePlayerView.h"
#import "AJMPMediaPreviewerImagePlayerCell.h"

@interface AJMPMediaPreviewerImagePlayerView ()<UICollectionViewDataSource,UICollectionViewDelegate>

//内容视图
@property (nonatomic ,weak)UICollectionView * collectionView;

@property (nonatomic ,assign)int currentIndex;//当前选中的图片的index
@property (nonatomic ,assign)int maxNumberOfMedia;
@property (nonatomic ,strong)NSMutableArray * selectedMediaInfoModelArray;
@property (nonatomic ,retain)NSArray * allMediaInfoModelArray;
@property (nonatomic ,copy)void(^chooseBtnClickBlock)(AJMPMediaInfoModel * mediaInfoModel);
@property (nonatomic ,copy)void(^itemScrollBlock)(int indexRow);


@end

@implementation AJMPMediaPreviewerImagePlayerView


#pragma mark - 懒加载

-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0.0;
        layout.minimumInteritemSpacing = 0.0;
        layout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) collectionViewLayout:layout];
        collectionView.backgroundColor=[UIColor whiteColor];
        
        //注册cell
        [collectionView registerClass:[AJMPMediaPreviewerImagePlayerCell class] forCellWithReuseIdentifier:AJMPMediaPreviewerImagePlayerCellIdentifier];
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        
        collectionView.pagingEnabled=YES;
        
        [self addSubview:collectionView];
        _collectionView=collectionView;
    }
    return _collectionView;
}


#pragma mark - setter

-(void)setImagePreviewerWithCurrentIndex:(int)currentIndex maxNumberOfMedia:(int)maxNumberOfMedia selectedMediaInfoModelArray:(NSMutableArray *)selectedMediaInfoModelArray allMediaInfoModelArray:(NSArray *)allMediaInfoModelArray chooseBtnClickBlock:(void(^)(AJMPMediaInfoModel * mediaInfoModel))chooseBtnClickBlock itemScrollBlock:(void(^)(int indexRow))itemScrollBlock
{
    _currentIndex=currentIndex;
    _maxNumberOfMedia=maxNumberOfMedia;
    _selectedMediaInfoModelArray=selectedMediaInfoModelArray;
    _allMediaInfoModelArray=allMediaInfoModelArray;
    _chooseBtnClickBlock=chooseBtnClickBlock;
    _itemScrollBlock=itemScrollBlock;
    
    //刷新collectio，并移至相应的图
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}



#pragma mark - UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allMediaInfoModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    AJMPMediaPreviewerImagePlayerCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:AJMPMediaPreviewerImagePlayerCellIdentifier forIndexPath:indexPath];
    
    AJMPMediaInfoModel * mediaInfoModel=self.allMediaInfoModelArray[indexPath.row];
    
    __weak __typeof__(self)weakSelf=self;
    
    [cell setMediaInfoModel:mediaInfoModel maxNumberOfMedia:self.maxNumberOfMedia selectedMediaInfoModelArray:self.selectedMediaInfoModelArray chooseBtnClickBlock:^(AJMPMediaInfoModel *mediaInfoModel) {
        
        if (weakSelf.chooseBtnClickBlock) {
            weakSelf.chooseBtnClickBlock(mediaInfoModel);
        }
        
    }];
    
    if (self.itemScrollBlock) {
        self.itemScrollBlock((int)indexPath.row);
    }
    
    return cell;
    
}



@end
