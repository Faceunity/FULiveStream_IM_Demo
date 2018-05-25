//
//  NTESSettingViewCell.m
//  ShortVideo_Demo
//
//  Created by Netease on 17/2/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESSettingViewCell.h"

const NSInteger gMaxBtnCount = 3;

@interface NTESSettingViewCell ()

@property (nonatomic, strong) UIScrollView *scroll;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) NSMutableArray *btns;

@property (nonatomic, strong) UIView *line;

@end

@implementation NTESSettingViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _selectedIndex = -1;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.scroll];
        [self addSubview:self.titleLab];
        [self addSubview:self.line];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleLab.left = 32.0;
    _titleLab.centerY = self.height/2;
    
    _scroll.frame = CGRectMake(_titleLab.right + 8.0,
                               0,
                               self.width - (_titleLab.right + 8.0) - 4.0,
                               self.height);
    
    _line.frame = CGRectMake(30.0, self.height - 1, self.width - 30.0*2, 1.0);
    
    [self layoutSelectedBtns];
}

#pragma mark - Private
- (void)layoutSelectedBtns
{
    CGFloat width = (_scroll.width - 32.0)/gMaxBtnCount;
    CGFloat height = self.scroll.height;
    
    //滚动视图
    CGFloat contentWidth = ((_btns.count >= gMaxBtnCount) ? (width * _btns.count) : (gMaxBtnCount * width));
    _scroll.contentSize = CGSizeMake(contentWidth, height);
    
    //btn
    __block CGFloat x = 0;
    __block CGFloat y = 0;
    __weak typeof(self) weakSelf = self;
    [_btns enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = (UIButton *)obj;
        if (weakSelf.btns.count == 1) //不足一页右对齐
        {
            x = 2 * width;
        }
        else if (weakSelf.btns.count == 2) //不足一页右对齐
        {
            x = (idx + 1) * width;
        }
        else
        {
            x = idx * width;
        }
        btn.frame = CGRectMake(x, y, width, height);
    }];
}

- (void)makeBtnsWithDatas:(NSArray *)datas
{
    for (UIButton *btn in _btns) {
        [btn removeFromSuperview];
    }
    
    [_btns removeAllObjects];
    
    if (!_btns) {
        _btns = [NSMutableArray array];
    }
    
    for (NSInteger i = 0; i < datas.count; i++) {
        UIButton *btn = [self selectBtn];
        btn.tag = 10 + i;
        NSString *title = [NSString stringWithFormat:@"%@", datas[i]];
        [btn setTitle:title forState:UIControlStateNormal];
        [_btns addObject:btn];
        [self.scroll addSubview:btn];
    }
}

#pragma mark - Public
- (void)configCellWithTitle:(NSString *)title datas:(NSArray *)datas selecedIndex:(NSInteger)selectedIndex
{
    self.titleStr = title;
    self.datas = datas;
    self.selectedIndex = selectedIndex;
    UIButton *btn = (UIButton *)[self viewWithTag:selectedIndex + 10];
    btn.selected = YES;
}

#pragma mark - Action
- (void)btnAction:(UIButton *)btn
{
    NSInteger index = btn.tag - 10;
    
    //选择
    self.selectedIndex = index;

    //选择回调
    if (_selectedBlock) {
        _selectedBlock(index);
    }
}

#pragma mark - Setter/Getter
- (void)setTitleStr:(NSString *)titleStr
{
    _titleStr = titleStr;
    
    if (titleStr) {
        self.titleLab.text = titleStr;
    }
}

- (void)setDatas:(NSArray *)datas
{
    _datas = datas;
    
    [self makeBtnsWithDatas:datas];
    
    [self layoutSelectedBtns];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex)
    {
        //选择btn
        if (_selectedIndex >= 0 && _selectedIndex < _btns.count)
        {
            UIButton *lastBtn =_btns[_selectedIndex];
            lastBtn.selected = NO;
        }
        if (selectedIndex >= 0 && selectedIndex < _btns.count) {
            UIButton *curBtn = _btns[selectedIndex];
            curBtn.selected = YES;
        }
        
        _selectedIndex = selectedIndex;
    }
}

- (UIScrollView *)scroll
{
    if (!_scroll) {
        _scroll = [[UIScrollView alloc] init];
        _scroll.showsHorizontalScrollIndicator = NO;
        _scroll.showsVerticalScrollIndicator = NO;
        _scroll.pagingEnabled = YES;
        _scroll.scrollEnabled = YES;
    }
    return _scroll;
}

- (UILabel *)titleLab
{
    if (!_titleLab)
    {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor colorWithWhite:1.0 alpha:0.4];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.font = [UIFont systemFontOfSize:14.0];
        _titleLab.textAlignment = NSTextAlignmentLeft;
        _titleLab.text = @"默认值";
        [_titleLab sizeToFit];
    }
    return _titleLab;
}

- (UIButton *)selectBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.4] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor lightGrayColor];
    }
    return _line;
}

@end
