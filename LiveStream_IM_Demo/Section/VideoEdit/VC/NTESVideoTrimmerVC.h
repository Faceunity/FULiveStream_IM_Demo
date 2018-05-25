//
//  NTESVideoTrimmerVC.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/21.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseVC.h"

@interface NTESVideoTrimmerVC : NTESBaseVC

@property(nonatomic, assign) CGFloat trimDuration;

- (instancetype)initWithVideoURL:(NSString *)videoPath trimDuration:(CGFloat)duration;

@end
