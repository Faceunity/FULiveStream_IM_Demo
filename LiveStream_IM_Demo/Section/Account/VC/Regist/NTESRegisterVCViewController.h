//
//  NTESRegisterVCViewController.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/30.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseVC.h"

typedef void(^NTESRegisterCompleteBlock)(NSString *userName, NSString *password);

@interface NTESRegisterVCViewController : NTESBaseVC

@property(nonatomic, copy) NTESRegisterCompleteBlock completeBlock;

@end
