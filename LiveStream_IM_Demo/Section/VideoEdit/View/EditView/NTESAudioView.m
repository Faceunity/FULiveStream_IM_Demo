//
//  NTESAudioView.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/5/27.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAudioView.h"
#import "NTESTemplatePickerView.h"
#import "NTESSlider.h"

@interface NTESAudioView () <NTESTemplatePickerViewDelegate>

@property(nonatomic, strong) NTESTemplatePickerView *pickerView;

@property(nonatomic, strong) NTESSlider *audioSlider;

@property(nonatomic, strong) UILabel *accompanyAudioLabel;

@property(nonatomic, strong) UILabel *originAudioLabel;



@end

@implementation NTESAudioView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    self.pickerView = ({
        NTESTemplatePickerView *pickerView = [[NTESTemplatePickerView alloc] initWithFrame:CGRectMake(30 * UISreenWidthScale, 22.5, UIScreenWidth - 60 * UISreenWidthScale, 80) templateCount:4 templateType:NTESTemplateTypeAudio];

        pickerView.delegate = self;
        pickerView;
    });
    [self addSubview:self.pickerView];
    
    self.originAudioLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30 * UISreenWidthScale, 141.5 * UISreenHeightScale, 28, 20)];
        label.font = [UIFont systemFontOfSize:13.f];
        label.textColor = [UIColor whiteColor];
        label.text = @"原声";
        label;
    });
    [self addSubview:self.originAudioLabel];
    
    self.audioSlider = ({
        NTESSlider *slider = [[NTESSlider alloc] initWithFrame:CGRectMake(77.5 * UISreenWidthScale, 141.5 * UISreenHeightScale, 220 * UISreenWidthScale, 30)];
        slider.centerY = self.originAudioLabel.centerY;
        //FIX ME:修改slider值，现在随意
        slider.thumbImage = [UIImage imageNamed:@"beauty_slider_thumb"];
        slider.thumbSize = CGSizeMake(18, 18);
        slider.trackColor = [UIColor colorWithWhite:1 alpha:0.45];
        slider.trackWidth = 2;
        slider.valueStyle = NTESValueStyleSignal;
        slider.minValue = 0;
        slider.maxValue = 1;
        slider.value = 0.5;
        slider.default_value = 0.5;
        WEAK_SELF(weakSelf);
        slider.valueChangedBlock = ^(CGFloat value) {
            STRONG_SELF(strongSelf);
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(audioView:mainAudioVolume:)]) {
                [strongSelf.delegate audioView:weakSelf mainAudioVolume:value];
            }
        };
        slider;
    });

    [self addSubview:self.audioSlider];
    
    self.accompanyAudioLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(315 * UISreenWidthScale, 141.5 * UISreenHeightScale, 28, 20)];
        label.font = [UIFont systemFontOfSize:13.f];
        label.textColor = [UIColor whiteColor];
        label.text = @"伴音";
        label;
    });
    
    [self addSubview:self.accompanyAudioLabel];
}

#pragma mark - delegate

- (void)templatePickerView:(NTESTemplatePickerView *)pickerView didSelectTemplate:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioView:selectAudio:)]) {
        [self.delegate audioView:self selectAudio:index];
    }
}

@end
