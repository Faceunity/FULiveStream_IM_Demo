//
//  NTESPresentShopView.h
//  NIMLiveDemo
//
//  Created by chris on 16/3/29.
//  Copyright © 2016年 Netease. All rights reserved.
//  观众的礼物商店

#import <UIKit/UIKit.h>
#import "NTESPresent.h"

@protocol NTESPresentShopViewDelegate <NSObject>

- (void)didSelectPresent:(NTESPresent *)present;

@end

@interface NTESPresentShopView : UIControl

@property (nonatomic, strong) NSArray <NTESPresent *> *presents;

@property (nonatomic, weak) id<NTESPresentShopViewDelegate> delegate;

- (void)showPresentShop:(NSArray <NTESPresent *> *)presents;

- (void)dismiss;

@end
