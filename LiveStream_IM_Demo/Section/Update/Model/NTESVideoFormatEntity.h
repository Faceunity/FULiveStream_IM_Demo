//
//  NTESVideoFormatEntity.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/10.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESUpdateDefine.h"

@interface NTESVideoFormatEntity : NSObject

@property (nonatomic, assign) NTESVideoFormat format;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) CGFloat size;

@end
