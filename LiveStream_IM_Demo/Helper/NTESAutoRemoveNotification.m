//
//  NTESAutoRemoveNotification.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/7/31.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAutoRemoveNotification.h"
#import <objc/runtime.h>

@interface NTESAutoRemoveNotification ()

@property(nonatomic, unsafe_unretained) id notificationObserver;

@property(nonatomic, assign) id notificationSender;
@property(nonatomic, copy) NSString *notificaitonName;

@property(nonatomic, strong) id blockObserver;


@end

@implementation NTESAutoRemoveNotification

+ (void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector name:(NSString *)notificationName object:(id)notificationSender {
    
    NTESAutoRemoveNotification *removeNotification = [[NTESAutoRemoveNotification alloc] init];
    removeNotification.notificationObserver = notificationObserver;
    removeNotification.notificaitonName = notificationName;
    removeNotification.notificationSender = notificationSender;
    
    objc_setAssociatedObject(notificationObserver, (__bridge const void*)(removeNotification), removeNotification, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[NSNotificationCenter defaultCenter] addObserver:notificationObserver
                                             selector:notificationSelector
                                                 name:notificationName
                                               object:notificationSender];
}

- (void)dealloc {
    if (self.blockObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.blockObserver];
    } else  {
        [[NSNotificationCenter defaultCenter] removeObserver:self.notificationObserver
                                                        name:self.notificaitonName
                                                      object:self.notificationSender];
    }
}


@end
