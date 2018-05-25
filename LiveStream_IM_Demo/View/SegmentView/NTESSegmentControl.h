//
//  NTESSegmentControl.h
//  NEUIDemo
//
//  Created by Netease on 17/1/3.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTESSegmentControl : UIControl

@property(nonatomic, assign) NSInteger selectedSegmentIndex;

@property (nonatomic, strong) UIColor *headerBackColor; //头部背景颜色

@property (nonatomic, assign) BOOL showSeparateLine; //是否显示分割线

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIView *separateLine;

@property(nonatomic, assign) BOOL isTitleHighlighted;

@property(nonatomic, assign) BOOL isSeparateLineFull;

- (instancetype)initWithItems:(NSArray<UIView *> *)items enableEdgePan:(BOOL)enableEdgePan andHighlightTitle:(BOOL)highlighted;

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;

@end
