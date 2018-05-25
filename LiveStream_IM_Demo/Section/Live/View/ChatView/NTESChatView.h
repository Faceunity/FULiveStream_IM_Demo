//
//  NTESChatView.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/11.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NTESNormalMessageView.h"
#import "NTESPresentMessageView.h"
#import "NTESPresentMessage.h"
#import "NTESTextMessage.h"

@protocol NTESChatViewProtocol;

@interface NTESChatView : UIView

@property (nonatomic, weak) id <NTESChatViewProtocol> delegate;

- (void)addNormalMessages:(NSArray <NTESTextMessage *> *)normalMessages;

- (void)addPresentMessage:(NTESPresentMessage *)presentMessage;

@end

@protocol NTESChatViewProtocol <NSObject>

- (void)chatView:(NTESChatView *)chatView clickUserId:(NSString *)userId;

@end
