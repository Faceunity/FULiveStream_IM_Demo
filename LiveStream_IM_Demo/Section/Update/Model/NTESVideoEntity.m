//
//  NTESVideoEntity.m
//  NTESUpadateUI
//
//  Created by Netease on 17/2/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESVideoEntity.h"

@implementation NTESVideoEntity

- (void)copyFromItem:(NTESVideoEntity *)item
{
    if (!item) {
        return;
    }
    
    _state = item.state;
    
    if (!_title && item.title) {
        _title = item.title;
    }
    
    if (!_extension && item.extension) {
        _extension = item.extension;
    }
    
    _duration = item.duration;
    _assetKey = item.assetKey;
    _fileSize = item.fileSize;
    
    if (!_thumbImg && item.thumbImg) {
        _thumbImg = item.thumbImg;
    }
    
    if (!_fileRelPath && item.fileRelPath) {
        _fileRelPath = item.fileRelPath;
    }
    
    _updateProcess = item.updateProcess;

    _vid = item.vid;
    _thumbImgUrl = item.thumbImgUrl;
    _origUrl = item.origUrl;
    _shdMp4Url = item.shdMp4Url;
    _shdMp4Size = item.shdMp4Size;
    _hdFlvUrl = item.hdFlvUrl;
    _hdFlvSize = item.hdFlvSize;
    _sdHlsUrl = item.sdHlsUrl;
    _sdHlsSize = item.sdHlsSize;
    
    if (!_nosBucket && item.nosBucket) {
        _nosBucket = item.nosBucket;
    }
    
    if (!_nosObject && item.nosObject) {
        _nosObject = item.nosObject;
    }
    
    if (!_nosToken && item.nosToken) {
        _nosToken = item.nosToken;
    }
}

- (instancetype)initWithAlbumVideo:(NTESAlbumVideoEntity *)albumItem
{
    NTESVideoEntity *entity = [[NTESVideoEntity alloc] init];
    
    //名称
    entity.title = [albumItem.title stringByDeletingPathExtension];
    entity.extension = [albumItem.title pathExtension];
    
    //文件大小
    entity.fileSize = albumItem.size / (1024.0 * 1024.0);
    
    //缩略图
    entity.thumbImg = albumItem.thumbImg;
    
    //时长
    entity.duration = albumItem.duration;
    
    //assetKey
    entity.assetKey = albumItem.assetKey;
    
    return entity;
}

+ (NTESVideoEntity *)entityWithFileName:(NSString *)name extension:(NSString *)extension relPath:(NSString *)fileRelPath
{
    NTESVideoEntity *entity = [[NTESVideoEntity alloc] init];
    
    //名称和路径
    entity.title = name;
    entity.extension = extension;
    entity.fileRelPath = fileRelPath;
    
    
    //文件大小
    NSString *path = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:fileRelPath];
    long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    entity.fileSize = fileSize / (1024.0 * 1024.0);
    
    //缩略图
    entity.thumbImg = [UIImage imageWithVideoPath:path];
    
    //时长
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset * asset = [AVURLAsset assetWithURL:url];
    CMTime time = [asset duration];
    entity.duration = ceil(time.value/time.timescale);
    
    return entity;
}


#pragma mark - <NSCoding>
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.state forKey:@"state"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.extension forKey:@"extension"];
    [aCoder encodeDouble:self.duration forKey:@"duration"];
    
    [aCoder encodeObject:self.assetKey forKey:@"assetKey"];
    [aCoder encodeDouble:self.fileSize forKey:@"fileSize"];
    [aCoder encodeObject:self.thumbImg forKey:@"thumbImg"];
    [aCoder encodeObject:self.fileRelPath forKey:@"fileRelPath"];
    [aCoder encodeDouble:self.updateProcess forKey:@"updateProcess"];
    
    [aCoder encodeObject:self.vid forKey:@"vids"];
    [aCoder encodeObject:self.thumbImgUrl forKey:@"thumbImgUrl"];
    [aCoder encodeObject:self.origUrl forKey:@"origUrl"];
    [aCoder encodeObject:self.shdMp4Url forKey:@"shdMp4Url"];
    [aCoder encodeDouble:self.shdMp4Size forKey:@"shdMp4Size"];
    [aCoder encodeObject:self.hdFlvUrl forKey:@"hdFlvUrl"];
    [aCoder encodeDouble:self.hdFlvSize forKey:@"hdFlvSize"];
    [aCoder encodeObject:self.sdHlsUrl forKey:@"sdHlsUrl"];
    [aCoder encodeDouble:self.sdHlsSize forKey:@"sdHlsSize"];
    
    [aCoder encodeInteger:self.updatePhase forKey:@"updatePhase"];
    [aCoder encodeObject:self.nosBucket forKey:@"nosBucket"];
    [aCoder encodeObject:self.nosObject forKey:@"nosObject"];
    [aCoder encodeObject:self.nosToken forKey:@"nosToken"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self.state = [aDecoder decodeIntegerForKey:@"state"];
    self.title = [aDecoder decodeObjectForKey:@"title"];
    self.extension = [aDecoder decodeObjectForKey:@"extension"];
    self.duration = [aDecoder decodeDoubleForKey:@"duration"];
    
    self.assetKey = [aDecoder decodeObjectForKey:@"assetKey"];
    self.fileSize = [aDecoder decodeDoubleForKey:@"fileSize"];
    self.thumbImg = [aDecoder decodeObjectForKey:@"thumbImg"];
    self.fileRelPath = [aDecoder decodeObjectForKey:@"fileRelPath"];
    self.updateProcess = [aDecoder decodeDoubleForKey:@"updateProcess"];
    
    self.vid = [aDecoder decodeObjectForKey:@"vid"];
    self.thumbImgUrl = [aDecoder decodeObjectForKey:@"thumbImgUrl"];
    self.origUrl = [aDecoder decodeObjectForKey:@"origUrl"];
    self.shdMp4Url = [aDecoder decodeObjectForKey:@"shdMp4Url"];
    self.shdMp4Size = [aDecoder decodeDoubleForKey:@"shdMp4Size"];
    self.hdFlvUrl = [aDecoder decodeObjectForKey:@"hdFlvUrl"];
    self.hdFlvSize = [aDecoder decodeDoubleForKey:@"hdFlvSize"];
    self.sdHlsUrl = [aDecoder decodeObjectForKey:@"sdHlsUrl"];
    self.sdHlsSize = [aDecoder decodeDoubleForKey:@"sdHlsSize"];
    
    self.updatePhase = [aDecoder decodeIntegerForKey:@"updatePhase"];
    self.nosBucket = [aDecoder decodeObjectForKey:@"nosBucket"];
    self.nosObject = [aDecoder decodeObjectForKey:@"nosObject"];
    self.nosToken = [aDecoder decodeObjectForKey:@"nosToken"];
    
    return self;
}
@end
