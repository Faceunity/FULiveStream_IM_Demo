//
//  NETimer.m
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2018/1/4.
//  Copyright © 2018年 NetEase. All rights reserved.
//

#import "NETimer.h"

@interface NETimer ()
@property (nonatomic, readwrite, copy) dispatch_block_t block;
@property (nonatomic, readwrite, strong) dispatch_source_t source;
@end

@implementation NETimer
@synthesize block = _block;
@synthesize source = _source;

+ (NETimer *)repeatingTimerWithTimeInterval:(NSTimeInterval)mSeconds
                                      block:(void (^)(void))block {
    NSParameterAssert(mSeconds);
    NSParameterAssert(block);
    
    dispatch_queue_t queue = dispatch_queue_create("com.netease.timer", DISPATCH_QUEUE_SERIAL);
    
    NETimer *timer = [[self alloc] init];
    timer.block = block;
    timer.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                          0, 0,
                                          queue);
    //使用毫秒
    uint64_t nsec = (uint64_t)(mSeconds * NSEC_PER_MSEC);
    //第二个参数dispatch_time(DISPATCH_TIME_NOW, nsec)，当我们使用 dispatch_time 或者 DISPATCH_TIME_NOW 时，系统会使用默认时钟来进行计时。然而当系统休眠的时候，默认时钟是不走的，也就会导致计时器停止。使用 dispatch_walltime 可以让计时器按照真实时间间隔进行计时.
    dispatch_source_set_timer(timer.source,
                              dispatch_walltime(NULL, 0),
                              nsec, 0);
    dispatch_source_set_event_handler(timer.source, block);
    dispatch_resume(timer.source);
    return timer;
}

- (void)resetTime:(NSTimeInterval)mSeconds{
    dispatch_suspend(self.source);
    //使用毫秒
    uint64_t nsec = (uint64_t)(mSeconds * NSEC_PER_MSEC);
    dispatch_source_set_timer(self.source,
                              dispatch_walltime(NULL, 0),
                              nsec, 0);
    dispatch_resume(self.source);
}

- (void)invalidate {
    if (self.source) {
        dispatch_source_cancel(self.source);
        self.source = nil;
    }
    self.block = nil;
}

- (void)dealloc {
    [self invalidate];
}


@end
