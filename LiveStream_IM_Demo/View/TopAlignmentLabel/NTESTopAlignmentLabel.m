//
//  NTESTopAlignmentLabel.m
//  NTESUpadateUI
//
//  Created by Netease on 17/2/27.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESTopAlignmentLabel.h"

@implementation NTESTopAlignmentLabel

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    textRect.origin.y = bounds.origin.y;
    return textRect;
}
-(void)drawTextInRect:(CGRect)requestedRect {
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

@end
