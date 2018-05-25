//
//  NTESDaoService.h
//  NIM
//
//  Created by amao on 1/20/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESDaoTaskProtocol.h"

@protocol NTESDaoTaskProtocol;

@interface NTESDaoService : NSObject

+ (instancetype)sharedService;

- (void)runTask:(id<NTESDaoTaskProtocol>)task;

@end
