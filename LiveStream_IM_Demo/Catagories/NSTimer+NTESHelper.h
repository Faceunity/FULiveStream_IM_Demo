//
//  NSTimer+NTESHelper.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/8/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (NTESHelper)

+ (NSTimer *)ntes_scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void(^)())inBlock repeats:(BOOL)inRepeats;

+ (NSTimer *)ntes_timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;



@end
