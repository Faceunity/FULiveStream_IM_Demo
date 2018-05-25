//
//  NTESFilterMenuBar.m
//  NTES_Live_Demo
//
//  Created by zhanggenning on 17/1/20.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "NTESFilterMenuBar.h"
#import "NTESMenuCell.h"

const CGFloat gFilterMenuRowsEveryPage = 4;
const CGFloat gFilterMenuLinesEveryPage = 1;

@interface NTESFilterMenuBar ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    CGFloat _row;
    CGFloat _line;
    CGRect _lastRect;
}

@property (nonatomic, strong) UILabel *barTitleLab; //名称
@property (nonatomic, strong) NSArray *filterInfos; //滤镜选项信息
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *menuList; //选项控件

@end

@implementation NTESFilterMenuBar
- (instancetype)init
{
    if (self = [super init])
    {
        [self addSubview:self.barTitleLab];
        [self addSubview:self.menuList];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!CGRectEqualToRect(_lastRect, self.bounds))
    {
        self.barTitleLab.frame = CGRectMake(12.0,
                                            20,
                                            self.barTitleLab.width,
                                            self.barTitleLab.height);
        
        
        
        self.menuList.frame = CGRectMake(0,
                                         self.barTitleLab.bottom,
                                         self.width,
                                         128.0);
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
    return CGSizeMake(64.0, self.menuList.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    NSInteger itemCount = self.filterInfos.count;
    CGFloat itemWidth = 64.0;
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
                         @{@"name": @"无",
                           @"icon": @"btn_filter_0_normal",
                           @"selectIcon": @"btn_filter_0_selected"},
                         
                         @{@"name": @"自然",
                           @"icon": @"btn_filter_1_normal",
                           @"selectIcon": @"btn_filter_1_selected"},
                         
                         @{@"name": @"粉嫩",
                           @"icon": @"btn_filter_3_normal",
                           @"selectIcon": @"btn_filter_3_selected"},
                         
                         @{@"name": @"怀旧",
                           @"icon": @"btn_filter_4_normal",
                           @"selectIcon": @"btn_filter_4_selected"},
                         
                         @{@"name": @"黑白",
                           @"icon": @"btn_filter_5_normal",
                           @"selectIcon": @"btn_filter_5_selected"}];
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
        _barTitleLab.text = @"滤镜模式";
        [_barTitleLab sizeToFit];
    }
    return _barTitleLab;

}

#pragma mark - 父类重载
- (void)doSetSelectedIndex
{
    [_menuList reloadData];
}

- (CGFloat)barHeight
{
    return 160.0;
}

@end
