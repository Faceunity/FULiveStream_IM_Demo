//
//  NTESTextImageView.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/9/12.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

//提供放大、缩小、背景替换

@class NTESTextImageView;
@protocol NTESTextImageViewDelegate <NSObject>
@optional
- (void)textImageViewDidBeginEditing:(NTESTextImageView *)imageView;
- (void)textImageViewDidChangeEditing:(NTESTextImageView *)imaageView;
- (void)textImageVIewDidEndEditing:(NTESTextImageView *)imageView;
- (void)textImageVIewDidClose:(NTESTextImageView *)imageView;

@end

@interface NTESTextImageView : UIImageView <UITextViewDelegate>

@property(nonatomic, assign) CGSize miniSize; //最小框架大小
@property(nonatomic, assign) CGFloat minFontSize;
@property(nonatomic, strong) UIFont *curFont;
@property(nonatomic, strong) UIImage *backImg;
@property(nonatomic, strong) UIColor *textColor;


@property(nonatomic, weak) id<NTESTextImageViewDelegate> textImgViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame andSize:(CGSize)superSize andText:(NSString *)text andColor:(UIColor *)textColor andBackImage:(UIImage *)TextImage NS_DESIGNATED_INITIALIZER;

- (NSString *)textString;

- (void)changeTextColor:(UIColor *)colorType;

- (UIImage *)imageWithText;

@end
