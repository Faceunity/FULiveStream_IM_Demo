//
//  NETimer.h
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2018/1/4.
//  Copyright © 2018年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NETimer : NSObject
+ (NETimer *)repeatingTimerWithTimeInterval:(NSTimeInterval)mSeconds block:(dispatch_block_t)block;
- (void)resetTime:(NSTimeInterval)mSeconds;
- (void)invalidate;
@end
