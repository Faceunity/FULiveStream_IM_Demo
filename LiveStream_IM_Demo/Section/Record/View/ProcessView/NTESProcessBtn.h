//
//  NTESProcessBtn.h
//  ShortVideo_Demo
//
//  Created by Netease on 17/2/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseView.h"

@protocol NTESProcessBtnProtocol;

@interface NTESProcessBtn : NTESBaseView

@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, weak) id <NTESProcessBtnProtocol> delegate;

@property (nonatomic, copy) NSString *titleStr;

- (void)showBtn:(BOOL)isShown;

- (void)stopProgressAnimation;

- (void)startProgressAnimation;

@end


@protocol NTESProcessBtnProtocol <NSObject>

- (void)NTESProcessBtnDidStart:(NTESProcessBtn *)processBtn;

- (void)NTESProcessBtnDidStop:(NTESProcessBtn *)processBtn;

@end
