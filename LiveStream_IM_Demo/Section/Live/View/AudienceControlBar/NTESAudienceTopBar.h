//
//  NTESAudienceTopBar.h
//  NEUIDemo
//
//  Created by Netease on 17/1/4.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NTESChatroom.h"

@protocol NTESAudienceTopBarProtocol;

@interface NTESAudienceTopBar : UIView

@property (nonatomic, weak) id <NTESAudienceTopBarProtocol> delegate;

@property (nonatomic, strong) NSMutableArray <NTESMember *> *audiences;

+ (instancetype)topBarInstance;

- (void)refreshBarWithChatroom:(NTESChatroom *)chatroom;

- (void)refreshBarWithCreator:(NTESMember *)creator;

- (void)refreshBarWithAudiences:(NSArray <NTESMember *> *)audiences;

@end

@protocol NTESAudienceTopBarProtocol <NSObject>
@optional
- (void)topBarClickClose:(NTESAudienceTopBar *)bar;

@end
