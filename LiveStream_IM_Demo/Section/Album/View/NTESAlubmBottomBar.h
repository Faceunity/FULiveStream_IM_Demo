//
//  NTESAlubmBottomBar.h
//  NTESUpadateUI
//
//  Created by Netease on 17/2/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NTESAlbumBottomBarProtocol;

@interface NTESAlubmBottomBar : UIView

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) NSInteger maxCount;

@property (nonatomic, weak) id <NTESAlbumBottomBarProtocol> delegate;

@end

@protocol NTESAlbumBottomBarProtocol <NSObject>

//底部确认事件
- (void)BottomBarSureAction:(NTESAlubmBottomBar *)bar;

@end
