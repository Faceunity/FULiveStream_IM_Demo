//
//  NTESAlbumHeader.h
//  ShortVideo_Demo
//
//  Created by Netease on 17/2/14.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClearBlock)();

@interface NTESAlbumHeader : UICollectionReusableView

@property (nonatomic, strong) ClearBlock clearBlock;

@property (nonatomic, copy) NSString *titleStr;

@property (nonatomic, assign) BOOL hiddenClear;

- (void)configHeader:(NSString *)title hiddenClear:(BOOL)hiddenClear clearBlock:(ClearBlock)clearBlock;

@end
