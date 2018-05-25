//
//  NTESPresentAttachment.m
//  NIMLiveDemo
//
//  Created by chris on 16/3/30.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESPresentAttachment.h"
#import "NTESCustomKeyDefine.h"

@implementation NTESPresentAttachment

- (NSString *)encodeAttachment
{
    NSDictionary *attach = @{
                             NTESCMType:@(NTESCustomAttachTypePresent),
                             NTESCMData:@{
                                             NTESCMPresentType : @(self.presentType),
                                             NTESCMPresentCount: @(self.count)
                                         }
                            };
    NSData *data = [NSJSONSerialization dataWithJSONObject:attach options:0 error:nil];
    NSString *str = @"{}";
    if (data) {
        str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return str;
}

@end
