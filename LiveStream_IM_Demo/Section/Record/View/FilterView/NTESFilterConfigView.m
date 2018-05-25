//
//  NTESFilterConfigView.m
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/4/1.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESFilterConfigView.h"
#import "NTESFilterConfigCell.h"

@interface NTESFilterConfigView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *list;

@end

@implementation NTESFilterConfigView

- (void)doInit
{
    self.alpha = 0.0;
    [self addSubview:self.list];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _list.frame = self.bounds;
}

#pragma mark - Public
- (void)showInView:(UIView *)view complete:(void (^)())complete
{
    [self removeFromSuperview];
    
    if (self.alpha == 0.0)
    {
        [view addSubview:self];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (complete) {
                complete();
            }
        }];
    }
    else
    {
        if (complete) {
            complete();
        }
    }
}

- (void)dismissComplete:(void (^)())complete
{
    if (self.alpha != 0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            if (complete) {
                complete();
            }
        }];
    }
    else
    {
        if (complete) {
            complete();
        }
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _datas.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NTESFilterConfigCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NTESFilterConfigCell" forIndexPath:indexPath];
    
    cell.titleStr = _datas[indexPath.row];
    
    cell.selected = (indexPath.row == _selectIndex);
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:_selectIndex inSection:0];
    NTESFilterConfigCell *cell = (NTESFilterConfigCell *)[collectionView cellForItemAtIndexPath:lastIndexPath];
    cell.selected = NO;
    
    _selectIndex = indexPath.row;
    
    if (_selectBlock) {
        _selectBlock(indexPath.row);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    return CGSizeMake(collectionView.width/_datas.count, collectionView.height);
    return CGSizeMake(60, collectionView.height);
}

#pragma mark - Setter
- (void)setDatas:(NSArray<NSString *> *)datas
{
    _datas = datas;
    
    [_list reloadData];
}

- (void)setSelectIndex:(NSInteger)selectIndex
{
    if (selectIndex < 0) {
        selectIndex = 0;
    }
    if (selectIndex > _datas.count - 1) {
        selectIndex = _datas.count - 1;
    }
    
    _selectIndex = selectIndex;
    
    [_list reloadData];
}

#pragma mark - Getter
- (UICollectionViewFlowLayout *)layout
{
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumLineSpacing = 1.0;
        _layout.minimumInteritemSpacing = 1.0;
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _layout;
}

- (UICollectionView *)list
{
    if (!_list) {
        _list = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) collectionViewLayout:self.layout];
        _list.showsVerticalScrollIndicator = NO;
        _list.showsHorizontalScrollIndicator = NO;
        _list.delegate = self;
        _list.dataSource = self;
        [_list setBackgroundView:nil];
        [_list setBackgroundView:[[UIView alloc] init]];
        _list.backgroundView.backgroundColor = [UIColor clearColor];
        _list.backgroundColor = [UIColor clearColor];
        [_list registerClass:[NTESFilterConfigCell class] forCellWithReuseIdentifier:@"NTESFilterConfigCell"];
    }
    return _list;
}

@end
