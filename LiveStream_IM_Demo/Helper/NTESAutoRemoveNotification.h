//
//  NTESAutoRemoveNotification.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/7/31.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

//使用这个类进行NSNotificaiton的传送，取消其他方法
@interface NTESAutoRemoveNotification : NSObject

+ (void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector name:(NSString *)notificationName object:(id)notificationSender;

@end
