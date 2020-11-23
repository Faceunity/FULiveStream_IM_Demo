//
//  NEAudioCapture.m
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/10/17.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "NEAudioCapture.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface NEAudioCapture ()
@property (nonatomic, assign) AudioComponentInstance componetInstance;
@property (nonatomic, assign) AudioComponent component;
@property (nonatomic, strong) dispatch_queue_t taskQueue;
@property (nonatomic, strong,nullable) LSAudioParaCtxConfiguration *configuration;
@end

@implementation NEAudioCapture

- (id)initWithAudioParaCtx:(LSAudioParaCtxConfiguration *)audioParaCtx{
    if(self = [super init]){
        _configuration = audioParaCtx;
        self.taskQueue = dispatch_queue_create("com.netease.audioCaptureQueue", NULL);
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleRouteChange:)
                                                     name: AVAudioSessionRouteChangeNotification
                                                   object: session];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleInterruption:)
                                                     name: AVAudioSessionInterruptionNotification
                                                   object: session];
        
        AudioComponentDescription acd;
        acd.componentType = kAudioUnitType_Output;
        //acd.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
        acd.componentSubType = kAudioUnitSubType_RemoteIO;
        acd.componentManufacturer = kAudioUnitManufacturer_Apple;
        acd.componentFlags = 0;
        acd.componentFlagsMask = 0;
        
        self.component = AudioComponentFindNext(NULL, &acd);
        
        OSStatus status = noErr;
        status = AudioComponentInstanceNew(self.component, &_componetInstance);
        
        if (noErr != status) {
            [self handleAudioComponentCreationFailure];
        }
        
        UInt32 flagOne = 1;
        
        AudioUnitSetProperty(self.componetInstance, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &flagOne, sizeof(flagOne));
        
        AudioStreamBasicDescription desc = {0};
        desc.mSampleRate = _configuration.samplerate;
        desc.mFormatID = kAudioFormatLinearPCM;
        desc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
        desc.mChannelsPerFrame = (UInt32)_configuration.numOfChannels;
        desc.mFramesPerPacket = 1;
        desc.mBitsPerChannel = 16;
        desc.mBytesPerFrame = desc.mBitsPerChannel / 8 * desc.mChannelsPerFrame;
        desc.mBytesPerPacket = desc.mBytesPerFrame * desc.mFramesPerPacket;
        
        AURenderCallbackStruct cb;
        cb.inputProcRefCon = (__bridge void *)(self);
        cb.inputProc = handleInputBuffer;
        AudioUnitSetProperty(self.componetInstance, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &desc, sizeof(desc));
        AudioUnitSetProperty(self.componetInstance, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 1, &cb, sizeof(cb));
        
    AudioUnitSetProperty(self.componetInstance,kAudioUnitProperty_StreamFormat,kAudioUnitScope_Input,0,&desc,sizeof(desc));
        
        status = AudioUnitInitialize(self.componetInstance);
        
        if (noErr != status) {
            [self handleAudioComponentCreationFailure];
        }
        
        [session setPreferredSampleRate:_configuration.samplerate error:nil];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        [session setActive:YES withOptions:kAudioSessionSetActiveFlag_NotifyOthersOnDeactivation error:nil];
        
        [session setActive:YES error:nil];
        
        AudioOutputUnitStart(self.componetInstance);
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    dispatch_sync(self.taskQueue, ^{
        if (self.componetInstance) {
            AudioOutputUnitStop(self.componetInstance);
            AudioComponentInstanceDispose(self.componetInstance);
            self.componetInstance = nil;
            self.component = nil;
        }
    });
}

#pragma mark -- CustomMethod
- (void)handleAudioComponentCreationFailure {
    NSLog(@"handleAudioComponentCreationFailure");
}

#pragma mark -- NSNotification
- (void)handleRouteChange:(NSNotification *)notification {
    AVAudioSession *session = [ AVAudioSession sharedInstance ];
    NSString *seccReason = @"";
    NSInteger reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    //  AVAudioSessionRouteDescription* prevRoute = [[notification userInfo] objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            seccReason = @"The route changed because no suitable route is now available for the specified category.";
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            seccReason = @"The route changed when the device woke up from sleep.";
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            seccReason = @"The output route was overridden by the app.";
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            seccReason = @"The category of the session object changed.";
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            seccReason = @"The previous audio output path is no longer available.";
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            seccReason = @"A preferred new audio output path is now available.";
            break;
        case AVAudioSessionRouteChangeReasonUnknown:
        default:
            seccReason = @"The reason for the change is unknown.";
            break;
    }
    NSLog(@"handleRouteChange reason is %@", seccReason);
    
    AVAudioSessionPortDescription *input = [[session.currentRoute.inputs count] ? session.currentRoute.inputs : nil objectAtIndex:0];
    if (input.portType == AVAudioSessionPortHeadsetMic) {
        
    }
}

- (void)handleInterruption:(NSNotification *)notification {
    NSInteger reason = 0;
    NSString *reasonStr = @"";
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        //Posted when an audio interruption occurs.
        reason = [[[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey] integerValue];
        if (reason == AVAudioSessionInterruptionTypeBegan) {
            dispatch_sync(self.taskQueue, ^{
                NSLog(@"MicrophoneSource: stopRunning");
                AudioOutputUnitStop(self.componetInstance);
            });
        }
        
        if (reason == AVAudioSessionInterruptionTypeEnded) {
            reasonStr = @"AVAudioSessionInterruptionTypeEnded";
            AVAudioSessionInterruptionOptions option = [notification.userInfo[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
            if (option == AVAudioSessionInterruptionOptionShouldResume)
            {
                dispatch_async(self.taskQueue, ^{
                    NSLog(@"MicrophoneSource: stopRunning");
                    AudioOutputUnitStart(self.componetInstance);
                });
            }
        }
        
    }
    ;
    NSLog(@"handleInterruption: %@ reason %@", [notification name], reasonStr);
}

#pragma mark -- CallBack
static OSStatus handleInputBuffer(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    @autoreleasepool {
        NEAudioCapture *source = (__bridge NEAudioCapture *)inRefCon;
        if (!source) return -1;
        
        AudioBuffer buffer;
        buffer.mData = NULL;
        buffer.mDataByteSize = 0;
        buffer.mNumberChannels = 1;
        
        AudioBufferList buffers;
        buffers.mNumberBuffers = 1;
        buffers.mBuffers[0] = buffer;
        
        OSStatus status = AudioUnitRender(source.componetInstance,
                                          ioActionFlags,
                                          inTimeStamp,
                                          inBusNumber,
                                          inNumberFrames,
                                          &buffers);


        
        if (!status) {
            if (source.encodeDelegate && [source.encodeDelegate respondsToSelector:@selector(didOutputAudioBufferList:inNumberFrames:)]) {
                [source.encodeDelegate didOutputAudioBufferList:&buffers inNumberFrames:inNumberFrames];
            }
        }
        return status;
    }
}
@end
