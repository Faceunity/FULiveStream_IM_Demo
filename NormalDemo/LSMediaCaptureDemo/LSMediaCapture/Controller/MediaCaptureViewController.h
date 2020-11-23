//
//  MediaCaptureViewController.h
//  lsMediaCapture
//
//  Created by NetEase on 15/7/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NMCLiveStreaming/NMCLiveStreaming.h>

@interface MediaCaptureViewController : UIViewController
- (instancetype)initWithUrl:(NSString*)url sLSctx:(LSVideoParaCtxConfiguration *)sLSctx;
@end
