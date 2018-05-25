//
//  UIColor+NTESHelper.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/9/11.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "UIColor+NTESHelper.h"

@implementation UIColor (NTESHelper)

+ (UIColor *)colorWithHex:(NSInteger)hex {
    return [UIColor colorWithRed:((float)((hex & 0xff0000) >> 16))/255.0
                            green:((float)((hex & 0x00ff00) >> 8))/255.0
                            blue:((float)(hex & 0x0000ff))/255.0 alpha:1.0];
}

+ (UIColor *)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((float)((hex & 0xff0000) >> 16))/255.0
                           green:((float)((hex & 0x00ff00) >> 8))/255.0
                            blue:((float)(hex & 0x0000ff))/255.0 alpha:(alpha)];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    return [self colorWithHexString:hexString alpha:1.f];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat  red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = alpha;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            blue=0;
            green=0;
            red=0;
            alpha=0;
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *subStr = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? subStr : [NSString stringWithFormat:@"%@%@", subStr, subStr];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.;
}

@end
