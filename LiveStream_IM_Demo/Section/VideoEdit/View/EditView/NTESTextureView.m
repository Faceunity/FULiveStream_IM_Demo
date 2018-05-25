  //
//  NTESTextureView.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/5/27.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESTextureView.h"
#import "NTESTemplatePickerView.h"
#import "NTESCustomSlider.h"

@interface NTESTextureView () <NTESTemplatePickerViewDelegate>

@property(nonatomic, strong) NTESTemplatePickerView *pickerView;

@property(nonatomic, strong) NTESCustomSlider *slider;

@property(nonatomic, strong) UILabel *showLabel;

@property(nonatomic, strong) UILabel *timeLabel;

@property(nonatomic, strong) UILabel *leftLabel;

@property(nonatomic, strong) UILabel *rightLabel;

@property(nonatomic, assign) CGFloat duration;

@end

@implementation NTESTextureView

- (instancetype)initWithFrame:(CGRect)frame filePaths:(NSArray<NSString *> *)filePaths {
    self = [super initWithFrame:frame];
    if (self) {
        self.filePaths = filePaths;
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    //总时长
    _duration = 0;
    for (NSString *filePath in self.filePaths) {
        NSURL *videoURL = [NSURL fileURLWithPath:filePath];
        AVAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        _duration += CMTimeGetSeconds([asset duration]);
    }
    
    self.pickerView = ({
        NTESTemplatePickerView *pickerView = [[NTESTemplatePickerView alloc] initWithFrame:CGRectMake(30 * UISreenWidthScale, 22.5 * UISreenHeightScale, UIScreenWidth - 60 * UISreenWidthScale, 80) templateCount:4 templateType:NTESTemplateTypeTexture];
        pickerView.delegate = self;
        pickerView;
    });
    
    self.showLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((162 + 20) * UISreenWidthScale, 100 * UISreenHeightScale, 80 * UISreenWidthScale, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 1;
        label.textColor = [UIColor grayColor];
        label;
    });
    
    self.timeLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30 * UISreenWidthScale, 140 * UISreenHeightScale, 56 * UISreenWidthScale, 20)];
        label.numberOfLines = 1;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:13];
        label.adjustsFontSizeToFitWidth = YES;
        label.text = @"显示时间";
        label;
    });
    
    self.slider = ({
        NTESCustomSlider *slider = [[NTESCustomSlider alloc] initWithFrame:CGRectMake(162 * UISreenWidthScale, 138.5 * UISreenHeightScale, 120 * UISreenWidthScale, 20 * UISreenHeightScale)];
        slider.maximumValue = _duration;
        slider.lowerValue = 0.;
        slider.upperValue = _duration;
        slider;
    });
    //起始时长
    self.leftLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(115 * UISreenWidthScale, 140 * UISreenHeightScale, 28, 20)];
        label.text = @"0.0";
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor lightGrayColor];
        label;
    });
    
    self.rightLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(310 * UISreenWidthScale, 140 * UISreenHeightScale, 28, 20)];
        label.text = [NSString stringWithFormat:@"%.1lf", _duration];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor lightGrayColor];
        label;
    });
    
    [self.slider addTarget:self action:@selector(rangeValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [@[self.pickerView,
       self.timeLabel,
       self.showLabel,
       self.slider,
       self.leftLabel,
       self.rightLabel
       ] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
           [self addSubview:view];
       }];
}

#pragma mark - delegate
- (void)templatePickerView:(NTESTemplatePickerView *)pickerView didSelectTemplate:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textureView:selectTexture:)]) {
        [self.delegate textureView:self selectTexture:index];
    }
}

- (void)rangeValueChanged:(NTESCustomSlider *)slider {
    [self updateRangeText];
    if (self.delegate && [self.delegate respondsToSelector:@selector(textureView:showTimeFrom:toTime:)]) {
        [self.delegate textureView:self showTimeFrom:self.slider.lowerValue toTime:self.slider.upperValue];
    }
}

- (void)updateRangeText {

    self.showLabel.text = [NSString stringWithFormat:@"%0.1f - %0.1f", self.slider.lowerValue, self.slider.upperValue];
}

@end
