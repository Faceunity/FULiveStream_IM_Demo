//
//  NTESAccountTask.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESDaoTaskProtocol.h"
@class NTESAccount;

@interface NTESAccountTask : NSObject <NTESDaoTaskProtocol>
@end

@interface NTESLoginTask : NTESAccountTask
@property (nonatomic,strong)    NTESAccount          *data;
@property (nonatomic,copy)      NTESResponseHandler   handler;
@end

@interface NTESLoginWithPhoneTask : NTESAccountTask
@property(nonatomic, strong) NTESAccount *data;
@property(nonatomic, copy) NTESResponseHandler handler;
@end

@interface NTESLogoutTask : NTESAccountTask
@property (nonatomic,strong)    NTESAccount          *data;
@property (nonatomic,copy)      NTESResponseHandler   handler;
@end


@interface NTESRegisterTask : NTESAccountTask
@property (nonatomic,strong)    NTESAccount          *data;
@property (nonatomic,copy)      NTESResponseHandler   handler;
@end

@interface NTESGetRegVerifyCodeTask : NTESAccountTask
@property(nonatomic, copy) NSString *phoneNum;
@property(nonatomic, copy) NTESResponseHandler handler;
@end

@interface NTESGetLogVerifyCodeTask : NTESAccountTask
@property(nonatomic, copy) NSString *phoneNum;
@property(nonatomic, copy) NTESResponseHandler handler;
@end
