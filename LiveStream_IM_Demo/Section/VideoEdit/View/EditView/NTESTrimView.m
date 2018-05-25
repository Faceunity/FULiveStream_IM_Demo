//
//  NTESTrimView.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/5/27.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESTrimView.h"
#import "NTESBeautyConfigView.h"

#define trimSpacing 30 * UISreenWidthScale

@interface NTESTrimView ()

@property(nonatomic, assign) NSUInteger trimNumber;

@property(nonatomic, strong) UIButton *btn0;

@property(nonatomic, strong) UIButton *btn1;

@property(nonatomic, strong) UIButton *btn2;

@property(nonatomic, strong) UIButton *btn3;

@property(nonatomic, strong) UIButton *imgBtn1;

@property(nonatomic, strong) UIButton *imgBtn2;

@property(nonatomic, strong) UIButton *imgBtn3;

@property(nonatomic, assign) NSInteger selected_btnTag;

@property(nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@property(nonatomic, strong) UILabel *sortLabel;

@property(nonatomic, strong) UIButton *moveForwardBtn;

@property(nonatomic, strong) UIButton *moveBackwardBtn;

@property(nonatomic, strong) UILabel *transLabel;

@property(nonatomic, strong) UIButton *noneBtn;

@property(nonatomic, strong) UIButton *transBtn;

@property(nonatomic, assign) NSInteger selectedFadePos;

@property(nonatomic, assign) BOOL isFadeUI;

@property(nonatomic, strong) NTESBeautyConfigView *audioConfig;

@property(nonatomic, strong) NSMutableArray *sortArray;

@property(nonatomic, assign) CGRect pos1;

@property(nonatomic, assign) CGRect pos2;

@property(nonatomic, assign) CGRect pos3;

@end

@implementation NTESTrimView

- (instancetype)initWithFrame:(CGRect)frame videoPaths:(NSArray<NSString *> *)videoPaths {
    if (self = [super initWithFrame:frame]) {
        self.videoPaths = videoPaths;
        self.trimNumber = videoPaths.count;
        [self setupSubViews];
        [self setupConstraints];
        [self addVideoFrame];
    }
    return self;
}

- (void)setupSubViews {
    self.sortArray = @[].mutableCopy;
    self.isFadeUI = NO;
    
    self.btn0 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 13, 13);
        [btn setBackgroundImage:[UIImage imageNamed:@"白点"] forState:UIControlStateNormal];
        btn.tag = 0;
        btn.enabled = YES;
        [btn addTarget:self action:@selector(btn0TapAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.btn1 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 13, 13);
        [btn setBackgroundImage:[UIImage imageNamed:@"白点"] forState:UIControlStateNormal];
        btn.tag = 1;
        btn.enabled = YES;
        [btn addTarget:self action:@selector(btn1TapAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.btn2 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 13, 13);
        [btn setBackgroundImage:[UIImage imageNamed:@"白点"] forState:UIControlStateNormal];
        
        btn.tag = 2;
        btn.enabled = YES;
        [btn addTarget:self action:@selector(btn2TapAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.btn3 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 13, 13);
        [btn setBackgroundImage:[UIImage imageNamed:@"白点"] forState:UIControlStateNormal];
        btn.tag = 3;
        btn.enabled = YES;
        [btn addTarget:self action:@selector(btn3TapAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.imgBtn1 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 10;
        btn.enabled = NO;
        [btn setTitle:@"1" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(imgBtn1Action:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.imgBtn2 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 11;
        btn.enabled = NO;
        [btn setTitle:@"2" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(imgBtn2Action:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.imgBtn3 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 12;
        btn.enabled = NO;
        [btn setTitle:@"3" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(imgBtn3Action:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    switch (self.trimNumber) {
        case 1:
        {
            _btn2.hidden = YES;
            _btn3.hidden = YES;
        }
            break;
        case 2:
        {
            _btn3.hidden = YES;
        }
            break;
        default:
            break;
    }
    
    self.sortLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30 * UISreenWidthScale, 90 * UISreenHeightScale, 28, 20)];
        label.text = @"排序";
        label.font = [UIFont systemFontOfSize:13.f];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 1;
        label;
    });
    
    self.moveForwardBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(261 * UISreenWidthScale, 90 * UISreenWidthScale, 28, 20);
        btn.contentHorizontalAlignment = NSTextAlignmentCenter;
        [btn setTitle:@"前移" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(moveForwardBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.enabled = NO;
        btn;
    });
    
    self.moveBackwardBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(317 * UISreenWidthScale, 90 * UISreenHeightScale, 28, 20);
        btn.contentHorizontalAlignment = NSTextAlignmentCenter;
        [btn setTitle:@"后移" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(moveBackwardBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.enabled = NO;
        btn;
    });
    
    self.audioConfig = ({
        NTESBeautyConfigView *configView = [[NTESBeautyConfigView alloc] initWithFrame:CGRectMake(12 * UISreenWidthScale, 135 * UISreenHeightScale, 335 * UISreenWidthScale, 40)];
        configView.titleLab.text = @"原声大小";
        configView.titleLab.textColor = [UIColor whiteColor];
        configView.titleLab.font = [UIFont systemFontOfSize:13.f];
        configView.maxValue = 100;
        configView.minValue = 0;
        configView.curValue = 50;
        configView.defalutValue = 50;
        configView.alpha = 1;
        configView;
    });
    
    WEAK_SELF(weakSelf);
    self.audioConfig.valueChangedBlock = ^(CGFloat value) {
        STRONG_SELF(strongSelf);
        if (strongSelf.delegate && [self.delegate respondsToSelector:@selector(trimView:audio:)]) {
            [strongSelf.delegate trimView:strongSelf audio:value];
        }
    };
    
    self.transLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30 * UISreenWidthScale, 96.5 * UISreenHeightScale, 28, 20)];
        label.text = @"过渡";
        label.font = [UIFont systemFontOfSize:13.f];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 1;
        label.hidden = YES;
        label;
    });
    
    self.noneBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(246 * UISreenWidthScale, 96.5 * UISreenHeightScale, 14, 20);
        btn.contentHorizontalAlignment = NSTextAlignmentCenter;
        [btn setTitle:@"无" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.f];

        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

        [btn addTarget:self action:@selector(noneBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.enabled = NO;
        btn.hidden = YES;
        btn;

    });
    
    self.transBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(288 * UISreenHeightScale, 96.5 * UISreenWidthScale, 56, 20);
        btn.contentHorizontalAlignment = NSTextAlignmentCenter;
        [btn setTitle:@"淡入淡出" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(transBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.hidden = YES;
        btn.enabled = YES;
        btn;
    });
    
    [@[self.imgBtn1,
       self.imgBtn2,
       self.imgBtn3] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
           [self.sortArray insertObject:btn atIndex:idx];
           if (idx == self.trimNumber - 1) {
               *stop = YES;
               return;
           }
       }];
    
    [@[self.btn0, self.btn1, self.btn2, self.btn3,
       self.imgBtn1, self.imgBtn2, self.imgBtn3,
       self.sortLabel, self.audioConfig, self.transLabel,
       self.noneBtn, self.transLabel, self.moveForwardBtn, self.moveBackwardBtn, self.transBtn]\
     enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
           [self addSubview:view];
       }];

}

- (void)setupConstraints {
    //set up subviews constraints
    CGFloat sectionWidth = 60 * UISreenWidthScale;
    CGFloat trimWidth = (UIScreenWidth - sectionWidth * (self.trimNumber + 1)) / self.trimNumber;
    self.pos1 = CGRectMake(sectionWidth, trimSpacing, trimWidth, trimSpacing);
    switch (self.trimNumber) {
        case 1:
        {
            self.imgBtn1.frame = self.pos1;
        }
            break;
        case 2:
        {
            self.pos2 = CGRectMake(sectionWidth * 2 + trimWidth, trimSpacing, trimWidth, trimSpacing);
            self.imgBtn1.frame = self.pos1;
            self.imgBtn2.frame = self.pos2;
        }
            break;
        case 3:
        {
            self.pos2 = CGRectMake(sectionWidth * 2 + trimWidth, trimSpacing, trimWidth, trimSpacing);
            self.pos3 = CGRectMake(sectionWidth * 3 + trimWidth * 2, trimSpacing, trimWidth, trimSpacing);
            self.imgBtn1.frame = self.pos1;
            self.imgBtn2.frame = self.pos2;
            self.imgBtn3.frame = self.pos3;
        }
            break;
        default:
            break;
    }
    
    
    [self.btn0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.imgBtn1.mas_centerY);
        make.width.height.equalTo(@13);
        make.centerX.equalTo(self.mas_left).offset(sectionWidth / 2);
    }];
    
    [self.btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.btn0.mas_centerY);
        make.width.height.equalTo(@13);
        make.centerX.equalTo(self.imgBtn1.mas_right).offset(sectionWidth / 2);
    }];
    
    [self.btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.imgBtn1.mas_centerY);
        make.width.height.equalTo(@13);
        make.centerX.equalTo(self.imgBtn2.mas_right).offset(sectionWidth / 2);
    }];
    
    [self.btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.imgBtn1.mas_centerY);
        make.width.height.equalTo(@13);
        make.left.equalTo(self.imgBtn3.mas_right).offset(sectionWidth / 2);
    }];
}

#pragma mark - action

- (void)btn0TapAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        //FIX ME:这里是一个按钮选择，则全局选择
        [self selectAllBtns];
    }else {
        [self deselectAllBtns];
    }
    //切换到过渡视图
    if (!self.isFadeUI) {
        [self switchUItoFade:YES];
    }
    self.selectedFadePos = sender.tag;
}

- (void)btn1TapAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self selectAllBtns];
    }else {
        [self deselectAllBtns];
    }
    if (!self.isFadeUI) {
        [self switchUItoFade:YES];
    }
    self.selectedFadePos = sender.tag;
}

- (void)btn2TapAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self selectAllBtns];
    }else {
        [self deselectAllBtns];
    }

    if (!self.isFadeUI) {
        [self switchUItoFade:YES];
    }
    self.selectedFadePos = sender.tag;

}

- (void)btn3TapAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self selectAllBtns];
    }else {
        [self deselectAllBtns];
    }

    if (!self.isFadeUI) {
        [self switchUItoFade:YES];
    }
    self.selectedFadePos = sender.tag;
}

- (void)imgBtn1Action:(UIButton *)sender {
    if (self.isFadeUI) {
        [self switchUItoFade:NO];
    }
    self.selected_btnTag = sender.tag;
    [self changeSelectedBtnUI:sender];
    
}

- (void)imgBtn2Action:(UIButton *)sender {
    if (self.isFadeUI) {
        [self switchUItoFade:NO];
    }
    self.selected_btnTag = sender.tag;
    [self changeSelectedBtnUI:sender];
}

- (void)imgBtn3Action:(UIButton *)sender {
    if (self.isFadeUI) {
        [self switchUItoFade:NO];
    }
    self.selected_btnTag = sender.tag;
    [self changeSelectedBtnUI:sender];
}

- (void)changeSelectedBtnUI:(UIButton *)btn {
    
    [self changeMoveBtnUI:btn];
    
    btn.layer.borderColor = UIColorFromRGB(0x2084FF).CGColor;
    btn.layer.borderWidth = 2;
    [self deselectBtnsUI:btn];
}

- (void)deselectBtnsUI:(UIButton *)selectedBtn {
    [@[self.imgBtn1, self.imgBtn2, self.imgBtn3] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
        if (btn.tag != selectedBtn.tag) {
            btn.layer.borderColor = nil;
            btn.layer.borderWidth = 0;
        }
    }];
}

//修改前移、后移按钮可点击属性
- (void)changeMoveBtnUI:(UIButton *)selectBtn {
    if (self.trimNumber == 1) {
        self.moveForwardBtn.enabled = NO;
        self.moveBackwardBtn.enabled = NO;
    }
    else if (self.trimNumber == 2) {
        if ([self isRect:selectBtn.frame equalToRect:self.pos1]) {
            self.moveForwardBtn.enabled = NO;
            self.moveBackwardBtn.enabled = YES;
        }else if ([self isRect:selectBtn.frame equalToRect:self.pos2]) {
            self.moveForwardBtn.enabled = YES;
            self.moveBackwardBtn.enabled = NO;
        }
    }
    else {
        if ([self isRect:selectBtn.frame equalToRect:self.pos1]) {
            self.moveForwardBtn.enabled = NO;
            self.moveBackwardBtn.enabled = YES;
        }
        else if ([self isRect:selectBtn.frame equalToRect:self.pos2]) {
            self.moveForwardBtn.enabled = YES;
            self.moveBackwardBtn.enabled = YES;
        }else {
            self.moveBackwardBtn.enabled = NO;
            self.moveForwardBtn.enabled = YES;
        }
    }

}

- (void)noneBtnAction:(UIButton *)sender {
    sender.enabled = YES;
    self.transBtn.enabled = NO;
    if (self.delegate &&[self.delegate respondsToSelector:@selector(trimView:fadeInOutPosition:)]) {
        [self.delegate trimView:self fadeInOutPosition:NO];
    }
}

- (void)transBtnAction:(UIButton *)sender {
    sender.enabled = YES;
    self.noneBtn.enabled = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(trimView:fadeInOutPosition:)]) {
        [self.delegate trimView:self fadeInOutPosition:YES];
    }
}

#pragma mark - Private

- (void)selectAllBtns {
    [@[self.btn0,
       self.btn1,
       self.btn2,
       self.btn3] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
           if (btn.enabled) {
               [btn setBackgroundImage:[UIImage imageNamed:@"Oval 2"] forState:UIControlStateNormal];
           }
       }];
    [self transBtnAction:self.transBtn];
}

- (void)deselectAllBtns {
    [@[self.btn0,
       self.btn1,
       self.btn2,
       self.btn3] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
           if (btn.enabled) {
               [btn setBackgroundImage:[UIImage imageNamed:@"白点"] forState:UIControlStateNormal];
           }
       }];
    
    [self noneBtnAction:self.noneBtn];
}

- (void)addVideoFrame {
    for (int i = 0; i < self.videoPaths.count; ++i) {
        NSString *filePath = self.videoPaths[i];
        NSURL *videoURL = [NSURL fileURLWithPath:filePath];
        AVAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];

        if ([self isRetina]) {
            self.imageGenerator.maximumSize = CGSizeMake(self.imgBtn1.width * 2, self.imgBtn1.height * 2);
        } else {
            self.imageGenerator.maximumSize = CGSizeMake(self.imgBtn1.width, self.imgBtn1.height);
        }
        //取第一帧
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:&error];
        UIImage *videoScreen = nil;
        
        if (halfWayImage) {
            if ([self isRetina]) {
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
            }else {
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
            }
            
            switch (i) {
                case 0:
                {
                    [self.imgBtn1 setBackgroundImage:videoScreen forState:UIControlStateNormal];
                    self.imgBtn1.enabled = YES;
                }
                    break;
                case 1:
                {
                    [self.imgBtn2 setBackgroundImage:videoScreen forState:UIControlStateNormal];
                    self.imgBtn2.enabled = YES;
                }
                    break;
                case 2:
                {
                    [self.imgBtn3 setBackgroundImage:videoScreen forState:UIControlStateNormal];
                    self.imgBtn3.enabled = YES;
                }
                    break;
                default:
                    break;
            }
            CGImageRelease(halfWayImage);
        }
    }
}

- (void)moveForwardBtnAction:(UIButton *)sender {
    //这里进行向前交换btn数组
    NSInteger switchPosition = [self getPosFromTag:self.selected_btnTag];
    if (switchPosition > 0) {
        [self switchArrayPos:switchPosition backWard:NO];
        UIButton *btn_sel = self.sortArray[switchPosition];
        UIButton *btn_before = self.sortArray[switchPosition - 1];
        [UIView animateWithDuration:0.3f animations:^{
            CGRect pos = btn_before.frame;
            btn_before.frame = btn_sel.frame;
            btn_sel.frame = pos;
        }];
        
        UIButton *btn = (UIButton *)[self viewWithTag:self.selected_btnTag];
        [self changeSelectedBtnUI:btn];
    }
}

- (void)moveBackwardBtnAction:(UIButton *)sender {
    //这里处理向后交换
    NSInteger switchPosition = [self getPosFromTag:self.selected_btnTag];
    if (switchPosition < self.trimNumber) {
        [self switchArrayPos:switchPosition backWard:YES];
        UIButton *btn_sel = self.sortArray[switchPosition];
        UIButton *btn_after = self.sortArray[switchPosition + 1];
        [UIView animateWithDuration:0.3f animations:^{
            CGRect pos = btn_after.frame;
            btn_after.frame = btn_sel.frame;
            btn_sel.frame = pos;
        }];
        UIButton *btn = (UIButton *)[self viewWithTag:self.selected_btnTag];
        [self changeSelectedBtnUI:btn];
    }
}

- (NSInteger)getPosFromTag:(NSInteger)selectedtag {
    for (int i = 0; i < self.sortArray.count; ++i) {
        UIButton *btn = self.sortArray[i];
        if (selectedtag == btn.tag) {
            return i;
        }
    }
    return -1;
}

- (void)switchArrayPos:(NSInteger)switchPosition backWard:(BOOL)isBackward{
    if (isBackward) {
        [self switchBackward:switchPosition];
    }
    else {
        [self switchForward:switchPosition];
    }
}

- (void)switchForward:(NSInteger)switchPosition {
    UIButton *tempBtn = self.sortArray[switchPosition];
    self.sortArray[switchPosition] = self.sortArray[switchPosition - 1];
    self.sortArray[switchPosition - 1] = tempBtn;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(trimView:switchForward:)]) {
        [self.delegate trimView:self switchForward:switchPosition];
    }
}

- (void)switchBackward:(NSInteger)switchPosition {
    UIButton *tempBtn = self.sortArray[switchPosition];
    self.sortArray[switchPosition] = self.sortArray[switchPosition + 1];
    self.sortArray[switchPosition + 1] = tempBtn;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(trimView:switchBackward:)]) {
        [self.delegate trimView:self switchBackward:switchPosition];
    }
}

- (void)switchUItoFade:(BOOL)isTrans {
    self.isFadeUI = isTrans;
    [@[self.sortLabel,
       self.moveForwardBtn,
       self.moveBackwardBtn,
       self.audioConfig] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
           view.hidden = isTrans;
       }];
    
    [@[self.transLabel,
       self.transBtn,
       self.noneBtn,] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
           view.hidden = !isTrans;
       }];
}

#pragma mark - Private

- (BOOL)isRetina{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0));
}

- (BOOL)isFloat:(CGFloat)float1 equalToFloat:(CGFloat)float2 {
    return fabs(float1-float2) < FLT_EPSILON ? YES : NO;
}

- (BOOL)isRect:(CGRect)rect1 equalToRect:(CGRect)rect2 {
    return [self isFloat:rect1.origin.x equalToFloat:rect2.origin.x]
    && [self isFloat:rect1.origin.y equalToFloat:rect2.origin.y]
    && [self isFloat:rect1.size.width equalToFloat:rect2.size.width]
    && [self isFloat:rect1.size.height equalToFloat:rect2.size.height];
}

@end
