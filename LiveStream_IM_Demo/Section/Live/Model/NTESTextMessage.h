//
//  NTESTextMessage.h
//  NEUIDemo
//
//  Created by Netease on 17/1/3.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESMember.h"

typedef NS_ENUM(NSInteger,NTESMessageType)
{
    NTESMessageTypeChat,          //对话信息
    NTESMessageTypeNotification,  //系统通知
};


typedef void(^MessageClickBlock)(NSString *userId);

@interface NTESTextMessage : NSObject

//数据模型
@property (nonatomic, assign) NTESMessageType type;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *showName;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, readonly, copy) NSMutableAttributedString *formatString;
@property (nonatomic, copy) MessageClickBlock messageClickBlock;

//样式模型
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) UIColor *fromColor;
@property (nonatomic, strong) UIColor *messageColor;
@property (nonatomic, strong) UIColor *noticationColor;

- (void)caculate:(CGFloat)width;

+ (NTESTextMessage *)textMessage:(NSString *)message sender:(NTESMember *)member;

+ (NTESTextMessage *)systemMessage:(NSString *)message from:(NSString *)from;

@end
