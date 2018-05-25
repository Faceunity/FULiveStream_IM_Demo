//
//  NTESAvatarCell.h
//  NEUIDemo
//
//  Created by Netease on 17/1/5.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTESAvatarCell : UICollectionViewCell

@property (nonatomic, copy) NSString *avatarUrl;

@property (nonatomic, assign) BOOL mute;

@property (nonatomic, copy) NSString *nickName;

- (void)configCell:(NSString *)avatarUrl nickName:(NSString *)nickName isMute:(BOOL)isMute;

@end
