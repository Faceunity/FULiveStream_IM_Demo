//
//  NTESDaoService.m
//  NIM
//
//  Created by amao on 1/20/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NTESDaoService.h"

@implementation NTESDaoService
+ (instancetype)sharedService
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}


#pragma mark - 网络请求
- (void)runTask:(id<NTESDaoTaskProtocol>)task
{
    NSMutableURLRequest *request = [task taskRequest];
    [request setTimeoutInterval:30.0];
    [request addValue:@"video-live" forHTTPHeaderField:@"Demo-Id"];

    NSURLSessionTask *sessionTask =
    [[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                        
                                        NSError *resultError = error;
                                        id jsonObject = nil;
                                        if (error == nil)
                                        {
                                            if ([response isKindOfClass:[NSHTTPURLResponse class]] &&
                                                [(NSHTTPURLResponse *)response statusCode] == 200 &&
                                                data)
                                            {
                                                jsonObject =[NSJSONSerialization JSONObjectWithData:data
                                                                                            options:0
                                                                                              error:&resultError];
                                            }
                                            else
                                            {
                                                NSString *msg = [NSString stringWithFormat:@"%@",response];
                                                resultError =  [NSError errorWithDomain:@"ntes domain"
                                                                                   code:-1
                                                                               userInfo:@{NTES_ERROR_MSG_KEY : msg}];
                                            }
                                        }
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [task onGetResponse:jsonObject
                                                          error:resultError];

                                        });
                                    }];
    [sessionTask resume];
}
@end
