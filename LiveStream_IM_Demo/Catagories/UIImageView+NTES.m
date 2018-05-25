//
//  UIImageView+NTES.m
//  NEUIDemo
//
//  Created by Netease on 17/1/5.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "UIImageView+NTES.h"

@implementation UIImageView (NTESHelper)

- (void)setCircleImageWithUrl:(NSString *)url
{
    NSURL *urlRequest = [NSURL URLWithString:url];
    
    UIImage *image = [UIImage imageNamed:@"default_avatar_user"];
    
    CGFloat radius = MIN(image.size.width, image.size.height)/2;
    
    UIImage *radiusImage = [image yy_imageByRoundCornerRadius:radius borderWidth:2.f borderColor:[UIColor whiteColor]];
    
    YYWebImageTransformBlock tranformBlock = ^UIImage *(UIImage *image, NSURL *url) {
        return  [image yy_imageByRoundCornerRadius:radius borderWidth:2.0f borderColor:[UIColor whiteColor]];
    };
    
    [self yy_setImageWithURL:urlRequest
                        placeholder:radiusImage
                            options:YYWebImageOptionShowNetworkActivity | YYWebImageOptionSetImageWithFadeAnimation
                           progress:nil
                          transform:tranformBlock
                         completion:nil];
}

@end
