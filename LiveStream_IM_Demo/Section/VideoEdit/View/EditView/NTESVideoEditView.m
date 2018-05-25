//
//  NTESVideoEditView.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/5/27.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESVideoEditView.h"
#import "NTESSegmentControl.h"
#import "NTESArrangeView.h"
#import "NTESTrimView.h"
#import "NTESTextureView.h"
#import "NTESAudioView.h"
#import "NTESTextAttachmentView.h"
#import "NTESTranscodingDataCenter.h"

@interface NTESVideoEditView () <NTESArrangeViewDelegate, NTESTrimViewDelegate, NTESTextureViewDelegate, NTESAudioViewDelegate, NTESTextAttachmentViewDelegate>

@property(nonatomic, strong) NTESSegmentControl *segCtrl;

@property(nonatomic, strong) NTESTransConfigEntity *transConfig;

@property(nonatomic, strong) NTESArrangeView *arrangeView;

@property(nonatomic, strong) NTESTrimView *trimView;

@property(nonatomic, strong) NTESTextureView *textureView;

@property(nonatomic, strong) NTESAudioView *audioView;

@property(nonatomic, strong) NTESTextAttachmentView *textAttachmentView;

@end

@implementation NTESVideoEditView

- (instancetype)initWithFrame:(CGRect)frame filePaths:(NSArray<NSString *> *)filePaths {
    if (self = [super initWithFrame:frame]) {
        self.filePaths = filePaths;
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.segCtrl.bounds), CGRectGetHeight(self.segCtrl.bounds));
    self.arrangeView = [[NTESArrangeView alloc] initWithFrame:frame];
    self.trimView = [[NTESTrimView alloc] initWithFrame:frame videoPaths:self.filePaths];
    self.textureView = [[NTESTextureView alloc] initWithFrame:frame filePaths:self.filePaths];
    self.audioView = [[NTESAudioView alloc] initWithFrame:frame];
    self.textAttachmentView = [[NTESTextAttachmentView alloc] initWithFrame:frame];
    
    NSArray *arrView = @[_arrangeView, _trimView, _textAttachmentView, _textureView, _audioView];
    NSArray *arrName = @[@"调整", @"分段", @"文字", @"贴图", @"伴音"];
    self.arrangeView.delegate = self;
    self.trimView.delegate = self;
    self.textureView.delegate = self;
    self.audioView.delegate = self;
    self.textAttachmentView.delegate = self;
    
    [self configSubViews];
    
    self.segCtrl = ({
        NTESSegmentControl *ctrl = [[NTESSegmentControl alloc] initWithItems:arrView enableEdgePan:YES andHighlightTitle:YES];
        ctrl.frame = self.bounds;
        ctrl.selectedSegmentIndex = 0;
        ctrl.headerBackColor = [UIColor colorWithWhite:0 alpha:0.9];
        ctrl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
        ctrl.lineView.hidden = YES;
        ctrl.showSeparateLine = YES;
        ctrl.isSeparateLineFull = NO;
        ctrl.separateLine.backgroundColor = [UIColor whiteColor];
        ctrl;
    });
    
    [arrName enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.segCtrl setTitle:str forSegmentAtIndex:idx];
    }];

    [self addSubview:self.segCtrl];
    
}


- (void)configSubViews {
    //进度范围
    self.arrangeView.bright_slider.minValue = -1.0;
    self.arrangeView.contr_slider.minValue = 0.0;
    self.arrangeView.saturation_slider.minValue = 0.0;
    self.arrangeView.sharp_slider.minValue = -4.0;
    self.arrangeView.temp_slider.minValue = 0;
    
    self.arrangeView.bright_slider.maxValue = 1.0;
    self.arrangeView.contr_slider.maxValue = 4.0;
    self.arrangeView.saturation_slider.maxValue = 2.0;
    self.arrangeView.sharp_slider.maxValue = 4.0;
    self.arrangeView.temp_slider.maxValue = 360;
    
    CGFloat brightness = [NTESTranscodingDataCenter sharedInstance].transConfig.brightness;
    self.arrangeView.bright_slider.value = brightness;
    self.arrangeView.bright_slider.default_value = brightness;
    
    CGFloat contrast = [NTESTranscodingDataCenter sharedInstance].transConfig.contrast;
    self.arrangeView.contr_slider.value = contrast;
    self.arrangeView.contr_slider.default_value = contrast;
    
    CGFloat sat = [NTESTranscodingDataCenter sharedInstance].transConfig.saturation;
    self.arrangeView.saturation_slider.value = sat;
    self.arrangeView.saturation_slider.default_value = sat;
    
    CGFloat sharp = [NTESTranscodingDataCenter sharedInstance].transConfig.sharpness;
    self.arrangeView.sharp_slider.value = sharp;
    self.arrangeView.sharp_slider.default_value = sharp;
    
    CGFloat temp = [NTESTranscodingDataCenter sharedInstance].transConfig.temperature;
    self.arrangeView.temp_slider.value = temp;
    self.arrangeView.temp_slider.default_value = temp;
}

#pragma mark - delegate
//arrangeView
- (void)ArrangeView:(NTESArrangeView *)arrangeView brightValueChanged:(CGFloat)brightness {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:brightnessValue:)]) {
        [self.delegate editView:self brightnessValue:brightness];
    }
}

- (void)ArrangeView:(NTESArrangeView *)arrangeView contrastValueChanged:(CGFloat)contrast {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:contrastValue:)]) {
        [self.delegate editView:self contrastValue:contrast];
    }
}

- (void)ArrangeView:(NTESArrangeView *)arrangeView saturateValueChanged:(CGFloat)saturation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:saturationValue:)]) {
        [self.delegate editView:self saturationValue:saturation];
    }
}

- (void)ArrangeView:(NTESArrangeView *)arrangeView tempValueChanged:(CGFloat)temperature {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:temperatureValue:)]) {
        [self.delegate editView:self temperatureValue:temperature];
    }
}

- (void)ArrangeView:(NTESArrangeView *)arrangeView sharpValueChanged:(CGFloat)sharpness {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:sharpnessValue:)]) {
        [self.delegate editView:self sharpnessValue:sharpness];
    }
}

//trimView
- (void)trimView:(NTESTrimView *)trimView audio:(NSUInteger)audioValue {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:audioValue:)]) {
        [self.delegate editView:self audioValue:audioValue];
    }
}

- (void)trimView:(NTESTrimView *)trimView fadeInOutPosition:(BOOL)hasFaded {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:hasFade:)]) {
        [self.delegate editView:self hasFade:hasFaded];
    }
}

- (void)trimView:(NTESTrimView *)trimView switchForward:(NSInteger)switchPosition {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:switchForward:)]) {
        [self.delegate editView:self switchForward:switchPosition];
    }

}

- (void)trimView:(NTESTrimView *)trimView switchBackward:(NSInteger)switchPosition {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:switchBackward:)]) {
        [self.delegate editView:self switchBackward:switchPosition];
    }
}

//textureView
- (void)textureView:(NTESTextureView *)textureView selectTexture:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:selectedTexture:)]) {
        [self.delegate editView:self selectedTexture:index];
    }
}

- (void)textureView:(NTESTextureView *)textureView showTimeFrom:(CGFloat)startTime toTime:(CGFloat)endTime {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:showTextureFromTime:toTime:)]) {
        [self.delegate editView:self showTextureFromTime:startTime toTime:endTime];
    }
}


//audioView
- (void)audioView:(NTESAudioView *)audioView selectAudio:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:selectedAudio:)]) {
        [self.delegate editView:self selectedAudio:index];
    }
}
//audioView
- (void)audioView:(NTESAudioView *)audioView mainAudioVolume:(CGFloat)volume {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:mainVolume:)]) {
        [self.delegate editView:self mainVolume:volume];
    }
}

//textAttachmentView
- (void)textAttachment:(NTESTextAttachmentView *)textAttachmentView selectTextColor:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:selectTextColor:)]) {
        [self.delegate editView:self selectTextColor:index];
    }
}

- (void)textAttachment:(NTESTextAttachmentView *)textAttachmentView selectTextStyle:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editView:selectText:)]) {
        [self.delegate editView:self selectText:index];
    }
}


@end
