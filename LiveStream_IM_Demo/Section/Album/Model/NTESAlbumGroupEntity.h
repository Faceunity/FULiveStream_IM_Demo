//
//  NTESAlbumGroupEntity.h
//  NTESUpadateUI
//
//  Created by Netease on 17/2/23.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESAlbumVideoEntity.h"

@interface NTESAlbumGroupEntity : NSObject

@property (nonatomic, copy) NSString *dateStr;

@property (nonatomic, strong) NSMutableArray <NTESAlbumVideoEntity *> *items;

@end

