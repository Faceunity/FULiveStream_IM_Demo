//
//  NEReadAudioFileManager.m
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/10/17.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "NEReadAudioFileManager.h"
#import "NETimer.h"
#import <CoreAudio/CoreAudioTypes.h>

#define defaultPcm 50

@interface NEReadAudioFileManager()
{
    FILE *pcmFile;
}
@property(nonatomic, strong) NSMutableArray *fileList;
@property (strong, nonatomic) NSString * path;
@property (strong, nonatomic) NSString * fileName;
@property (nonatomic, strong) NETimer *timer;
@end

@implementation NEReadAudioFileManager

#pragma clang diagnostic ignored "-Wimplicit-retain-self"


+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NEReadAudioFileManager *ne_authorizeManager = nil;
    dispatch_once(&onceToken, ^{
        ne_authorizeManager = [[NEReadAudioFileManager alloc] init];
    });
    return ne_authorizeManager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self initFileList];
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *yuvPath = [docPath stringByAppendingPathComponent:@"PCMFile"];
        if ([self.fileList count] > 0) {
            self.fileName = self.fileList[0];
        }
        self.path =  [NSString stringWithFormat:@"%@/%@", yuvPath, self.fileName];
    }
    return self;
}

-(void)initFileList
{
    self.fileList = [[NSMutableArray alloc] init];
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *yuvPath = [docPath stringByAppendingPathComponent:@"PCMFile"];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:yuvPath];
    
    NSString *path;
    while((path = [enumerator nextObject]) != nil) {
        BOOL isDirectory = YES;
        
        [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", yuvPath, path] isDirectory:&isDirectory];
        
        if (!isDirectory && ![path containsString:@".DS_Store"] && ![path containsString:@".log"]) {
            [self.fileList addObject:path];
        }
    }
    
}

- (void)startPcmFile
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if (pcmFile) {
        fclose(pcmFile);
        pcmFile = NULL;
    }
    
    if (self.fileName == nil || [self.fileName length] == 0) {
        return;
    }
    
    if ([self openFile:self.path]) {
        NSTimeInterval interval = (float) 1000 / defaultPcm;
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __weak typeof(self) weakSelf = self;
            _timer = [NETimer repeatingTimerWithTimeInterval:interval block:^{
                [weakSelf readPCMFile];
            }];
        });
    }
}

- (void)stopPcmFile{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if (pcmFile) {
        fclose(pcmFile);
        pcmFile = NULL;
    }
}

- (BOOL)openFile:(NSString *)url
{
    const char * filePathChar = [url UTF8String];
    
    pcmFile = fopen(filePathChar, "r");
    
    if (!pcmFile) {
        NSLog(@"open pcmfile failed");
        return NO;
    }
    else
    {
        NSLog(@"open pcmfile success");
        return YES;
    }
}

- (void)readPCMFile
{
    NSLog(@"read pcmfile");
    
    int len = 2048;
    
    Byte buf[len];
    
    long num = fread(buf,1,len,pcmFile);
    
    if (num == 0) {
        if (/* DISABLES CODE */ (1)) {
            //这里可以停止
            NSLog(@"read stop!");
            [self stopPcmFile];
            if (self.delegate && [self.delegate respondsToSelector:@selector(didReadAudioFileComplete)]) {
                [self.delegate didReadAudioFileComplete];
            }
            return;
        }else{
            //也可以发静音帧
            NSLog(@"read 0!");
            AudioBuffer buffer;
            buffer.mNumberChannels = 1;
            buffer.mDataByteSize = len;
            buffer.mData = calloc(1, len);
            
            memset(buffer.mData, 0, len);
            
            // bufferlist
            AudioBufferList bufferList;
            bufferList.mNumberBuffers = 1;
            bufferList.mBuffers[0] = buffer;
            
            //发送
            if (self.delegate && [self.delegate respondsToSelector:@selector(didReadAudioBufferList:inNumberFrames:)]) {
                [self.delegate didReadAudioBufferList:&bufferList inNumberFrames:bufferList.mBuffers[0].mDataByteSize/2];
            }
            
            free(buffer.mData);
        }
        
    }else{
        AudioBuffer buffer;
        buffer.mNumberChannels = 1;
        buffer.mDataByteSize = len;
        buffer.mData = (void *)buf;
        
        // bufferlist
        AudioBufferList bufferList;
        bufferList.mNumberBuffers = 1;
        bufferList.mBuffers[0] = buffer;
        
        //发送
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReadAudioBufferList:inNumberFrames:)]) {
            [self.delegate didReadAudioBufferList:&bufferList inNumberFrames:bufferList.mBuffers[0].mDataByteSize/2];
        }
    }
}
@end
