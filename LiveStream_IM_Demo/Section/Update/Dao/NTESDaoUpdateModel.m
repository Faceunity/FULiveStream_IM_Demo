//
//  NTESDaoUpdateModel.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDaoUpdateModel.h"

@implementation NTESDaoUpdateModel
@end

#pragma mark - 增加视频
@implementation NTESAddVideoInfo
@end
@implementation NTESAddVideoModel
@end

#pragma mark - 查询视频信息
@implementation NTESVideoInfo
@end
@implementation NTESVideoQueryInfo
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [NTESVideoInfo class]};
}
@end
@implementation NTESVideoQueryModel
@end

#pragma mark - 查询视频转码状态
@implementation NTESVideoState
@end
@implementation NTESVideoStateInfo
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [NTESVideoState class]};
}
@end
@implementation NTESVideoStateModel
@end
