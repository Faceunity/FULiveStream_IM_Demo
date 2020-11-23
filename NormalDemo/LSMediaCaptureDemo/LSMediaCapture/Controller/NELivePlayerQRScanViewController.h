//
//  NELivePlayerQRScanViewController.h
//  NELivePlayerDemo
//
//  Created by NetEase on 16/10/10.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NELivePlayerQRScanViewControllerDelegate <NSObject>
- (void)NELivePlayerQRScanDidFinishScanner:(NSString *)string;
@end


@interface NELivePlayerQRScanViewController : UIViewController
@property (nonatomic, weak) id<NELivePlayerQRScanViewControllerDelegate> delegate;
@end
