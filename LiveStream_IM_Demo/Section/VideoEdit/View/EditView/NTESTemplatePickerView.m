//
//  NTESTemplatePickerView.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/12.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESTemplatePickerView.h"
#import "UIColor+NTESHelper.h"

#define templateSpace 25

@interface NTESTemplatePickerView ()

@property(nonatomic, strong) UIScrollView *containerScrollView;

@property(nonatomic, assign) CGFloat totalWidth;

@property(nonatomic, strong) UIButton *templateBtn;


@end

@implementation NTESTemplatePickerView

- (instancetype)initWithFrame:(CGRect)frame templateCount:(NSInteger)count templateType:(NTESTemplateType)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.tempCount = count;
        self.templateType = type;
        [self setupSubViews];
    }
    return self;
}


- (void)setupSubViews {
    self.containerScrollView = ({
        UIScrollView *view = [[UIScrollView alloc] init];
        view.showsVerticalScrollIndicator = NO;
        view.showsHorizontalScrollIndicator = NO;
        view;
    });
    [self addSubview:self.containerScrollView];
    [self addTemplates];

}

- (void)addTemplates {
    self.containerScrollView.frame = self.bounds;
    NSString *prefixStr = @"";
    switch (self.templateType) {
        case NTESTemplateTypeTexture:
        {
            prefixStr = @"贴图";
            [self addTexture];
            break;
        }
        case NTESTemplateTypeAudio:
        {
            prefixStr = @"伴音";
            [self addAudio];
            break;
        }
            case NTESTemplateTypeText:
        {
            [self addTextAttachment];
        }
            break;
        case NTESTemplateTypeColor:
        {
            [self addColor];
        }
            break;
        default:
            break;
    }
    self.containerScrollView.contentSize = CGSizeMake(self.totalWidth, self.containerScrollView.height);
    self.containerScrollView.bounces = NO;
    self.containerScrollView.alwaysBounceHorizontal = NO;
}

#pragma mark - Private

- (void)addTexture {
    CGFloat offset = 0;
    NSArray *textImgArray = @[@"无", @"亲亲", @"刺刀", @"鬼脸"];

    CGFloat templateWidth = (self.containerScrollView.width - templateSpace * (self.tempCount - 1)) / self.tempCount;
    for (int i = 0; i < self.tempCount; ++i) {
            
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(offset, 0, templateWidth, templateWidth)];
        btn.tag = i + 10 * NTESTemplateTypeTexture;
        UIImage *img = [UIImage imageNamed:textImgArray[i]];
        [btn setImage:img forState:UIControlStateNormal];
        btn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        btn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
        [self.containerScrollView addSubview:btn];
        
        offset += templateWidth + templateSpace;
        if (i == self.tempCount - 2) {
            self.totalWidth = offset + templateWidth;
        }
        [btn addTarget:self action:@selector(textureBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            [self textureBtnAction:btn];
        }
    }
}

- (void)addAudio {
    CGFloat offset = 0;
    CGFloat templateWidth = (self.containerScrollView.width - templateSpace * (self.tempCount - 1)) / self.tempCount;
    for (int i = 0; i < self.tempCount; ++i) {
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(offset, 0, templateWidth, templateWidth)];
        btn.tag = i + 10 * NTESTemplateTypeAudio;
        if (i == 0) {
            UIImage *img = [UIImage imageNamed:@"无"];
            [btn setImage:img forState:UIControlStateNormal];
            btn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        }else {
            NSString *title = [NSString stringWithFormat:@"伴音%i", i];
            [btn setTitle:title forState:UIControlStateNormal];
        }
        
        btn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
        [self.containerScrollView addSubview:btn];
        
        offset += templateWidth + templateSpace;
        if (i == self.tempCount - 2) {
            self.totalWidth = offset + templateWidth;
        }
        [btn addTarget:self action:@selector(audioBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            [self audioBtnAction:btn];
        }
    }
}

- (void)addTextAttachment {
    NSArray <NSString *> *textArr = @[@"无", @"t1", @"t2", @"t3"];
    CGFloat offset = 0;
    CGFloat templateWidth = (self.containerScrollView.width - templateSpace * (self.tempCount - 1)) / self.tempCount;
    for (int i = 0; i < self.tempCount; ++i) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(offset, 0, templateWidth, templateWidth)];
        btn.tag = i + 10 * NTESTemplateTypeText;
        UIImage *img = [UIImage imageNamed:textArr[i]];
        [btn setImage:img forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.f];
        [self.containerScrollView addSubview:btn];
        
        offset += templateWidth + templateSpace;
        if (i == self.tempCount - 2) {
            self.totalWidth = offset + templateWidth;
        }
        [btn addTarget:self action:@selector(textAttachmentBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            [self textAttachmentBtnAction:btn];
        }
    }
}

- (void)addColor {
    CGFloat offset = 0.f;
    CGFloat templateWidth = (self.containerScrollView.width - templateSpace * (self.tempCount - 1)) / self.tempCount;
    NSArray *colorArr = @[@"000000", @"FFFFFF", @"FBDC40", @"F21111", @"0021FF", @"009E1A"];
    for (int i = 0; i < self.tempCount; ++i) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(offset, 0, templateWidth, templateWidth);
        btn.tag = i + 10 * NTESTemplateTypeColor;
        btn.layer.cornerRadius = templateWidth / 2.f;
        btn.backgroundColor = [UIColor colorWithHexString:colorArr[i]];
        [self.containerScrollView addSubview:btn];
        
        offset += templateWidth + templateSpace;
        if (i == self.tempCount - 2) {
            self.totalWidth = offset + templateWidth;
        }
        [btn addTarget:self action:@selector(colorBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            [self colorBtnAction:btn];
        }
    }
}

#pragma mark - action

- (void)textureBtnAction:(UIButton *)sender {
    [self changeSelectBtnUI:sender];
    if (self.delegate && [self.delegate respondsToSelector:@selector(templatePickerView:didSelectTemplate:)]) {
        [self.delegate templatePickerView:self didSelectTemplate:sender.tag - 10 * NTESTemplateTypeTexture];
    }
}

- (void)audioBtnAction:(UIButton *)sender {
    [self changeSelectBtnUI:sender];
    if (self.delegate && [self.delegate respondsToSelector:@selector(templatePickerView:didSelectTemplate:)]) {
        [self.delegate templatePickerView:self didSelectTemplate:sender.tag - 10 * NTESTemplateTypeAudio];
    }

}

- (void)textAttachmentBtnAction:(UIButton *)sender {
    [self changeSelectBtnUI:sender];
    if (self.delegate && [self.delegate respondsToSelector:@selector(templatePickerView:didSelectTemplate:)]) {
        [self.delegate templatePickerView:self didSelectTemplate:sender.tag - 10 * NTESTemplateTypeText];
    }
}

- (void)colorBtnAction:(UIButton *)sender {
    [self changeSelectBtnUI:sender];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(templatePickerView:didSelectColor:)]) {
        [self.delegate templatePickerView:self didSelectColor:sender.tag - 10 * NTESTemplateTypeColor];
    }
}

- (void)changeSelectBtnUI:(UIButton *)btn {
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.layer.borderWidth = 1;
    int offset = 10 * self.templateType;
    for (int i = 0; i < self.tempCount; i++) {
        if (btn.tag != i+ offset) {
            [self viewWithTag:i + offset].layer.borderColor = nil;
            [self viewWithTag:i + offset].layer.borderWidth = 0;
        }
    }
    
}

@end
