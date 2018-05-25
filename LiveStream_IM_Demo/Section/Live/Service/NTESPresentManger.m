//
//  NTESPresentManger.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/13.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESPresentManger.h"
#import "NTESPresent.h"

static NSString *kNtesPresentBoxPath = @"ntes_present_box_data"; //礼物盒子相对路径

@interface NTESPresentManger ()
@property (nonatomic, strong) NSMutableDictionary *allPresents; //所有礼物
@property (nonatomic, strong) NSMutableArray<NTESPresent *> *presentBox;  //礼物盒子（主播）
@property (nonatomic, strong) NSMutableArray<NTESPresent *> *presentShop; //礼物商店（观众）
@property (nonatomic, strong) YYDiskCache *presentBoxDiskCache;
@end

@implementation NTESPresentManger

- (instancetype)init
{
    if (self = [super init])
    {
        
        [NTESAutoRemoveNotification addObserver:self
                                       selector:@selector(onEnterBackground)
                                           name:UIApplicationDidEnterBackgroundNotification
                                         object:nil];
        
        [NTESAutoRemoveNotification addObserver:self
                                       selector:@selector(onAppWillTerminate)
                                           name:UIApplicationWillTerminateNotification
                                         object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [self archivePresentBox];
}

#pragma mark - Public
+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESPresentManger alloc] init];
    });
    return instance;
}

- (void)cachePresentToBox:(NTESPresent *)present
{
    if (!present) {
        return;
    }
    
    NTESPresent *dstPresent = nil;

    for (NTESPresent *item in self.presentBox)
    {
        if (item.type == present.type)
        {
            dstPresent = [[NTESPresent alloc] init];
            dstPresent.type = item.type;
            dstPresent.name = item.name;
            dstPresent.icon = item.icon;
            dstPresent.count = item.count + present.count;
            NSInteger dstIndex = [self.presentBox indexOfObject:item];
            [self.presentBox replaceObjectAtIndex:dstIndex withObject:dstPresent];
            break;
        }
    }
    
    if (!dstPresent)
    {
        [self.presentBox addObject:present];
    }
}

#pragma mark - Private
//从本地读取礼物商店
- (NSMutableArray *)unarchivePresentShop
{
    NSMutableArray *presentShop = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Presents" ofType:@"plist"];
    
    if (path)
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
        for (NSString *key in dict) {
            NSDictionary *p = dict[key];
            NTESPresent *present = [[NTESPresent alloc] init];
            present.type = key.integerValue;
            present.name = p[@"name"];
            present.icon = p[@"icon"];
            if (!presentShop) {
                presentShop = [NSMutableArray array];
            }
            [presentShop addObject:present];
        }
    }
    return presentShop;
}

//从本地读取礼物列表
- (NSMutableDictionary *)unarchivePresent
{
    NSMutableDictionary *presents = [NSMutableDictionary dictionary];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Presents" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    for (NSString *key in dict) {
        NSDictionary *p = dict[key];
        NTESPresent *present = [[NTESPresent alloc] init];
        present.type = key.integerValue;
        present.name = p[@"name"];
        present.icon = p[@"icon"];
        presents[key] = present;
    }
    return presents;
}

//从本地读取礼物盒子
- (NSArray *)unarchivePresentBox
{
    return (NSArray *)[self.presentBoxDiskCache objectForKey:@"presentBox"];
}

//礼物盒子保存至本地
- (void)archivePresentBox
{
    [self.presentBoxDiskCache setObject:self.presentBox forKey:@"presentBox"];
}

#pragma mark - Notication Action
- (void)onEnterBackground
{
    [self archivePresentBox];
}
- (void)onAppWillTerminate
{
    [self archivePresentBox];
}

#pragma mark - Setter/Getter
- (NSDictionary *)presents
{
    return self.allPresents;
}

- (NSArray<NTESPresent *> *)myPresentBox
{
    return self.presentBox;
}

- (NSMutableArray<NTESPresent *> *)myPresentShop
{
    return self.presentShop;
}

- (NSMutableDictionary *)allPresents
{
    if (!_allPresents)
    {
        //从本地读取
        _allPresents = [self unarchivePresent];
    }
    return _allPresents;
}

- (NSMutableArray<NTESPresent *> *)presentBox
{
    if (!_presentBox)
    {
        //从本地读取
        _presentBox = [NSMutableArray arrayWithArray:[self unarchivePresentBox]];
    }
    return _presentBox;
}

- (NSMutableArray<NTESPresent *> *)presentShop
{
    if (!_presentShop)
    {
        //从本地读取
        _presentShop = [NSMutableArray arrayWithArray:[self unarchivePresentShop]];
    }
    return _presentShop;
}

- (YYDiskCache *)presentBoxDiskCache
{
    if (!_presentBoxDiskCache)
    {
        _presentBoxDiskCache = [[YYDiskCache alloc] initWithPath:self.presentBoxDataPath];
    }
    return _presentBoxDiskCache;
}

- (NSString *)presentBoxDataPath
{
    return [[NTESSandboxHelper userRootPath] stringByAppendingPathComponent:kNtesPresentBoxPath];
}

@end
