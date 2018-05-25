//
//  NTESUDIDSolution.m
//  XL
//
//  Created by Wesley Lin on 1/2/14.
//
//

#import "NTESUDIDSolution.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/utsname.h>
#include <sys/socket.h> // Per msqr
#include <net/if.h>
#include <net/if_dl.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NTESUDIDSolution

// NOTE: macAddress is deprecated from iOS7 and on
+ (NSString*)macAddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

+ (NSString*)md5StringFromString:(NSString*)strSrc
{
    const char *cStr = [strSrc UTF8String];
    if (NULL==cStr) {
        return @"";
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (unsigned int)strlen(cStr), digest);
    
    char md5string[CC_MD5_DIGEST_LENGTH*2+1];
    
    int i;
    for(i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        sprintf(md5string+i*2, "%02x", digest[i]);
    }
    md5string[CC_MD5_DIGEST_LENGTH*2] = 0;
    
    return @(md5string);
}

+ (NSString*)xlUDIDSourceString_
{
    NSString* xlUDID = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        xlUDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    else {
        xlUDID = [NTESUDIDSolution macAddress];
    }
    return xlUDID;
}

+ (NSString*)xlUDID_MD5
{
    static NSString* xlUDID = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xlUDID = [NTESUDIDSolution xlUDIDSourceString_];
        xlUDID = [NTESUDIDSolution md5StringFromString:xlUDID];
    });
    return xlUDID;
}

+ (NSString*)xlUDID
{
    static NSString* xlUDID = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xlUDID = [NTESUDIDSolution xlUDIDSourceString_];
        NSString* strMD5 = [NTESUDIDSolution md5StringFromString:xlUDID];
        NSString* strHash = [NSString stringWithFormat:@"%.8lx", (unsigned long)[xlUDID hash]];
        xlUDID = [strMD5 stringByAppendingString:strHash];
        NSLog(@"## xlUDID: %@", xlUDID);
    });
    return xlUDID;
}

+ (NSString*)xlUDID_HashToLength:(NSInteger)length
{
    NSString* xlUDID = [NTESUDIDSolution xlUDID];
    if (length < 1 || length > xlUDID.length) {
        return nil;
    }
    else if (length == xlUDID.length)
    {
        return xlUDID;
    }
    return [xlUDID substringFromIndex:xlUDID.length-length];
}

@end
