//
//  NTESSettingView.m
//  ShortVideo_Demo
//
//  Created by Netease on 17/2/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESSettingView.h"
#import "NTESSettingViewCell.h"

@interface NTESSettingView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIView *titleLine;
@property (nonatomic, strong) UITableView *list;

@property (nonatomic, strong) NSArray *durations;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *resolutions;
@property (nonatomic, strong) NSArray *screenScales;
@property (nonatomic, strong) NSMutableArray *durationStrs;
@property (nonatomic, strong) NSMutableArray *sectionStrs;
@property (nonatomic, strong) NSArray *resolutionStrs;
@property (nonatomic, strong) NSArray *screenScaleStrs;

@property (nonatomic, assign) NSInteger selectedDurationIndex;
@property (nonatomic, assign) NSInteger selectedSectionIndex;
@property (nonatomic, assign) NSInteger selectedResolutionIndex;
@property (nonatomic, assign) NSInteger selectedScreenIndex;

@end

@implementation NTESSettingView

- (void)doInit
{
    self.alpha = 0.0;
    self.clipsToBounds = YES;
    
    _resolutions = @[@(NTESRecordResolutionSD), @(NTESRecordResolutionHD)];
    _screenScales = @[@(NTESRecordScreenScale16x9), @(NTESRecordScreenScale4x3), @(NTESRecordScreenScale1x1)];
    _durations = @[@(6), @(10), @(30)];
    _sections = @[@(1), @(2), @(3)];
    
    
    _durationStrs = [NSMutableArray array];
    for (NSNumber *num in _durations) {
        NSString *str = [NSString stringWithFormat:@"%@S", num];
        [_durationStrs addObject:str];
    }
    _sectionStrs = [NSMutableArray array];
    for (NSNumber *num in _sections) {
        NSString *str = [NSString stringWithFormat:@"%@段",num];
        [_sectionStrs addObject:str];
    }
    _screenScaleStrs = @[@"16:9", @"4:3", @"1:1"];
    _resolutionStrs = @[@"流畅", @"高清"];
    
    _selectedScreenIndex = 0;
    _selectedDurationIndex = 6;
    _selectedSectionIndex = 1;
    _selectedResolutionIndex = 0;
    
    //初始化
    [self addSubview:self.titleLab];
    [self addSubview:self.titleLine];
    [self addSubview:self.list];
    
    [self.list reloadData];
}

- (void)configWithEntity:(NTESRecordConfigEntity *)entity
{
    __weak typeof(self) weakSelf = self;
    
    if (!entity) {
        return;
    }
    
    //段落
    [_sections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (entity.section == [obj integerValue]) {
            weakSelf.selectedSectionIndex = idx;
            *stop = YES;
        }
    }];
    
    //时长
    [_durations enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (entity.duration == [obj integerValue]) {
            weakSelf.selectedDurationIndex = idx;
            *stop = YES;
        }
    }];
    
    //分辨率
    [_resolutions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (entity.resolution == [obj integerValue]) {
            weakSelf.selectedResolutionIndex = idx;
            *stop = YES;
        }
    }];
    
    //画幅
    [_resolutions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (entity.screenScale == [obj integerValue]) {
            weakSelf.selectedScreenIndex = idx;
            *stop = YES;
        }
    }];
    
    [self.list reloadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLine.frame = CGRectMake(30, 57.0, self.width - 30*2, 1);
    self.titleLab.center = CGPointMake(self.width/2, self.titleLine.top/2);
    self.list.frame = CGRectMake(0,
                                 self.titleLine.bottom + 2,
                                 self.width,
                                 self.height - self.titleLine.bottom + 2);
}

#pragma mark - Public
- (void)showInView:(UIView *)view complete:(void(^)())complete
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

- (void)dismissComplete:(void(^)())complete
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

- (CGFloat)settingHeight
{
    return 272.0;
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) //选择分辨率
    {
        NTESSettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NTESSettingViewCell"
                                                                    forIndexPath:indexPath];
        
        [cell configCellWithTitle:@"清晰度" datas:_resolutionStrs selecedIndex:_selectedResolutionIndex];
        
        //选择回调
        __weak typeof(self) weakSelf = self;
        cell.selectedBlock = ^(NSInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            strongSelf.selectedResolutionIndex = index;
            
            if (strongSelf.delegate &&
                [strongSelf.delegate respondsToSelector:@selector(NTESSettingView:selectResolution:)])
            {
                NTESRecordResolution resolution = [strongSelf.resolutions[index] integerValue];
                [strongSelf.delegate NTESSettingView:strongSelf selectResolution:resolution];
            }
        };
        return cell;
    }
    else if (indexPath.row == 1) //选择段数
    {
        NTESSettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NTESSettingViewCell"
                                                                    forIndexPath:indexPath];
        [cell configCellWithTitle:@"分段数" datas:_sectionStrs selecedIndex:_selectedSectionIndex];
        
        //选择回调
        __weak typeof(self) weakSelf = self;
        cell.selectedBlock = ^(NSInteger index){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.selectedSectionIndex = index;
            if (strongSelf.delegate &&
                [strongSelf.delegate respondsToSelector:@selector(NTESSettingView:selectSection:)])
            {
                NSInteger section = [strongSelf.sections[index] integerValue];
                [strongSelf.delegate NTESSettingView:strongSelf selectSection:section];
            }
        };
        return cell;
    }
    else if (indexPath.row == 2) //选择时长
    {
        NTESSettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NTESSettingViewCell"
                                                                    forIndexPath:indexPath];
        
        [cell configCellWithTitle:@"总时长" datas:_durationStrs selecedIndex:_selectedDurationIndex];
        
        //选择回调
        __weak typeof(self) weakSelf = self;
        cell.selectedBlock = ^(NSInteger index){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.selectedDurationIndex = index;
            if (strongSelf.delegate &&
                [strongSelf.delegate respondsToSelector:@selector(NTESSettingView:selectDuration:)])
            {
                NSInteger duration = [strongSelf.durations[index] integerValue];
                
                [strongSelf.delegate NTESSettingView:strongSelf selectDuration:duration];
            }
        };
        return cell;
    }
    else if (indexPath.row == 3) //选择画幅
    {
        NTESSettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NTESSettingViewCell"
                                                                    forIndexPath:indexPath];
        [cell configCellWithTitle:@"画幅" datas:_screenScaleStrs selecedIndex:_selectedScreenIndex];
        
        //选择回调
        __weak typeof(self) weakSelf = self;
        cell.selectedBlock = ^(NSInteger index){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.selectedScreenIndex = index;
            if (strongSelf.delegate &&
                [strongSelf.delegate respondsToSelector:@selector(NTESSettingView:selectScreen:)])
            {
                NTESRecordScreenScale screenScale = [strongSelf.screenScales[index] integerValue];
                [strongSelf.delegate NTESSettingView:strongSelf selectScreen:screenScale];
            }
        };
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"
                                                                forIndexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53.5;
}

#pragma mark - Getter
- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor colorWithWhite:1.0 alpha:0.4];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.font = [UIFont systemFontOfSize:14.0];
        _titleLab.text = @"视频设置";
        [_titleLab sizeToFit];
    }
    return _titleLab;
}

- (UIView *)titleLine
{
    if (!_titleLine) {
        _titleLine = [[UIView alloc] init];
        _titleLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    }
    return _titleLine;
}

- (UITableView *)list
{
    if (!_list) {
        _list = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStylePlain];
        _list.dataSource = self;
        _list.delegate = self;
        _list.showsVerticalScrollIndicator = NO;
        _list.showsHorizontalScrollIndicator = NO;
        _list.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_list setBackgroundView:nil];
        [_list setBackgroundView:[[UIView alloc]init]];
        _list.backgroundView.backgroundColor = [UIColor clearColor];
        _list.backgroundColor = [UIColor clearColor];
        _list.clipsToBounds = YES;
        _list.bounces = NO;
        _list.scrollEnabled = NO;
        [_list registerClass:[NTESSettingViewCell class] forCellReuseIdentifier:@"NTESSettingViewCell"];
        [_list registerClass:[UITableViewCell class] forCellReuseIdentifier:@"defaultCell"];
    }
    return _list;
}

@end
