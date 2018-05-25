//
//  NTESMuteView.h
//  NEUIDemo
//
//  Created by Netease on 17/1/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESMember.h"

@protocol  NTESMuteViewProtocol;

@interface NTESMuteView : UIControl

@property (nonatomic, weak) id <NTESMuteViewProtocol> delegate;

- (void)showWithUserInfo:(NTESMember *) userInfo;

- (void)dismiss;

@end

@protocol  NTESMuteViewProtocol <NSObject>

- (void)muteView:(NTESMuteView *)muteView kick:(NTESMember *)userInfo;

- (void)muteView:(NTESMuteView *)muteView mute:(NTESMember *)userInfo;

@end
