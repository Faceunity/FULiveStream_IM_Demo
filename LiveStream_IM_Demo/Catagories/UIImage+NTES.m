//
//  UIImage+NTES.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/9.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "UIImage+NTES.h"
#import <objc/runtime.h>

@implementation UIImage (NTES)

- (void)setHandelEvent:(void (^)(id))handelEvent
{
    objc_setAssociatedObject(self, @selector(handelEvent), handelEvent, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(id))handelEvent
{
    return objc_getAssociatedObject(self, _cmd);
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithText:(NSString *)text width:(float)width
{
    // set the font type and size
    UIFont *font = [UIFont systemFontOfSize:12.0]; //字体
    UIColor *color = [UIColor whiteColor]; //颜色
    
    NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    NSDictionary*attribute = @{NSForegroundColorAttributeName:color,
                               NSFontAttributeName:font,
                               NSParagraphStyleAttributeName:paragraphStyle};
    CGSize size = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    
    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [text drawInRect:CGRectMake(0, 0, width, size.height) withAttributes:attribute];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)imageSaveToPhoto:(void(^)(NSError *error))complete
{
    UIImageWriteToSavedPhotosAlbum(self, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    self.handelEvent = [complete copy];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (self.handelEvent) {
        self.handelEvent(error);
    }
}

+ (UIImage*)imageWithVideoPath:(NSString *)filePath
{
    UIImage *shotImage;
    //视频路径URL
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.5, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    shotImage = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return shotImage;
}

@end
