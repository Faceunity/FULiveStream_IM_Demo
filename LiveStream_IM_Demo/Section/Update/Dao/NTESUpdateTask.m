//
//  NTESUpdateTask.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/8.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateTask.h"
#import "NTESDaoUpdateModel.h"

@implementation NTESUpdateTask
- (NSURLRequest *)taskRequest {return NULL;}
- (void)onGetResponse:(id)jsonObject error:(NSError *)error {}
@end

#pragma mark -
@implementation NTESVideoAddTask
- (NSURLRequest *)taskRequest
{
    NSString *urlString = [[[NTESDemoConfig sharedConfig] apiURL] stringByAppendingString:@"/vod/videoadd"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:30];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *sid = [NTESLoginManager sharedManager].currentNTESLoginData.accid;
    NSString *postData = [NSString stringWithFormat:@"sid=%@&vid=%@&name=%@&type=%zi",sid, _vid, _name, _type];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error
{
    NSError *resultError = error;
    NSInteger transjobstatus = 0;
    NSInteger videoCount = 0;
    NTESVideoEntity *entity = nil;
    
    if (error == nil && [jsonObject isKindOfClass:[NSDictionary class]])
    {
        NTESAddVideoModel *response = [NTESAddVideoModel yy_modelWithDictionary:jsonObject];
        
        if ([response.code integerValue] != 200)
        {
            resultError = [NSError errorWithDomain:@"ntes.demo.dao.update.add"
                                              code:[response.code integerValue]
                                          userInfo:@{NTES_ERROR_MSG_KEY: (response.msg ?: @"")}];
        }
        else
        {
            transjobstatus = [response.data.transjobstatus integerValue];
            videoCount = [response.data.videoCount integerValue];
            
            entity = [NTESVideoEntity new];
            entity.vid = [NSString stringWithFormat:@"%@", response.data.videoinfo.vid];
            entity.title = [response.data.videoinfo.videoName stringByDeletingPathExtension];
            entity.extension = [response.data.videoinfo.videoName pathExtension];
            entity.duration = [response.data.videoinfo.duration integerValue];
            entity.fileSize = [response.data.videoinfo.initialSize floatValue] / (1024.0 * 1024.0);
            entity.thumbImgUrl = response.data.videoinfo.snapshotUrl;
            entity.origUrl = response.data.videoinfo.origUrl;
            
            switch ([response.data.videoinfo.status integerValue]) {
                case 20: //转码失败
                    entity.state = NTESVideoItemTransCodeFail;
                    break;
                case 40: //完成
                    entity.state = NTESVideoItemComplete;
                    break;
                case 10:
                case 30:
                    entity.state = NTESVideoItemTransCoding;
                    break;
                default:
                    break;
            }
        }
    }
    
    if (_handler) {
        _handler (resultError, transjobstatus, videoCount, entity);
    }
}
@end

#pragma mark -
@implementation NTESVideoDelTask
- (NSURLRequest *)taskRequest
{
    NSString *urlString = [[[NTESDemoConfig sharedConfig] apiURL] stringByAppendingString:@"/vod/videodelete"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:30];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *sid = [NTESLoginManager sharedManager].currentNTESLoginData.accid;
    NSMutableString *postData = [NSMutableString stringWithFormat:@"sid=%@&vid=%@", sid, _vid];
    if (_format)
    {
        [postData appendString:[NSString stringWithFormat:@"&format=%@", _format]];
    }
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error
{
    NSError *resultError = error;

    if (error == nil && [jsonObject isKindOfClass:[NSDictionary class]])
    {
        NTESDaoModel *response = [NTESDaoModel yy_modelWithDictionary:jsonObject];
        
        if ([response.code integerValue] != 200)
        {
            resultError = [NSError errorWithDomain:@"ntes.demo.dao.update.query"
                                              code:[response.code integerValue]
                                          userInfo:@{NTES_ERROR_MSG_KEY: (response.msg ?: @"")}];
        }
    }
    
    if (_handler) {
        _handler(resultError);
    }
}

@end

#pragma mark -
@implementation NTESVideoQueryTask
- (NSURLRequest *)taskRequest
{
    NSString *urlString = [[[NTESDemoConfig sharedConfig] apiURL] stringByAppendingString:@"/vod/videoinfoget/"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:30];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *sid = [NTESLoginManager sharedManager].currentNTESLoginData.accid;
    NSMutableString *postData = [NSMutableString stringWithFormat:@"sid=%@", sid];
    if (!(_vid.length == 0))
    {
        [postData appendString:[NSString stringWithFormat:@"&vid=%@", _vid]];
    }
    else
    {
        [postData appendString:[NSString stringWithFormat:@"&type=%zi", _type]];
    }
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error
{
    NSError *resultError = error;
    NSMutableArray *infos = [NSMutableArray array];

    if (error == nil && [jsonObject isKindOfClass:[NSDictionary class]])
    {
        NTESVideoQueryModel *response = [NTESVideoQueryModel yy_modelWithDictionary:jsonObject];
        
        if ([response.code integerValue] != 200)
        {
            resultError = [NSError errorWithDomain:@"ntes.demo.dao.update.query"
                                              code:[response.code integerValue]
                                          userInfo:@{NTES_ERROR_MSG_KEY: (response.msg ?: @"")}];
        }
        else
        {
            for (NTESVideoInfo *info in response.data.list) {
                NTESVideoEntity *entity = [NTESVideoEntity new];
                if (info.vid) {
                    entity.vid = [NSString stringWithFormat:@"%@", info.vid];
                }
                entity.title = [info.videoName stringByDeletingPathExtension];
                entity.extension = [info.videoName pathExtension];
                entity.duration = [info.duration integerValue];
                entity.fileSize = [info.initialSize floatValue] / (1024.0 * 1024.0);
                entity.thumbImgUrl = info.snapshotUrl;
                entity.origUrl = info.origUrl;
                entity.shdMp4Url = info.shdMp4Url;
                entity.shdMp4Size = [info.shdMp4Size floatValue] / (1024.0 * 1024.0);
                entity.hdFlvUrl = info.hdFlvUrl;
                entity.hdFlvSize = [info.hdFlvSize floatValue] / (1024.0 * 1024.0);
                entity.sdHlsUrl = info.sdHlsUrl;
                entity.sdHlsSize = [info.sdHlsSize floatValue] / (1024.0 * 1024.0);
                
                switch ([info.status integerValue]) {
                    case 20: //转码失败
                        entity.state = NTESVideoItemTransCodeFail;
                        break;
                    case 40: //完成
                        entity.state = NTESVideoItemComplete;
                        break;
                    case 10:
                    case 30:
                        entity.state = NTESVideoItemTransCoding;
                        break;
                    default:
                        break;
                }
                [infos addObject:entity];
            }
        }
    }
    
    if (_handler) {
        _handler(resultError, infos);
    }
}
@end

#pragma mark -
@implementation NTESVideoStateTask
- (NSURLRequest *)taskRequest
{
    NSString *urlString = [[[NTESDemoConfig sharedConfig] apiURL] stringByAppendingString:@"/vod/videotranscodestatus"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:30];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *sid = [NTESLoginManager sharedManager].currentNTESLoginData.accid;
    NSMutableString *postData = [NSMutableString stringWithFormat:@"sid=%@", sid];

    [_vids enumerateObjectsUsingBlock:^(NSString *vid, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == 0)
        {
            [postData appendString:@"&vids="];
        }
        
        [postData appendString:[NSString stringWithFormat:@"%@", vid]];
        
        if (idx != _vids.count - 1)
        {
            [postData appendString:@","];
        }
    }];
    
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error
{
    NSError *resultError = error;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (error == nil && [jsonObject isKindOfClass:[NSDictionary class]])
    {
        NTESVideoStateModel *response = [NTESVideoStateModel yy_modelWithDictionary:jsonObject];
        
        if ([response.code integerValue] != 200)
        {
            resultError = [NSError errorWithDomain:@"ntes.demo.dao.update.query"
                                              code:[response.code integerValue]
                                          userInfo:@{NTES_ERROR_MSG_KEY: (response.msg ?: @"")}];
        }
        else
        {
            for (NTESVideoState *state in response.data.list) {
                dic[state.vid] = state.transcodestatus;
            }
        }
    }
    
    if (_handler) {
        _handler(resultError, dic);
    }
}

@end
