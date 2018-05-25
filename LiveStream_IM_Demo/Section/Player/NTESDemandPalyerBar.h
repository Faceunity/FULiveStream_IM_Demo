//
//  NTESDemandPalyerBar.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NTESDemandPalyerBarProtocol;

@interface NTESDemandPalyerBar : UIView

@property (nonatomic, strong) NSString *titleStr;

@property (nonatomic, assign) NSInteger duration;

@property (nonatomic, assign) NSInteger playTime;

@property (nonatomic, assign) NSInteger maxValue;

@property (nonatomic, assign) NSInteger curValue;

@property (nonatomic, assign) BOOL isStart;

@property (nonatomic, assign) BOOL isMuted;

@property (nonatomic, assign) BOOL isFull;

@property (nonatomic, weak) id <NTESDemandPalyerBarProtocol> delegate;

- (void)showBar;

- (void)dismissBar;

@end

@protocol NTESDemandPalyerBarProtocol <NSObject>
@optional

- (void)PlayerBarBackAction:(NTESDemandPalyerBar *)bar;

- (void)PlayerBarStartAction:(NTESDemandPalyerBar *)bar;

- (void)PlayerBarMuteAction:(NTESDemandPalyerBar *)bar;

- (void)PlayerBarSnapAction:(NTESDemandPalyerBar *)bar;

- (void)PlayerBarFullAction:(NTESDemandPalyerBar *)bar;

- (void)PlayerBar:(NTESDemandPalyerBar *)bar processChanged:(CGFloat)process;

@end
