//
//  NTESNormalMessageView.h
//  NEUIDemo
//
//  Created by Netease on 17/1/3.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTESTextMessage;
@protocol NTESNormalMessageViewProtocol;

@interface NTESNormalMessageView : UIView

@property (nonatomic, weak) id <NTESNormalMessageViewProtocol> delegate;

- (void)addMessages:(NSArray <NTESTextMessage *> *)messages;

@end

@protocol NTESNormalMessageViewProtocol <NSObject>
@optional
- (void)normalMessageView:(NTESNormalMessageView *)chatView clickUserId:(NSString *)userId;

@end
