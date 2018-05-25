//
//  NTESPresentMessage.h
//  NIMLiveDemo
//
//  Created by chris on 16/3/29.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESMember.h"
#import "NTESPresent.h"

@interface NTESPresentMessage : NSObject

@property (nonatomic, strong) NTESPresent *present;

@property (nonatomic, strong) NTESMember *sender;

- (NTESPresentMessage *)initWithNIMPresentMessage:(NIMMessage *)message;

@end
