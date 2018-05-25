//
//  NTESPresentEmptyView.m
//  NEUIDemo
//
//  Created by Netease on 17/1/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESPresentEmptyView.h"

@interface NTESPresentEmptyView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLab;

@end

@implementation NTESPresentEmptyView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    [self addSubview:self.imageView];
    [self addSubview:self.textLab];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.imageView sizeToFit];
    self.imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2 - 10.0);
    
    [self.textLab sizeToFit];
    self.textLab.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.textLab.top = self.imageView.bottom + 10.0;
}

#pragma mark - Public
+ (instancetype)emptyViewWithInfo:(NSString *)info
{
    NTESPresentEmptyView *empty = [[NTESPresentEmptyView alloc] init];
    empty.info = info;
    return empty;
}

+ (instancetype)emptyViewWithInfo:(NSString *)info bkImageName:(NSString *)imageName
{
    NTESPresentEmptyView *empty = [[NTESPresentEmptyView alloc] init];
    empty.info = info;
    empty.bkImageName = imageName;
    return empty;
}


#pragma mark - Getter/Setter
- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_noliwu"]];
    }
    return _imageView;
}

- (UILabel *)textLab
{
    if (!_textLab)
    {
        _textLab = [[UILabel alloc] init];
        _textLab.font = [UIFont systemFontOfSize:13.f];
        _textLab.textColor = UIColorFromRGB(0xffffff);
        _textLab.text = _info;
    }
    return _textLab;
}

- (void)setInfo:(NSString *)info
{
    info = (info ?: @"");
    
    if (![_info isEqualToString:info])
    {
        self.textLab.text = info;
        
        [self setNeedsLayout];
        
        _info = info;
    }
}

- (void)setBkImageName:(NSString *)bkImageName
{
    bkImageName = (bkImageName ?: @"");
    
    if (![bkImageName isEqualToString:_bkImageName])
    {
        self.imageView.image = [UIImage imageNamed:bkImageName];
        
        _bkImageName = bkImageName;
    }
}

@end
