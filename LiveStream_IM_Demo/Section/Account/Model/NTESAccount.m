//
//  NTESAccount.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAccount.h"

#define NIMAccount      @"accid"
#define NIMToken        @"imToken"
#define NIMNickname     @"nickname"
#define NIMPassword     @"password"

@implementation NTESAccount

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _accid = [aDecoder decodeObjectForKey:NIMAccount];
        _imToken   = [aDecoder decodeObjectForKey:NIMToken];
        _nickname = [aDecoder decodeObjectForKey:NIMNickname];
        _password = [aDecoder decodeObjectForKey:NIMPassword];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if ([_accid length]) {
        [encoder encodeObject:_accid forKey:NIMAccount];
    }
    if ([_imToken length]) {
        [encoder encodeObject:_imToken forKey:NIMToken];
    }
    if ([_nickname length]) {
        [encoder encodeObject:_nickname forKey:NIMNickname];
    }
    if ([_password length]) {
        [encoder encodeObject:_password forKey:NIMPassword];
    }
}


@end
