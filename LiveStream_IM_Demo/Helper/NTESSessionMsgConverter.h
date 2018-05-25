//
//  NTESSessionMsgHelper.h
//  NIMDemo
//
//  Created by ght on 15-1-28.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NIMSDK.h"

@class NTESPresent;

@interface NTESSessionMsgConverter : NSObject

+ (NIMMessage *)msgWithText:(NSString*)text;

+ (NIMMessage *)msgWithTip:(NSString *)tip;

+ (NIMMessage *)msgWithPresent:(NTESPresent *)present;

+ (NIMMessage *)msgWithLike;

@end