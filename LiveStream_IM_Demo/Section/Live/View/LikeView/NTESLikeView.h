//
//  NTESLikeView.h
//  NIMLiveDemo
//
//  Created by chris on 16/3/29.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NTESLikeViewProtocol;

@interface NTESLikeView : UIView

@property (nonatomic, weak) id <NTESLikeViewProtocol> delegate;

- (void)hiddenButton:(BOOL)isHidden;

- (void)fireLike;

@end

@protocol NTESLikeViewProtocol <NSObject>

- (void)likeViewSendZan:(NTESLikeView *)likeView;

@end
