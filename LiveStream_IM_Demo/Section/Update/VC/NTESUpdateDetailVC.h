//
//  NTESUpdateDetailVC.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/10.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseVC.h"

@class NTESVideoEntity;

@interface NTESUpdateDetailVC : NTESBaseVC

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithEntity:(NTESVideoEntity *)entity;

@end
