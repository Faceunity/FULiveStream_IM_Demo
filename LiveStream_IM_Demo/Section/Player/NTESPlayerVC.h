//
//  NTESPlayerVC.h
//  NIMLiveDemo
//
//  Created by chris on 16/3/2.
//  Copyright © 2016年 Netease. All rights reserved.
//  直播观众端播放器业务相关

#import "NTESBaseVC.h"

typedef NS_ENUM(NSInteger, NTESPlayType) {
    
    NTESPlayTypeNone = 0,
    NTESPlayTypeVideo,
    NTESPlayTypeAudio,
    NTESPlayTypeVideoAndAudio
};

@interface NTESPlayerVC : NTESBaseVC

@property (nonatomic, readonly) NELivePlayerController *player;

@property (nonatomic, assign) NTESPlayType playType; //播放类型


- (void)startPlay:(NSString *)streamUrl inView:(UIView *)view isFull:(BOOL)isFull;

- (void)releasePlayer;

//子类重载
- (void)doStartPlay;
- (void)doPlayComplete:(NSError *)error;
- (void)doPlayUrlType: (NTESPlayType)playType;

@end
