//
//  NTESMuteBar.h
//  NEUIDemo
//
//  Created by Netease on 17/1/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESMember.h"

typedef void(^MuteActionBlock)(NTESMember *userInfo);

@interface NTESMuteBar : UIView

@property (nonatomic, strong) NTESMember *userInfo;

@property (nonatomic, copy) MuteActionBlock kickBlock;

@property (nonatomic, copy) MuteActionBlock muteBlock;

+ (instancetype)instancView;

@end

