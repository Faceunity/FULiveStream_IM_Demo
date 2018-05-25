//
//  NTESArrangeView.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/5/27.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESArrangeView.h"

@interface NTESArrangeView ()


@property(nonatomic, strong) UILabel *bri_label;
@property(nonatomic, strong) UILabel *contr_label;
@property(nonatomic, strong) UILabel *sat_label;
@property(nonatomic, strong) UILabel *temp_label;
@property(nonatomic, strong) UILabel *sharp_label;


@end

@implementation NTESArrangeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupSubViews {
    //亮度Slider
    self.bright_slider = ({
        NTESSlider *slider = [[NTESSlider alloc] initWithFrame:CGRectMake(UIScreenWidth/10 - 15, 35, 30, 100)];
        //FIX ME:修改slider值，现在随意
        slider.thumbImage = [UIImage imageNamed:@"beauty_slider_thumb"];
        slider.thumbSize = CGSizeMake(12, 12);
        slider.trackColor = [UIColor colorWithWhite:1 alpha:0.45];
        slider.trackWidth = 2;
        slider.valueStyle = NTESValueStyleInteger;
        WEAK_SELF(weakSelf);
        slider.valueChangedBlock = ^(CGFloat value) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ArrangeView:brightValueChanged:)]) {
                [weakSelf.delegate ArrangeView:weakSelf brightValueChanged:value];
                weakSelf.bri_label.textColor = UIColorFromRGB(0x2084ff);
            }
        };
        slider.valueEndChangeBlock = ^(CGFloat value) {
            weakSelf.bri_label.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        };
        slider;
    });
    //对比度Slider
    self.contr_slider = ({
        NTESSlider *slider = [[NTESSlider alloc] initWithFrame:CGRectMake(UIScreenWidth*3/10 - 15, 35, 30, 100)];
        slider.thumbImage = [UIImage imageNamed:@"beauty_slider_thumb"];
        slider.thumbSize = CGSizeMake(12, 12);
        slider.trackWidth = 2;
        slider.trackColor = [UIColor colorWithWhite:1 alpha:0.45];
        slider.valueStyle = NTESValueStyleInteger;
        WEAK_SELF(weakSelf);
        slider.valueChangedBlock = ^(CGFloat value) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ArrangeView:contrastValueChanged:)]) {
                [weakSelf.delegate ArrangeView:weakSelf contrastValueChanged:value];
                weakSelf.contr_label.textColor = UIColorFromRGB(0x2084ff);
            }
        };
        slider.valueEndChangeBlock = ^(CGFloat value) {
            weakSelf.contr_label.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        };
        slider;
    });
    //饱和度Slider
    self.saturation_slider = ({
        NTESSlider *slider = [[NTESSlider alloc] initWithFrame:CGRectMake(UIScreenWidth*5/10 - 15, 35, 30, 100)];
        slider.thumbImage = [UIImage imageNamed:@"beauty_slider_thumb"];
        slider.trackWidth = 2;
        slider.thumbSize = CGSizeMake(12, 12);
        slider.trackColor = [UIColor colorWithWhite:1 alpha:0.45];
        slider.valueStyle = NTESValueStyleInteger;
        WEAK_SELF(weakSelf);
        slider.valueChangedBlock = ^(CGFloat value) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ArrangeView:saturateValueChanged:)]) {
                [weakSelf.delegate ArrangeView:weakSelf saturateValueChanged:value];
                weakSelf.sat_label.textColor = UIColorFromRGB(0x2084ff);
            }
        };
        slider.valueEndChangeBlock = ^(CGFloat value) {
            weakSelf.sat_label.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        };
        slider;
    });
    //色温Slider
    self.temp_slider = ({
        NTESSlider *slider = [[NTESSlider alloc] initWithFrame:CGRectMake(UIScreenWidth*7/10 - 15, 35, 30, 100)];
        slider.thumbImage = [UIImage imageNamed:@"beauty_slider_thumb"];
        slider.trackWidth = 2;
        slider.thumbSize = CGSizeMake(12, 12);
        slider.trackColor = [UIColor colorWithWhite:1 alpha:0.45];
        slider.valueStyle = NTESValueStyleInteger;
        WEAK_SELF(weakSelf);
        slider.valueChangedBlock = ^(CGFloat value) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ArrangeView:tempValueChanged:)]) {
                [weakSelf.delegate ArrangeView:weakSelf tempValueChanged:value];
                weakSelf.temp_label.textColor = UIColorFromRGB(0x2084ff);
            }
        };
        slider.valueEndChangeBlock = ^(CGFloat value) {
            weakSelf.temp_label.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        };
        slider;
    });
    //锐度Slider
    self.sharp_slider = ({
        NTESSlider *slider = [[NTESSlider alloc] initWithFrame:CGRectMake(UIScreenWidth*9/10 - 15, 35, 30, 100)];
        slider.thumbImage = [UIImage imageNamed:@"beauty_slider_thumb"];
        slider.trackWidth = 2;
        slider.thumbSize = CGSizeMake(12, 12);
        slider.trackColor = [UIColor colorWithWhite:1 alpha:0.45];
        slider.valueStyle = NTESValueStyleInteger;
        WEAK_SELF(weakSelf);
        slider.valueChangedBlock = ^(CGFloat value) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ArrangeView:sharpValueChanged:)]) {
                [weakSelf.delegate ArrangeView:weakSelf sharpValueChanged:value];
                weakSelf.sharp_label.textColor = UIColorFromRGB(0x2084ff);
            }
        };
        slider.valueEndChangeBlock = ^(CGFloat value) {
            weakSelf.sharp_label.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        };
        slider;
    });
    
    [@[self.bright_slider, self.contr_slider,
       self.saturation_slider, self.temp_slider,
       self.sharp_slider] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
           [self addSubview:view];
       }];
    
    self.bri_label = ({
        UILabel *label = [UILabel new];
        label.text = @"亮度";
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    
    self.contr_label = ({
        UILabel *label = [UILabel new];
        label.text = @"对比度";
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });

    self.sat_label = ({
        UILabel *label = [UILabel new];
        label.text = @"饱和度";
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    
    self.temp_label = ({
        UILabel *label = [UILabel new];
        label.text = @"色温";
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    
    self.sharp_label = ({
        UILabel *label = [UILabel new];
        label.text = @"锐度";
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    
    [@[self.bri_label, self.contr_label,
       self.sat_label, self.temp_label,
       self.sharp_label] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
           [self addSubview:view];
       }];

}

- (void)setupConstraints {
    NSNumber *labelWidth = [NSNumber numberWithFloat: UIScreenWidth / 5 ];
    
    [self.bri_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bright_slider.mas_bottom).offset(10);
        make.width.equalTo(labelWidth);
        make.height.equalTo(@20);
        make.left.equalTo(self.mas_left);
    }];
    
    [self.contr_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bri_label.mas_top);
        make.width.equalTo(self.bri_label.mas_width);
        make.height.equalTo(self.bri_label.mas_height);
        make.left.equalTo(self.bri_label.mas_right);
        
    }];
    
    [self.sat_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bri_label.mas_top);
        make.width.equalTo(self.bri_label.mas_width);
        make.height.equalTo(self.bri_label.mas_height);

        make.left.equalTo(self.contr_label.mas_right);
    }];
    
    [self.temp_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bri_label.mas_top);
        make.width.equalTo(self.bri_label.mas_width);
        make.height.equalTo(self.bri_label.mas_height);
        make.left.equalTo(self.sat_label.mas_right);
    }];
    
    [self.sharp_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bri_label.mas_top);
        make.width.equalTo(self.bri_label.mas_width);
        make.height.equalTo(self.bri_label.mas_height);
        make.left.equalTo(self.temp_label.mas_right);
    }];
    
}

@end
