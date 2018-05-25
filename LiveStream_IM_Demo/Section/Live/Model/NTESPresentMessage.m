//
//  NTESPresentMessage.m
//  NIMLiveDemo
//
//  Created by chris on 16/3/29.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESPresentMessage.h"
#import "NTESChatroomDataCenter.h"
#import "NTESPresentAttachment.h"
#import "NTESPresent.h"
#import "NTESPresentManger.h"

@implementation NTESPresentMessage

- (NTESPresentMessage *)initWithNIMPresentMessage:(NIMMessage *)message
{
    NIMCustomObject *object = message.messageObject;
    NTESPresentAttachment *attachment = object.attachment;
    NSDictionary *presents = [NTESPresentManger sharedInstance].presents;
    NTESPresent  *present  = presents[@(attachment.presentType).stringValue];
    
    NTESPresentMessage *presentMessage = [[NTESPresentMessage alloc] init];
    presentMessage.sender = [[NTESMember alloc] initWithUserId:message.from message:message];
    presentMessage.present = present;
    presentMessage.present.count = 1;
    return presentMessage;
}

@end
