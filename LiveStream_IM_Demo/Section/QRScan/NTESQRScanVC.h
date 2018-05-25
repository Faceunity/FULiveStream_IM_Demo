//
//  NTESQRScanVC.h
//  NELivePlayerDemo
//
//  Created by NetEase on 16/10/10.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NTESQRScanVCDelegate <NSObject>

- (void)NELivePlayerQRScanDidFinishScanner:(NSString *)string;

@end


@interface NTESQRScanVC : UIViewController

@property (nonatomic, weak) id<NTESQRScanVCDelegate> delegate;

@end
