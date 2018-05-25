//
//  NTESPresentManger.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/13.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NTESPresent;

@interface NTESPresentManger : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *presents; //所有礼物种类

@property (nonatomic, strong, readonly) NSMutableArray <NTESPresent *> *myPresentBox; //礼物盒子（主播）

@property (nonatomic, strong, readonly) NSMutableArray <NTESPresent *> *myPresentShop;//礼物商店（观众）

+ (instancetype)sharedInstance;

- (void)cachePresentToBox:(NTESPresent *)present;

@end
