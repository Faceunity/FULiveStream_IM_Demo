//
//  NTESUpdateDelegate.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/12.
//  Copyright © 2017年 Netease. All rights reserved.
//  采用静态变量管理代理，保证代理对象一直存在，防止代理对象提前释放导致上传参数不对的问题。

#import <Foundation/Foundation.h>

@interface NTESUpdateDelegate : NSObject <NOSUploadRequestDelegate>

+ (instancetype)shareInstance;

@end
