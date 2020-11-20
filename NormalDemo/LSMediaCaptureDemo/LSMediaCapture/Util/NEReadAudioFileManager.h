//
//  NEReadAudioFileManager.h
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/10/17.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@protocol NEReadAudioFileManagerDelegate <NSObject>
-(void)didReadAudioBufferList:(AudioBufferList *)bufferList inNumberFrames:(NSInteger)inNumberFrames;
-(void)didReadAudioFileComplete;
@end

@interface NEReadAudioFileManager : NSObject
@property(nonatomic, weak) id <NEReadAudioFileManagerDelegate> delegate;
+ (instancetype)sharedInstance;
- (void)startPcmFile;
- (void)stopPcmFile;
@end
