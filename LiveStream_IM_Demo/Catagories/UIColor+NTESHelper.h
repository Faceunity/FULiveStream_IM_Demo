//
//  UIColor+NTESHelper.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/9/11.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (NTESHelper)

+ (UIColor *)colorWithHex:(NSInteger)hex;

+ (UIColor *)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha;

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end
