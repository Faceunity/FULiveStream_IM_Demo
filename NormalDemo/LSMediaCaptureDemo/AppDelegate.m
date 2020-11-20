//
//  AppDelegate.m
//  LSMediaCaptureDemo
//
//  Created by NetEase on 15/8/14.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "AppDelegate.h"

#import "NELoginViewController.h"
#import "NEReachability.h"
#import "NENavigationController.h"



@interface AppDelegate ()
@property(nonatomic, strong) NEReachability *reachability;
@end

@implementation AppDelegate

-(void)configuration{
    _reachability = [NEReachability ne_reachabilityForInternetConnection];
    [_reachability ne_startNotifier];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configuration];
    [self registerDefaultsFromSettingsBundle];


    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //FIX ME:
    self.window.backgroundColor = [UIColor blackColor];

    NELoginViewController *rootVC = [[NELoginViewController alloc] init];
    NENavigationController* nav = [[NENavigationController alloc]initWithRootViewController:rootVC];

    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];    
    
    return YES;
}

- (void)registerDefaultsFromSettingsBundle {
    [[NSUserDefaults standardUserDefaults] registerDefaults:[self defaultsFromPlistNamed:@"Root"]];
}

- (NSDictionary *)defaultsFromPlistNamed:(NSString *)plistName {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if (settingsBundle == nil) {
        NSLog(@"Could not find Settings.bundle while loading defaults.");
    }
    
    NSString *plistFullName = [NSString stringWithFormat:@"%@.plist", plistName];
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:plistFullName]];
    if (settings == nil) {
        NSLog(@"Could not load plist '%@' while loading defaults.", plistFullName);
    }
    
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    if (preferences == nil) {
        NSLog(@"Could not find preferences entry in plist '%@' while loading defaults.", plistFullName);
    }
    
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        id value = [prefSpecification objectForKey:@"DefaultValue"];
        if(key && value) {
            [defaults setObject:value forKey:key];
        }
        
        NSString *type = [prefSpecification objectForKey:@"Type"];
        if ([type isEqualToString:@"PSChildPaneSpecifier"]) {
            NSString *file = [prefSpecification objectForKey:@"File"];
            if (file == nil) {
                NSLog(@"Unable to get child plist name from plist '%@'", plistFullName);
            }
            [defaults addEntriesFromDictionary:[self defaultsFromPlistNamed:file]];
        }
    }
    
    return defaults;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

@end
