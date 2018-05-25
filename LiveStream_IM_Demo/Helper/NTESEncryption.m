//
//  NTESEncryption.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/7/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESEncryption.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NTESEncryption

+ (NSString *)md5EncryptWithString:(NSString *)string {
    return [self md5:[NSString stringWithFormat:@"%@", string]];
}

+ (NSString *)md5:(NSString *)string {
    const char* input = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}


@end

