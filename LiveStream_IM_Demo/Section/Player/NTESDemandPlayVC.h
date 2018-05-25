//
//  NTESDemandPlayVC.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESPlayerVC.h"

@interface NTESDemandPlayVC : NTESPlayerVC

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *playUrl;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithName:(NSString *)name url:(NSString *)playUrl;

@end
