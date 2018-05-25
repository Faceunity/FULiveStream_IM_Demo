//
//  UIImage+NTES.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/9.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (NTES)

+ (UIImage*)imageWithVideoPath:(NSString *)filePath;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)imageWithText:(NSString *)text width:(float)width;

- (void)imageSaveToPhoto:(void(^)(NSError *error))complete;

@end
