//
//  main.m
//  LSMediaCaptureDemo
//
//  Created by NetEase on 15/8/14.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        signal(SIGPIPE, SIG_IGN);
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
