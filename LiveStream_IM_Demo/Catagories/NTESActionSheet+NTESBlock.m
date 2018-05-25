//
//  NTESActionSheet+NTESBlock.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/23.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESActionSheet+NTESBlock.h"
#import <objc/runtime.h>

static char kUIActionSheetBlockAddress;

@implementation NTESActionSheet (NTESBlock)

- (void)showInView: (UIView *)view completionHandler: (ActionSheetBlock)block
{
    self.delegate = self;
    objc_setAssociatedObject(self,&kUIActionSheetBlockAddress,block,OBJC_ASSOCIATION_COPY);
    
    if (view.window)
    {
        [self showInView:view];
    }
    else
    {
        [self performSelector:@selector(showInView:)
                       withObject:view
                       afterDelay:1];

    }
}

- (UITabBar *)tabbarForPresent
{
    UITabBar *bar = nil;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        UIViewController *rootViewController= [[[UIApplication sharedApplication] keyWindow] rootViewController];
        if ([rootViewController isKindOfClass:[UITabBarController class]])
        {
            bar = [(UITabBarController *)rootViewController tabBar];
        }
    }
    return bar;
}

- (void)actionSheet:(NTESActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ActionSheetBlock block = [objc_getAssociatedObject(self, &kUIActionSheetBlockAddress) copy];
    objc_setAssociatedObject(self,&kUIActionSheetBlockAddress,nil,OBJC_ASSOCIATION_COPY);
    dispatch_block_t dispatchBlock = ^(){
        if (block)
        {
            block(buttonIndex);
        }
    };
    //需要延迟的原因是actionsheet dismiss本身是个动画,如果在这种动画没完成的情况下直接调用present会导致两个切换冲突
    //这种情况在iOS5上最为明显
    dispatchBlock();
}


- (void)clearActionBlock
{
    self.delegate = nil;
    objc_setAssociatedObject(self,&kUIActionSheetBlockAddress,nil,OBJC_ASSOCIATION_COPY);
}

@end
