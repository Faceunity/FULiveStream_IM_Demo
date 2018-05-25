//
//  NTESShareMenuBar.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/2/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESMenuBaseBar.h"

typedef void(^CancelBlock)();

@interface NTESShareMenuBar : NTESMenuBaseBar

@property (nonatomic, strong) CancelBlock cancelBlock;

@end
