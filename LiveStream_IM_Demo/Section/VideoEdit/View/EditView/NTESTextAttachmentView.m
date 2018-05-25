//
//  NTESTextAttachmentView.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/8/25.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESTextAttachmentView.h"
#import "NTESTemplatePickerView.h"

@interface NTESTextAttachmentView () <NTESTemplatePickerViewDelegate>

@property(nonatomic, strong) NTESTemplatePickerView *pickerView;

@property(nonatomic, strong) NTESTemplatePickerView *colorPickerView;

@end

@implementation NTESTextAttachmentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    self.pickerView = ({
        NTESTemplatePickerView *pickerView = [[NTESTemplatePickerView alloc] initWithFrame:CGRectMake(30, 22.5 * UISreenHeightScale, UIScreenWidth - 60 * UISreenWidthScale, 80) templateCount:4 templateType:NTESTemplateTypeText];
        pickerView.delegate = self;
        pickerView;
    });
    self.colorPickerView = ({
        NTESTemplatePickerView *colorView = [[NTESTemplatePickerView alloc] initWithFrame:CGRectMake(30, 132.5 * UISreenHeightScale, UIScreenWidth - 60 * UISreenWidthScale, 45) templateCount:6 templateType:NTESTemplateTypeColor];
        colorView.delegate = self;
        colorView;
    });
    
    [self addSubview:self.pickerView];
    [self addSubview:self.colorPickerView];
}

#pragma mark - delegate
- (void)templatePickerView:(NTESTemplatePickerView *)pickerView didSelectTemplate:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textAttachment:selectTextStyle:)]) {
        [self.delegate textAttachment:self selectTextStyle:index];
    }
}

- (void)templatePickerView:(NTESTemplatePickerView *)pickerView didSelectColor:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textAttachment:selectTextColor:)]) {
        [self.delegate textAttachment:self selectTextColor:index];
    }
}

@end
