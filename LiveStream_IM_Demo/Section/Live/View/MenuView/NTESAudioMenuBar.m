//
//  NTESAudioMenuBar.m
//  NTES_Live_Demo
//
//  Created by zhanggenning on 17/1/20.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "NTESAudioMenuBar.h"
#import "NTESMenuCell.h"
#import "NTESPagingLayout.h"

const CGFloat gAudioMenuRowsEveryPage = 4;
const CGFloat gAudioMenuLinesEveryPage = 1;

@interface NTESAudioMenuBar ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    CGFloat _row;
    CGFloat _line;
}

@property (nonatomic, strong) NSArray *audioInfos;  //伴音选项信息
@property (nonatomic, strong) NTESPagingLayout *pagingLayout; //布局
@property (nonatomic, strong) UICollectionView *menuList; //选项控件

@end

@implementation NTESAudioMenuBar

- (instancetype)init
{
    if (self = [super init])
    {
        [self addSubview:self.menuList];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!CGRectEqualToRect(self.menuList.frame, self.bounds)) {
        self.menuList.frame = self.bounds;
    }
    
    _row = ((self.audioInfos.count > gAudioMenuRowsEveryPage) ? gAudioMenuRowsEveryPage : self.audioInfos.count);
    CGFloat width = (self.width - ((_row - 1) * 1)) / _row;
    CGSize size = CGSizeMake(width, self.height);
    if (!CGSizeEqualToSize(self.pagingLayout.itemSize, size))
    {
        self.pagingLayout.itemSize = size;
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.audioInfos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NTESMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
     
    NSDictionary *dic = self.audioInfos[indexPath.row];
    if (dic) {
        NSString *name = dic[@"name"];
        NSString *icon = dic[@"icon"];
        [cell refreshCell:name icon:icon selectIcon:nil];
    }
    
    cell.selected = (indexPath.row == self.selectedIndex);
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    
    if (self.selectBlock) {
        self.selectBlock(self.selectedIndex);
    }
}

#pragma mark - Getter/Setter
- (NSArray *)audioInfos
{
    if (!_audioInfos) {
        _audioInfos = @[
                        @{@"name": @"无伴音", @"icon": @"audio0"},
                        @{@"name": @"伴音一", @"icon": @"audio1"},
                        @{@"name": @"伴音二", @"icon": @"audio2"}];
    }
    return _audioInfos;
}

- (NTESPagingLayout *)pagingLayout
{
    if (!_pagingLayout) {
        _pagingLayout = [[NTESPagingLayout alloc] init];
        _pagingLayout.minimumLineSpacing = 0.0f;
        _pagingLayout.minimumInteritemSpacing = 0.0f;
    }
    return _pagingLayout;
}

- (UICollectionView *)menuList
{
    if (!_menuList)
    {
        _menuList = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.pagingLayout];
        _menuList.backgroundColor = [UIColor clearColor];
        _menuList.showsVerticalScrollIndicator = NO;
        _menuList.showsHorizontalScrollIndicator = NO;
        _menuList.dataSource = self;
        _menuList.delegate   = self;
        _menuList.bounces = NO;
        [_menuList registerClass:[NTESMenuCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _menuList;
}

- (void)doSetSelectedIndex
{
    [_menuList reloadData];
}

@end
