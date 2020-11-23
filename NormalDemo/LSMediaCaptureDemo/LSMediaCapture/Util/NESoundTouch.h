//
//  NESoundTouch.h
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/12/28.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NESoundTouch : NSObject
- (instancetype)initWithSampleRate:(Float64)sampleRate pitchSemiTones:(int)pitch; //声音的pitch (集音高变化semi-tones相比原来的音调) //男: -8 女:8

- (NSUInteger)processSound:(short *)pcmSamples number:(NSUInteger)nSamples;
@end
