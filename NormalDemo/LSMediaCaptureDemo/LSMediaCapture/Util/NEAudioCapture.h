//
//  NEAudioCapture.h
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/10/17.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <NMCLiveStreaming/NMCLiveStreaming.h>


@protocol NEAudioEncodeDelegate <NSObject>
-(void)didOutputAudioBufferList:(AudioBufferList *)bufferList inNumberFrames:(NSInteger)inNumberFrames;
@end

@interface NEAudioCapture : NSObject
@property(nonatomic, weak) id<NEAudioEncodeDelegate> encodeDelegate;

- (id)initWithAudioParaCtx:(LSAudioParaCtxConfiguration *)audioParaCtx;
@end
