//
//  NTESMember.h
//  NEUIDemo
//
//  Created by Netease on 17/1/5.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTESMember : NSObject

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy) NSString *showName;

@property (nonatomic, copy) NSString *avatarUrlString;

@property (nonatomic, assign) BOOL isMuted;

@property (nonatomic, assign) BOOL isKicked;

- (instancetype)initWithNIMMember:(NIMChatroomMember *)member;

- (instancetype)initWithUserId:(NSString *)userId message:(NIMMessage *)message;

@end
