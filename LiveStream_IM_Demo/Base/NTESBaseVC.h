//
//  NTESBaseVC.h
//  NEUIDemo
//
//  Created by Netease on 16/12/30.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTESBaseVC : UIViewController

@property (nonatomic, copy) NSString *leftBtnImage;
@property (nonatomic, copy) NSString *leftBtnTitle;
@property (nonatomic, copy) NSString *rightBtnImage;
@property (nonatomic, copy) NSString *rightBtnTitle;
@property(nonatomic, strong) UIColor *leftBtnTitleColor;
@property(nonatomic, strong) UIColor *rightBtnTitleColor;


@property (nonatomic, assign) BOOL hiddenRightBtn;
@property (nonatomic, assign) BOOL hiddenLeftBtn;

//是否显示NavigationBar
- (BOOL)isNaviBarVisible;
//是否显示statusBar
- (BOOL)isStatusBarVisible;

- (void)configNavigationBar;

#pragma mark - 子类重载
- (void)doKeyboardChangedWithTransition:(YYKeyboardTransition)transition; //键盘事件

- (void)doRightNavBarRightBtnAction; //导航栏右键事件

- (void)doAccountBeKicked; //账号被踢事件

@end
