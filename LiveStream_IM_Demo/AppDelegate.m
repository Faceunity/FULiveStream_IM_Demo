//
//  AppDelegate.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 16/12/23.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "AppDelegate.h"
#import "NTESRootNavVC.h"
#import "NTESLoginVC.h"
#import "NTESAttachDecoder.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    //appkey是应用的标识，不同应用之间的数据（用户、消息、群组等）是完全隔离的。
    //如需打网易云信Demo包，请勿修改appkey，开发自己的应用时，请替换为自己的appkey.
    //并请对应更换Demo代码中的获取好友列表、个人信息等网易云信SDK未提供的接口。
    NSString *appKey = [[NTESDemoConfig sharedConfig] appKey];
    NSString *cerName= [[NTESDemoConfig sharedConfig] cerName];
    [[NIMSDK sharedSDK] registerWithAppID:appKey
                                  cerName:cerName];
    [NIMCustomObject registerCustomDecoder:[NTESAttachDecoder new]];
    
    [self setupMainViewController];
    
    //权限
    [NTESAuthorizationHelper requestAblumAuthorityWithCompletionHandler:nil];
    [NTESAuthorizationHelper requestMediaCapturerAccessWithHandler:nil];
    
    //hud
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setMaximumDismissTimeInterval:1.0];
    
    //net
    [RealReachability sharedInstance].autoCheckInterval = 1.0;
    [[RealReachability sharedInstance] startNotifier];
    
    //cache
    [NTESSandboxHelper clearRecordVideoPath];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupMainViewController
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    NTESRootNavVC *nav = [[NTESRootNavVC alloc] initWithRootViewController:[NTESLoginVC new]];
    self.window.rootViewController = nav;
}

@end
