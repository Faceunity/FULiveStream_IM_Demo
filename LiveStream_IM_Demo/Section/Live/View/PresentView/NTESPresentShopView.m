//
//  NTESPresentShopView.m
//  NIMLiveDemo
//
//  Created by chris on 16/3/29.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESPresentShopView.h"
#import "UIView+NTES.h"
#import "NTESPresentShopCell.h"
#import "NTESPresent.h"
#import "NTESPagingLayout.h"

const CGFloat gPresentShopItemInterval = 1.0; //间隔
const NSInteger gPresentShopLinesEveryPage = 1; //每页有几行
const NSInteger gPresentShopRowsEveryPage = 4;  //每页有几列
const CGFloat gPresentShopSendBtnWidth = 64.0;
const CGFloat gPresentShopSendBtnHeight = 32.0;

typedef void(^SendPresentBlock)(NTESPresent *present);

@interface NTESPresentShopFlowLayout : UICollectionViewFlowLayout
@end

@interface NTESPresentShopBar : UIView<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong) NSArray *datas;

@property (nonatomic, strong) NTESPagingLayout *pagingLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *separateLine;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) SendPresentBlock sendPresentBlock;

@end

@interface NTESPresentShopView()
@property (nonatomic,strong) NTESPresentShopBar *bar;
@end

@implementation NTESPresentShopView

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGSize barSize = [self targetBarSize];
    if (!CGSizeEqualToSize(self.bar.size, barSize))
    {
        self.bar.size = barSize;
    }
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.frame = [UIScreen mainScreen].bounds;
        [self addTarget:self action:@selector(onTapBackground:) forControlEvents:UIControlEventTouchUpInside];
        
        _bar = [[NTESPresentShopBar alloc] init];
        _bar.size = [self targetBarSize];
        _bar.top = self.height;
        __weak typeof(self) weakSelf = self;
        _bar.sendPresentBlock = ^(NTESPresent *present){
            [weakSelf dismiss];
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSelectPresent:)]) {
                [weakSelf.delegate didSelectPresent:present];
            }
        };
        [self addSubview:self.bar];
    }
    
    return self;
}

- (void)setPresents:(NSArray<NTESPresent *> *)presents
{
    self.bar.datas = presents;
}

- (void)onTapBackground:(id)sender
{
    [self dismiss];
}

- (CGSize)targetBarSize
{
    CGFloat itemWidth = self.width / gPresentShopRowsEveryPage;
    CGFloat itemHeight = itemWidth;
    CGFloat targetWidth = self.width;
    CGFloat targetHeight = itemHeight * gPresentShopLinesEveryPage + gPresentShopItemInterval + gPresentShopSendBtnHeight + 4.0*2;
    CGSize  targetSize = CGSizeMake(targetWidth, targetHeight);
    return targetSize;
}

#pragma mark - Public
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

- (void)showPresentShop:(NSArray <NTESPresent *> *)presents
{
    self.bar.datas = presents;
    
    [self show];
}

@end


#pragma mark - NTESPresentShopBar
@implementation NTESPresentShopBar
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //collectionView
    CGFloat itemWidth = (self.width - (gPresentShopRowsEveryPage - 1) * 1.0) / gPresentShopRowsEveryPage;
    CGFloat itemHeight = itemWidth;
    self.collectionView.frame = CGRectMake(0, 0, self.width, itemHeight);

    //itemSize
    CGSize itemSize = CGSizeMake(itemWidth, itemHeight);
    if (!CGSizeEqualToSize(_pagingLayout.itemSize, itemSize))
    {
        _pagingLayout.itemSize = itemSize;
    }
    
    //separateLine
    self.separateLine.frame = CGRectMake(self.collectionView.left,
                                         self.collectionView.bottom,
                                         self.collectionView.width, 1.0);
    
    //sendbtn
    self.sendButton.frame = CGRectMake(self.width - gPresentShopSendBtnWidth - 4.0,
                                       self.height - gPresentShopSendBtnHeight - 4.0,
                                       gPresentShopSendBtnWidth,
                                       gPresentShopSendBtnHeight);
}

#pragma mark - Public
- (instancetype)init
{
    if (self = [super init])
    {
        self.backgroundColor = UIColorFromRGBA(0x000000, 0.8);
        [self addSubview:self.collectionView];
        [self addSubview:self.separateLine];
        [self addSubview:self.sendButton];
        self.selectIndex = -1; //开始不选择
    }
    return self;
}

#pragma mark - Action
- (void)onSend:(id)sender
{
    if (_sendPresentBlock) {
        _sendPresentBlock(_datas[self.selectIndex]);
    }
}

#pragma mark - <UICollectionViewDelegate,UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NTESPresentShopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"present" forIndexPath:indexPath];
    
    [cell configCellSeparate:indexPath.row
               rowsEveryPage:gPresentShopRowsEveryPage
              linesEveryPage:gPresentShopLinesEveryPage];
    
    NTESPresent *present = _datas[indexPath.row];
    cell.selected = (self.selectIndex == indexPath.row);
    [cell refreshPresent:present];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectIndex = indexPath.row;
    [collectionView reloadData];
}

#pragma mark - Getter/Setter
- (NTESPagingLayout *)pagingLayout
{
    if (!_pagingLayout) {
        _pagingLayout = [[NTESPagingLayout alloc] init];
        _pagingLayout.minimumLineSpacing = 1.0f;
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
        [_collectionView registerClass:[NTESPresentShopCell class]
            forCellWithReuseIdentifier:@"present"];
    }
    return _collectionView;
}

- (UIView *)separateLine
{
    if (!_separateLine)
    {
        _separateLine = [[UIView alloc] init];
        _separateLine.backgroundColor = UIColorFromRGBA(0xffffff, 0.3);
    }
    return _separateLine;
}

- (UIButton *)sendButton
{
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setBackgroundColor:[UIColor whiteColor]];
        [_sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_sendButton setTitle:@"赠送" forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _sendButton.size = CGSizeMake(57.f, 26.f);
        _sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        _sendButton.right =  self.width  - 8.f;
        _sendButton.bottom = self.height - 5.f;
        _sendButton.layer.cornerRadius = 4.f;
        [_sendButton addTarget:self action:@selector(onSend:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

- (void)setDatas:(NSArray<NTESPresent *> *)datas
{
    _datas = datas;
    
    [self.collectionView reloadData];
}

- (void)setSelectIndex:(NSInteger)selectIndex
{
    _selectIndex = selectIndex;
    
    _sendButton.enabled = (selectIndex >= 0 && selectIndex < _datas.count);
}

@end
