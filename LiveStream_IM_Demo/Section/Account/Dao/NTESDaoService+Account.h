//
//  NTESDaoService+Account.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDaoService.h"
@class NTESAccount;

@interface NTESDaoService (Account)

- (void)registerUser:(NTESAccount *)data
          completion:(NTESResponseHandler)completion;

- (void)loginUser:(NTESAccount *)data
       completion:(NTESResponseHandler)completion;

- (void)logoutUser:(NTESAccount *)data
        completion:(NTESResponseHandler)completion;

- (void)getRegVerifyCode:(NSString *)phone
           completion:(NTESResponseHandler)completion;

- (void)getLogVerifyCode:(NSString *)phone
              completion:(NTESResponseHandler)completion;

- (void)loginUserWithPhone:(NTESAccount *)data
                completion:(NTESResponseHandler)completion;

@end
