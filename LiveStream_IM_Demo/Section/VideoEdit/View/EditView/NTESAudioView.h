//
//  NTESAudioView.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/5/27.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseView.h"

@class NTESAudioView;
@protocol NTESAudioViewDelegate <NSObject>

- (void)audioView:(NTESAudioView *)audioView selectAudio:(NSInteger)index;

//这里是原声强度占比
- (void)audioView:(NTESAudioView *)audioView mainAudioVolume:(CGFloat)volume;

@end

@interface NTESAudioView : NTESBaseView

@property(nonatomic, weak) id<NTESAudioViewDelegate> delegate;


@end
