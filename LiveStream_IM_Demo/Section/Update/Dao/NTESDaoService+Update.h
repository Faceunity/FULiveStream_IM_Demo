//
//  NTESDaoService+Update.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDaoService.h"
#import "NTESUpdateTask.h"

@interface NTESDaoService (Update)

- (void)requestAddVideoWithName:(NSString *)name
                            vid:(NSString *)vid
                           type:(NSInteger)type
                     completion:(NTESVideoAddHandler)completion;

- (void)requestDelVideoWithVid:(NSString *)vid
                        format:(NSString *)format
                    completion:(NTESResponseHandler)completion;

- (void)requestQueryVideoInfoWithType:(NSInteger)type
                            completion:(NTESVideoQueryHandler)completion;

- (void)requestQueryVideoInfoWithVid:(NSString *)vid
                          completion:(NTESVideoQueryHandler)completion;

- (void)requestVideoStateWithVids:(NSArray *)vids
                       completion:(NTESVideoStateHandler)completion;

@end
