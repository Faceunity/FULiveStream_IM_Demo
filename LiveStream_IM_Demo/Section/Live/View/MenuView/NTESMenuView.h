//
//  NTESMenuView.h
//  NEUIDemo
//
//  Created by Netease on 17/1/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NTESMenuViewProtocol;

typedef NS_ENUM(NSInteger,NTESMenuType)
{
    NTESMenuTypeFilter, //滤镜选项
    NTESMenuTypeAudio , //伴音选项
    NTESMenuTypeShare , //分享选项
};

@interface NTESMenuView : UIControl

@property (nonatomic, weak) id <NTESMenuViewProtocol> delegate;

@property (nonatomic, assign) NSInteger selectedIndex; //选择

- (instancetype)initWithType:(NTESMenuType)type;

- (void)show;

- (void)dismiss;

@end

@protocol NTESMenuViewProtocol <NSObject>
@optional
- (void)menuView:(NTESMenuView *)menu didSelect:(NSInteger)index;

@end
