//
//  NTESTemplatePickerView.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/12.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseView.h"

typedef NS_ENUM(NSInteger, NTESTemplateType) {
    NTESTemplateTypeTexture = 1,//贴图
    NTESTemplateTypeAudio,       //伴音
    NTESTemplateTypeText,        //文字
    NTESTemplateTypeColor,       //颜色
};

@class NTESTemplatePickerView;
@protocol NTESTemplatePickerViewDelegate <NSObject>

@optional

- (void)templatePickerView:(NTESTemplatePickerView *)pickerView didSelectTemplate:(NSInteger)index;

- (void)templatePickerView:(NTESTemplatePickerView *)pickerView didSelectColor:(NSInteger)index;

@end

@interface NTESTemplatePickerView : NTESBaseView

@property(nonatomic, assign) NTESTemplateType templateType;
//模版的个数
@property(nonatomic, assign) NSInteger tempCount;

@property(nonatomic, weak) id<NTESTemplatePickerViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame templateCount:(NSInteger)count templateType:(NTESTemplateType)type NS_DESIGNATED_INITIALIZER;

@end
