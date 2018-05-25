//
//  NTESPresentBoxView.m
//  NIMLiveDemo
//
//  Created by chris on 16/3/30.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESPresentBoxView.h"
#import "UIView+NTES.h"
#import "NTESPresentBoxCell.h"
#import "NTESPresent.h"
#import "NTESPresentEmptyView.h"
#import "NTESPagingLayout.h"

const NSInteger gPresentBoxLinesEveryPage = 2; //每页有几行
const NSInteger gPresentBoxRowsEveryPage = 4;  //每页有几列

@interface NTESPresentMessageBoxBar : UIView<UICollectionViewDelegate,UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) NTESPagingLayout *pagingLayout;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIPageControl *pageCtl;

@property (nonatomic, strong) NTESPresentEmptyView *emptyTip;

@property (nonatomic, strong) NSArray<NTESPresent *> *datas;

@end

@interface NTESPresentBoxView()

@property (nonatomic,strong) NTESPresentMessageBoxBar *bar;

@end

@implementation NTESPresentBoxView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize  targetSize = [self targetBarSize];
    if (!CGSizeEqualToSize(self.bar.size, targetSize)) {
        
        if (self.bar.top != self.bottom)
        {
            self.bar.frame = CGRectMake(0,
                                        self.height - targetSize.height,
                                        targetSize.width,
                                        targetSize.height);
        }
        else
        {
            self.bar.size = targetSize;
        }
    }
}

#pragma mark - Public
- (instancetype)init
{
    if (self = [super init])
    {
        self.frame = [UIScreen mainScreen].bounds;
        [self addTarget:self action:@selector(onTapBackground:) forControlEvents:UIControlEventTouchUpInside];
        self.bar = [[NTESPresentMessageBoxBar alloc] init];
        CGSize barSize = [self targetBarSize];
        self.bar.frame = CGRectMake(0, self.height, barSize.width, barSize.height);
        [self addSubview:self.bar];
    }
    
    return self;
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    self.bar.top = self.height;
    [UIView animateWithDuration:0.25 animations:^{
        self.bar.bottom = self.height;
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bar.top = self.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (CGSize)targetBarSize
{
    CGFloat itemWidth = self.width / gPresentBoxRowsEveryPage;
    CGFloat itemHeight = itemWidth;
    CGFloat targetWidth = self.width;
    
    CGFloat targetHeight = itemHeight * gPresentBoxLinesEveryPage;
    if (self.bar.datas.count != 0)
    {
        NSInteger lines = self.bar.datas.count / gPresentBoxRowsEveryPage + 1;
        if (lines > gPresentBoxLinesEveryPage) {
            lines = gPresentBoxLinesEveryPage;
        }
        targetHeight = itemHeight * lines;
    }
    CGSize  targetSize = CGSizeMake(targetWidth, targetHeight);
    return targetSize;
}

- (void)setPresents:(NSArray<NTESPresent *> *)presents
{
    self.bar.datas = presents;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Action
- (void)onTapBackground:(id)sender
{
    [self dismiss];
}

@end

@implementation NTESPresentMessageBoxBar

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect colFrame = CGRectMake(0, 0, self.width, self.height);
    
    if (!CGRectEqualToRect(self.collectionView.frame, colFrame)) {
        self.collectionView.frame = colFrame;
    }

    CGRect pageFrame = CGRectMake(0, self.collectionView.bottom, self.width, 10.0);
    
    if (!CGRectEqualToRect(self.pageCtl.frame, pageFrame)) {
        self.pageCtl.frame = pageFrame;
    }
    
    if (!CGRectEqualToRect(self.emptyTip.frame, self.bounds)) {
        self.emptyTip.frame = self.bounds;
    }
    
    CGFloat itemWidth = (self.width - (gPresentBoxRowsEveryPage - 1) * 1.0) / gPresentBoxRowsEveryPage;
    CGFloat itemHeight = itemWidth;
    CGSize itemSize = CGSizeMake(itemWidth, itemHeight);
    if (!CGSizeEqualToSize(_pagingLayout.itemSize, itemSize))
    {
        _pagingLayout.itemSize = itemSize;
    }
}

#pragma mark - Public
- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = UIColorFromRGBA(0x0, .8f);
    }
    return self;
}

#pragma mark - <UICollectionViewDelegate,UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NTESPresentBoxCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"present"
                                                                         forIndexPath:indexPath];
    cell.userInteractionEnabled = NO;
    [cell configCellSeparate:indexPath.row
               rowsEveryPage:gPresentBoxRowsEveryPage
              linesEveryPage:gPresentBoxLinesEveryPage];

    NTESPresent *present = self.datas[indexPath.row];
    [cell refreshPresent:present count:present.count];
    
    return cell;
}

#pragma mark - Getter/Setter

- (NTESPagingLayout *)pagingLayout
{
    if (!_pagingLayout) {
        _pagingLayout = [[NTESPagingLayout alloc] init];
        _pagingLayout.minimumLineSpacing = 0.0f;
        _pagingLayout.minimumInteritemSpacing = 0.0f;
    }
    return _pagingLayout;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width)
                                             collectionViewLayout:self.pagingLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate   = self;
        [_collectionView registerClass:[NTESPresentBoxCell class]   forCellWithReuseIdentifier:@"present"];
    }
    return _collectionView;
}

- (UIPageControl *)pageCtl
{
    if (!_pageCtl)
    {
        _pageCtl = [[UIPageControl alloc] init];
    }
    return _pageCtl;
}

- (NTESPresentEmptyView *)emptyTip
{
    if (!_emptyTip) {
        _emptyTip = [NTESPresentEmptyView emptyViewWithInfo:@"暂时还没有礼物哦"];
    }
    return _emptyTip;
}

- (void)setDatas:(NSArray<NTESPresent *> *)datas
{
    _datas = datas;
    
    [self.collectionView removeFromSuperview];
    [self.emptyTip removeFromSuperview];
    
    if (!datas || datas.count == 0)
    {
        [self addSubview:self.emptyTip];
    }
    else
    {
        [self addSubview:self.collectionView];
        [self.collectionView reloadData];
        [self addSubview:self.pageCtl];
        self.pageCtl.numberOfPages = datas.count/(gPresentBoxLinesEveryPage*gPresentBoxRowsEveryPage);
    }
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _collectionView) {
        NSInteger currentIndex = scrollView.contentOffset.x / self.width;
        self.pageCtl.currentPage = currentIndex;
    }
}

@end
