//
//  NTESTranscodingDataCenter.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/15.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESTransConfigEntity.h"

@interface NTESTranscodingDataCenter : NSObject

+ (instancetype)sharedInstance;

+ (void)clear;

@property(nonatomic, strong) NTESTransConfigEntity *transConfig;



@end
