//
//  NTESAccount.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTESAccount : NSObject<NSCoding>

@property(nonatomic, copy) NSString *accid;

@property(nonatomic, copy) NSString *nickname;

@property(nonatomic, copy) NSString *password;

@property(nonatomic, copy) NSString *phone;

@property(nonatomic, copy) NSString *verifyCode;

@property(nonatomic, copy) NSString *imToken;

@property(nonatomic, copy) NSString *vodToken;

@end
