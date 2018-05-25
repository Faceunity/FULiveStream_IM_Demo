//
//  NTESDaoTaskProtocol.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NTESResponseHandler)(NSError *error);

@protocol NTESDaoTaskProtocol <NSObject>

- (NSMutableURLRequest *)taskRequest;

- (void)onGetResponse:(id)jsonObject
                error:(NSError *)error;

@end
