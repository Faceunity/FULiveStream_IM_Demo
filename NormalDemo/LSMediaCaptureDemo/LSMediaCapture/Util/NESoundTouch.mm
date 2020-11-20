//
//  NESoundTouch.m
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/12/28.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "NESoundTouch.h"
#include "SoundTouch.h"

using namespace soundtouch;

@interface NESoundTouch()
{
    soundtouch::SoundTouch *soundTouch;
}


@end

@implementation NESoundTouch

- (instancetype)initWithSampleRate:(Float64)sampleRate pitchSemiTones:(int)pitch
{
    if (self = [super init]) {
        soundTouch = new soundtouch::SoundTouch();
        
        soundTouch->setSampleRate(sampleRate); //setSampleRate
        soundTouch->setChannels(1);       //设置声音的声道
        soundTouch->setPitchSemiTones(pitch); //设置声音的pitch (集音高变化semi-tones相比原来的音调) //男: -8 女:8
        soundTouch->setSetting(SETTING_SEQUENCE_MS, 20);
        soundTouch->setSetting(SETTING_SEEKWINDOW_MS, 15); //寻找帧长
        soundTouch->setSetting(SETTING_OVERLAP_MS, 6);  //重叠帧长
        
        
    }
    return self;
}


- (void)dealloc
{
    if (soundTouch) {
        delete soundTouch;
    }
}

- (NSUInteger)processSound:(short *)pcmSamples number:(NSUInteger)nSamples
{
    soundTouch->putSamples(pcmSamples, (uint)nSamples);
    
    return soundTouch->receiveSamples(pcmSamples, (uint)nSamples);
}



@end

