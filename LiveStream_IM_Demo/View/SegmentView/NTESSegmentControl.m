//
//  NTESSegmentControl.m
//  NEUIDemo
//
//  Created by Netease on 17/1/3.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESSegmentControl.h"

const NSInteger gHeaderBtnStartTag = 10000;
const CGFloat gLineHeight = 2.0;
const CGFloat gLineEdgeOffset = 24.0;
const CGFloat gHeaderHeight = 48.0;

@interface NTESSegmentControl ()<UIScrollViewDelegate>

{
    NSArray *_items;
    BOOL _enableLeft;
    BOOL _enableRight;
}

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftEdgePan;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *rightEdgePan;

@property (nonatomic, assign) BOOL enableEdgePan; //使用边缘手势

@end

@implementation NTESSegmentControl

- (instancetype)initWithItems:(NSArray<UIView *> *)items enableEdgePan:(BOOL)enableEdgePan andHighlightTitle:(BOOL)highlighted
{
    if (self = [super init])
    {
        _items = items;
        self.isTitleHighlighted = highlighted;
        self.enableEdgePan = enableEdgePan;
        [self setupViewsWithItems:items];
        self.isSeparateLineFull = YES;
    }
    return self;
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment
{
    UIButton *btn = [self.headerView viewWithTag:(segment + gHeaderBtnStartTag)];
    if (btn) {
        [btn setTitle:title forState:UIControlStateNormal];
    }
}

- (void)setupViewsWithItems:(NSArray *)items
{
    for (NSInteger index = 0; index < items.count; index++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = [UIFont systemFontOfSize:17.0];
        if (_isTitleHighlighted) {
            if (index == 0) {
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else {
                [btn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            }
        }
        else {
            [btn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        }
        btn.tag = gHeaderBtnStartTag + index;
        [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:btn];
        [self.headerView addSubview:self.lineView];
        [self.mainScrollView addSubview:items[index]];
    }
    [self addSubview:self.separateLine];
    [self addSubview:self.headerView];
    [self addSubview:self.mainScrollView];
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    if (self.headerView.width != self.width || self.mainScrollView.height != self.height)
    {
        //header
        self.headerView.frame = CGRectMake(0, 0, self.width, gHeaderHeight);
        
        //separate line
        if (_isSeparateLineFull) {
            self.separateLine.frame = CGRectMake(0, _headerView.bottom, self.width, 0.5);
        }
        else {
            self.separateLine.frame = CGRectMake(10, _headerView.bottom, self.width - 20, 0.5);
        }
        
        //scroll view
        self.mainScrollView.frame = CGRectMake(0,
                                       _separateLine.bottom,
                                       self.width,
                                       self.height - _separateLine.bottom);
        self.mainScrollView.contentSize = CGSizeMake(_mainScrollView.width * _items.count,
                                                     _mainScrollView.height);
        
        //btn & vc.view
        CGFloat btnWidth = 0.0;
        for (NSInteger index = 0; index < _items.count; index++)
        {
            btnWidth = self.headerView.width / _items.count;
            UIButton *btn = [self.headerView viewWithTag:(gHeaderBtnStartTag + index)];
            btn.frame = CGRectMake(index * btnWidth, 0, btnWidth, self.headerView.height);
            
            UIView *view = _items[index];
            view.frame = CGRectMake(index * self.mainScrollView.width,
                                    0,
                                    self.mainScrollView.width,
                                    self.mainScrollView.height);
        }
        
        //select line
        self.lineView.frame = CGRectMake(_selectedSegmentIndex * btnWidth + gLineEdgeOffset,
                                         _headerView.bottom - gLineHeight,
                                         btnWidth - (gLineEdgeOffset * 2),
                                         gLineHeight);
        
        [self.mainScrollView setContentOffset:CGPointMake(_mainScrollView.width * _selectedSegmentIndex, 0)
                                     animated:NO];
    }
}

#pragma mark -- Action
-(void)onClick:(UIButton *)btn
{
    NSInteger index = btn.tag - gHeaderBtnStartTag;
    self.selectedSegmentIndex = index;
}

- (void)edgeRightAction:(UIScreenEdgePanGestureRecognizer *)ges
{
    if (_enableRight)
    {
        _enableRight = NO;
        
        self.selectedSegmentIndex = 0;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _enableLeft = YES;
        });
    }
}

- (void)edgeLeftAction:(UIScreenEdgePanGestureRecognizer *)ges
{
    if (_enableLeft)
    {
        _enableLeft = NO;
        
        self.selectedSegmentIndex = 1;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _enableRight = YES;
        });
    }
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _mainScrollView) {
        NSInteger currentIndex = scrollView.contentOffset.x / self.width;
        self.selectedSegmentIndex = currentIndex;
    }
}

#pragma mark - Setter
- (void)setShowSeparateLine:(BOOL)showSeparateLine
{
    _separateLine.hidden = !showSeparateLine;
}

- (void)setHeaderBackColor:(UIColor *)headerBackColor
{
    if (headerBackColor) {
        _headerView.backgroundColor = headerBackColor;
    }
}

- (void)setEnableEdgePan:(BOOL)enableEdgePan
{
    if (_enableEdgePan != enableEdgePan)
    {
        if (enableEdgePan)
        {
            
            [_mainScrollView addGestureRecognizer:self.leftEdgePan];
            [_mainScrollView addGestureRecognizer:self.rightEdgePan];
            _enableLeft = YES; //允许左滑
        }
        else
        {
            [_mainScrollView removeGestureRecognizer:self.leftEdgePan];
            [_mainScrollView removeGestureRecognizer:self.rightEdgePan];
        }
        
        _enableEdgePan = enableEdgePan;
    }
}

#pragma mark -- 属性
- (UIView *)headerView
{
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor whiteColor];
    }
    return _headerView;
}

- (UIScrollView *)mainScrollView
{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.bounces = NO;
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.delegate = self;
        _mainScrollView.scrollEnabled = NO;
        _mainScrollView.canCancelContentTouches = NO;
        _mainScrollView.delaysContentTouches  = NO;
    }
    return _mainScrollView;
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorFromRGB(0x238efa);
    }
    return _lineView;
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    if (_selectedSegmentIndex != selectedSegmentIndex)
    {
        UIButton *btn = (UIButton *)[self.headerView viewWithTag:(_selectedSegmentIndex + gHeaderBtnStartTag)];
        btn.selected = NO;
        

        UIButton *currentSelectBtn = (UIButton *)[self.headerView viewWithTag:(selectedSegmentIndex + gHeaderBtnStartTag)];
        currentSelectBtn.selected = YES;
        
        if (_isTitleHighlighted) {
            [btn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            [currentSelectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        CGRect rect = self.lineView.frame;
        rect.origin.x = selectedSegmentIndex * btn.width + gLineEdgeOffset;
        [UIView animateWithDuration:0.3 animations:^{
            self.lineView.frame = rect;
        }];
    
        //页面切换收键盘。（这里其实不应该这样写，应该代理出去解耦合，懒得改了）
        [self endEditing:YES];
        
        [self.mainScrollView setContentOffset:CGPointMake(_mainScrollView.width * selectedSegmentIndex, 0)
                                     animated:YES];
        
        _selectedSegmentIndex = selectedSegmentIndex;
    }
}

- (UIView *)separateLine
{
    if (!_separateLine) {
        _separateLine = [UIView new];
        _separateLine.backgroundColor = UIColorFromRGB(0xc8c7cc);
        _separateLine.hidden = YES;
    }
    return _separateLine;
}

- (UIScreenEdgePanGestureRecognizer *)leftEdgePan
{
    if (!_leftEdgePan) {
        _leftEdgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(edgeRightAction:)];
        _leftEdgePan.edges = UIRectEdgeLeft;
    }
    return _leftEdgePan;
}

- (UIScreenEdgePanGestureRecognizer *)rightEdgePan
{
    if (!_rightEdgePan) {
        _rightEdgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(edgeLeftAction:)];
        _rightEdgePan.edges = UIRectEdgeRight;
    }
    return _rightEdgePan;
}

@end
