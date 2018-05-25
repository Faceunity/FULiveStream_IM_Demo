//
//  NTESUpdateData.m
//  NTESUpadateUI
//
//  Created by Netease on 17/2/28.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateData.h"
#import "NTESVideoEntity.h"
#import "NTESVideoFormatEntity.h"

#define DEFAULT_MAX_VIDEO_COUNT 5

@interface NTESUpdateData ()

@property (nonatomic, copy) NSString *recordPath;

@property (nonatomic, strong) YYDiskCache *cache;

@property (nonatomic, assign) BOOL locIsLoaded;

@end

@implementation NTESUpdateData

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESUpdateData alloc] initWithRecordPath:nil maxVideoCount:DEFAULT_MAX_VIDEO_COUNT];
    });
    return instance;
}

- (instancetype)initWithRecordPath:(NSString *)recordPath maxVideoCount:(NSInteger)maxcount
{
    if (self = [super init])
    {
        _netVideos = [NSMutableArray array];
        
        if (maxcount <= 0)
        {
            maxcount = DEFAULT_MAX_VIDEO_COUNT;
        }
        
        _videoMaxCount = maxcount;
        
        if (recordPath == nil) {
            recordPath = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:@"loc_default_video_record"];
        }
        _recordPath = recordPath;
        
        [NTESAutoRemoveNotification addObserver:self
                                       selector:@selector(saveUpdateRecordToDisk)
                                           name:UIApplicationDidEnterBackgroundNotification
                                         object:nil];
        
        [NTESAutoRemoveNotification addObserver:self
                                       selector:@selector(saveUpdateRecordToDisk)
                                           name:UIApplicationWillTerminateNotification
                                         object:nil];
    }
    return self;
}

- (void)clear
{
    [self saveUpdateRecordToDisk];
    [self.netVideos removeAllObjects];
    [self.locVideos removeAllObjects];
    _locIsLoaded = NO;
}

- (void)loadLocVideos
{
    if (_locIsLoaded) {
        return;
    }
    
    //获取缓存
    _cache = [[YYDiskCache alloc] initWithPath:_recordPath];
    
    _locVideos = [self queryUpdateRecordFromDisk];
    if (!_locVideos) {
        _locVideos = [NSMutableArray array];
    }
    
    _locIsLoaded = YES;
}

- (NTESVideoEntity *)videoInVideosWithVid:(NSString *)vid
{
    NTESVideoEntity *ret = nil;
    for (NTESVideoEntity *item in _netVideos) {
        if ([item.vid isEqualToString:vid]) {
            ret = item;
            break;
        }
    }
    return ret;
}

#pragma mark - 上传记录缓存相关
- (void)saveUpdateRecordToDisk
{
    if (_locVideos)
    {
        [_cache setObject:_locVideos forKey:[_recordPath lastPathComponent]];
    }
}

- (NSMutableArray *)queryUpdateRecordFromDisk
{
    return (NSMutableArray *)[_cache objectForKey:[_recordPath lastPathComponent]];
}

@end
