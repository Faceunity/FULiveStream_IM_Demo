//
//  NTESShareMenuBar.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/2/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESShareMenuBar.h"
#import "NTESMenuCell.h"

const CGFloat gItemWidth = 45.0;

@interface NTESShareMenuBar ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    CGFloat _row;
    CGFloat _line;
    CGRect _lastRect;
}
@property (nonatomic, strong) UILabel *barTitleLab; //名称
@property (nonatomic, strong) UIView *separateLineTop; //分割线上
@property (nonatomic, strong) UIView *separateLineBottom; //分割线下
@property (nonatomic, strong) UIButton *cancelBtn;  //取消
@property (nonatomic, strong) NSArray *filterInfos; //滤镜选项信息
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *menuList; //选项控件

@end

@implementation NTESShareMenuBar

- (instancetype)init
{
    if (self = [super init])
    {
        [self addSubview:self.barTitleLab];
        [self addSubview:self.menuList];
        [self addSubview:self.separateLineTop];
        [self addSubview: self.separateLineBottom];
        [self addSubview:self.cancelBtn];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (newWindow)
    {
        self.selectedIndex = -1;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!CGRectEqualToRect(_lastRect, self.bounds))
    {
        self.separateLineTop.frame = CGRectMake(16, 65, self.width - 2*16, 1);
        
        self.separateLineBottom.frame = CGRectMake(16, self.height - 66, self.width - 2*16, 1.0);
        
        self.barTitleLab.center = CGPointMake(self.width/2, self.separateLineTop.top/2);
        
        self.menuList.frame = CGRectMake(0,
                                         self.separateLineTop.bottom + 20,
                                         (gItemWidth + 45.0) * self.filterInfos.count - 45.0,
                                         self.separateLineBottom.top - self.separateLineTop.bottom - 20);
        self.menuList.center = CGPointMake(self.width/2, self.menuList.centerY);
        
        self.cancelBtn.frame = CGRectMake(0, self.separateLineBottom.bottom, self.width, 65);
    }
}

- (void)cancelAction:(UIButton *)btn
{
    if (_cancelBlock) {
        _cancelBlock();
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.filterInfos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NTESMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [cell hiddenAllSeparate];
    
    NSDictionary *dic = self.filterInfos[indexPath.row];
    if (dic) {
        NSString *name = dic[@"name"];
        NSString *icon = dic[@"icon"];
        NSString *selectIcon = dic[@"selectIcon"];
        [cell refreshCell:name icon:icon selectIcon:selectIcon];
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(gItemWidth, self.menuList.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    NSInteger itemCount = self.filterInfos.count;
    CGFloat itemWidth = gItemWidth;
    CGFloat interval = 1.0;
    if ((itemWidth + interval) * itemCount > self.menuList.width)
    {
        interval = ((self.menuList.width + itemWidth/2) - itemCount*itemWidth) / (itemCount - 1);
    }
    else
    {
        interval = (self.menuList.width - itemWidth * itemCount) / (itemCount - 1);
    }
    return interval;
}

#pragma mark - Getter/Setter
-(NSArray *)filterInfos
{
    if (!_filterInfos) {
        _filterInfos = @[
                         @{@"name": @"",
                           @"icon": @"btn_share_http",
                           @"selectIcon": @"btn_share_http_s"},
                         
                         @{@"name": @"",
                           @"icon": @"btn_share_hls",
                           @"selectIcon": @"btn_share_hls_s"},
                         
                         @{@"name": @"",
                           @"icon": @"btn_share_rtmp",
                           @"selectIcon": @"btn_share_rtmp_s"},
                         ];
    }
    return _filterInfos;
}

- (UICollectionViewFlowLayout *)layout
{
    if (!_layout)
    {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumInteritemSpacing = 0.1f;
        _layout.minimumInteritemSpacing = 0.1f;
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _layout;
}

- (UICollectionView *)menuList
{
    if (!_menuList)
    {
        _menuList = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
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

- (UILabel *)barTitleLab
{
    if (!_barTitleLab)
    {
        _barTitleLab = [[UILabel alloc] init];
        _barTitleLab.font = [UIFont systemFontOfSize:14.0];
        _barTitleLab.textColor = [UIColor whiteColor];
        _barTitleLab.text = @"分享地址类型";
        [_barTitleLab sizeToFit];
    }
    return _barTitleLab;
    
}

- (UIView *)separateLineTop
{
    if (!_separateLineTop) {
        _separateLineTop = [[UIView alloc] init];
        _separateLineTop.backgroundColor = [UIColor colorWithWhite:1 alpha:0.45];
    }
    return _separateLineTop;
}

- (UIView *)separateLineBottom
{
    if (!_separateLineBottom) {
        _separateLineBottom = [[UIView alloc] init];
        _separateLineBottom.backgroundColor = [UIColor colorWithWhite:1 alpha:0.45];
    }
    return _separateLineBottom;
}

- (UIButton *)cancelBtn
{
    if (!_cancelBtn)
    {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

#pragma mark - 父类重载
- (void)doSetSelectedIndex
{
    [_menuList reloadData];
}

- (CGFloat)barHeight
{
    return 230.0;
}

@end
