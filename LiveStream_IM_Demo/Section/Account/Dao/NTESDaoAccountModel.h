//
//  NTESDaoAccountModel.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDaoModel.h"

#pragma mark - 登陆网络数据模型
@interface NTESDaoLoginInfo : NSObject
@property (nonatomic, copy) NSString *accid;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *imToken;
@property (nonatomic, copy) NSString *vodToken;
@end

@interface NTESDaoAccountModel : NTESDaoModel
@property (nonatomic, strong) NTESDaoLoginInfo *data;
@end
