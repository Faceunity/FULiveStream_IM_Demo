//
//  NTESMicAttachment.h
//  NIMLiveDemo
//
//  Created by chris on 16/7/25.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTESMicConnectedAttachment : NSObject<NIMCustomAttachment>

@property (nonatomic, assign) NIMNetCallType type;

@property (nonatomic, copy)   NSString *connectorId;

@property (nonatomic, copy)   NSString *nick;

@property (nonatomic, copy)   NSString *avatar;

@end



@interface NTESDisConnectedAttachment : NSObject<NIMCustomAttachment>

@property (nonatomic, copy)   NSString *connectorId;

@end

