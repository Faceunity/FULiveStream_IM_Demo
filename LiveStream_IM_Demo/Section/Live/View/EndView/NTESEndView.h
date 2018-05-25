//
//  NTESEndView.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/9.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NTESEndViewProtocol;

@interface NTESEndView : UIView

@property (nonatomic, weak) id <NTESEndViewProtocol> delegate;

- (void)configEndView:(NSString *)avatarImage
                 name:(NSString *)name
              message:(NSString *)message
           hiddenBack:(BOOL)hiddenBack;

@end

@protocol NTESEndViewProtocol <NSObject>

- (void)endViewCloseAction:(NTESEndView *)endView;

@end
