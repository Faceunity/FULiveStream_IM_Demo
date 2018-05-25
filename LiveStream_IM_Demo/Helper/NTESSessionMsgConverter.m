//
//  NTESSessionMsgHelper.m
//  NIMDemo
//
//  Created by ght on 15-1-28.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESSessionMsgConverter.h"
#import "NSString+NTES.h"
#import "NTESPresentAttachment.h"
#import "NTESLikeAttachment.h"
#import "NTESPresent.h"

@implementation NTESSessionMsgConverter


+ (NIMMessage*)msgWithText:(NSString*)text
{
    NIMMessage *textMessage = [[NIMMessage alloc] init];
    textMessage.text        = text;
    return textMessage;
}

+ (NIMMessage *)msgWithTip:(NSString *)tip
{
    NIMMessage *message        = [[NIMMessage alloc] init];
    NIMTipObject *tipObject    = [[NIMTipObject alloc] init];
    message.messageObject      = tipObject;
    message.text               = tip;
    NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
    setting.apnsEnabled        = NO;
    message.setting            = setting;
    return message;
}

+ (NIMMessage *)msgWithPresent:(NTESPresent *)present
{
    NIMMessage *message        = [[NIMMessage alloc] init];
    NIMCustomObject *object    = [[NIMCustomObject alloc] init];
    NTESPresentAttachment *attachment = [[NTESPresentAttachment alloc] init];
    attachment.presentType     = present.type;
    attachment.count           = 1;
    object.attachment          = attachment;
    message.messageObject      = object;
    return message;
}

+ (NIMMessage *)msgWithLike
{
    NIMMessage *message        = [[NIMMessage alloc] init];
    NIMCustomObject *object    = [[NIMCustomObject alloc] init];
    NTESLikeAttachment *attachment = [[NTESLikeAttachment alloc] init];
    object.attachment          = attachment;
    message.messageObject      = object;
    return message;
}


@end
