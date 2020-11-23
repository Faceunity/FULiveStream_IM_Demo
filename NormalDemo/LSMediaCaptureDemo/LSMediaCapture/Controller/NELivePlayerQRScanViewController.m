//
//  NELivePlayerQRScanViewController.m
//  NELivePlayerDemo
//
//  Created by NetEase on 16/10/10.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NELivePlayerQRScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface NELivePlayerQRScanViewController () <AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, strong) UIImageView *scanMask;
@property (nonatomic, assign) BOOL isStop;
@end

@implementation NELivePlayerQRScanViewController {
    CGSize  screenSize;
    CGFloat scanFrameW;
    CGFloat scanFrameH;
    CGFloat scanFrameX;
    CGFloat scanFrameY;
}

#pragma clang diagnostic ignored "-Wimplicit-retain-self"

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.clipsToBounds = YES;
    [self.navigationController setNavigationBarHidden:YES];
    self.isStop = NO;
    [self startMaskAnimation];

    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:input]) {
        [_session addInput:input];
    }
    if ([_session canAddOutput:output]) {
        [_session addOutput:output];
    }
    
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    // 设置扫描框
    screenSize = [[UIScreen mainScreen] bounds].size;
    scanFrameW = screenSize.width - 80;
    scanFrameH = screenSize.width - 80;
    scanFrameX = (screenSize.width - scanFrameW) / 2;
    scanFrameY = (screenSize.height - scanFrameH) / 2;
    
    CGRect scanFrame = CGRectMake(scanFrameX, scanFrameY, scanFrameW, scanFrameH);
    CGRect ScanInterest = CGRectMake(scanFrame.origin.y / screenSize.height, scanFrame.origin.x / screenSize.width, scanFrameH / screenSize.height, scanFrameW / screenSize.width);
    output.rectOfInterest = ScanInterest;
    
    //扫描框周围颜色设置
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, scanFrame.origin.y)];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, scanFrame.origin.y, scanFrame.origin.x, scanFrameH)];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(scanFrame), scanFrame.origin.y, CGRectGetWidth(leftView.frame), scanFrameH)];
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(leftView.frame), screenSize.width, CGRectGetHeight(topView.frame))];
    
    topView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    bottomView.backgroundColor = topView.backgroundColor;
    leftView.backgroundColor = topView.backgroundColor;
    rightView.backgroundColor = topView.backgroundColor;
    
    [self.view addSubview:topView];
    [self.view addSubview:leftView];
    [self.view addSubview:rightView];
    [self.view addSubview:bottomView];
    
    //取景框
    CGFloat edgeLength = 17;
    //左上角
    UIImageView *topLeft = [[UIImageView alloc] initWithFrame:CGRectMake(scanFrame.origin.x, scanFrame.origin.y, edgeLength, edgeLength)];
    topLeft.image = [UIImage imageNamed:@"app_scan_corner_top_left"];
    //右上角
    UIImageView *topRight = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(scanFrame) - edgeLength, scanFrame.origin.y, edgeLength, edgeLength)];
    topRight.image = [UIImage imageNamed:@"app_scan_corner_top_right"];
    //左下角
    UIImageView *bottomLeft = [[UIImageView alloc] initWithFrame:CGRectMake(scanFrame.origin.x, CGRectGetMaxY(scanFrame) - edgeLength, edgeLength, edgeLength)];
    bottomLeft.image = [UIImage imageNamed:@"app_scan_corner_bottom_left"];
    //右下角
    UIImageView *bottomRight = [[UIImageView alloc] initWithFrame:CGRectMake(topRight.frame.origin.x, bottomLeft.frame.origin.y, edgeLength, edgeLength)];
    bottomRight.image = [UIImage imageNamed:@"app_scan_corner_bottom_right"];
    
    [self.view addSubview:topLeft];
    [self.view addSubview:topRight];
    [self.view addSubview:bottomLeft];
    [self.view addSubview:bottomRight];
    
    //扫描掩模
    CGFloat scanMaskWidth = scanFrameW;
    CGFloat scanMaskHeight = scanFrameW;
    UIImageView *scanMask = [[UIImageView alloc] initWithFrame:CGRectMake((screenSize.width - scanMaskWidth) / 2, scanFrame.origin.y, scanMaskWidth, scanMaskHeight)];
    scanMask.image = [UIImage imageNamed:@"scan_net"];
    self.scanMask = scanMask;
    [self.view addSubview:scanMask];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    [_session startRunning];
    
    //返回
    CGFloat backImageViewWidth = 25;
    CGFloat backImageViewY = 30;
    UIButton *back = [[UIButton alloc] init];
    back.frame = CGRectMake(scanFrame.origin.x/2, backImageViewY, backImageViewWidth, backImageViewWidth);
    [back setBackgroundImage:[UIImage imageNamed:@"btn_player_quit"] forState:UIControlStateNormal];
    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(onClickback) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startMaskAnimation
{
    if (self.isStop) {
        return;
    }
    self.scanMask.alpha = 0.25;
    [UIView animateWithDuration:1.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _scanMask.transform = CGAffineTransformTranslate(_scanMask.transform, 0, _scanMask.frame.size.height);
                         self.scanMask.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                        self.scanMask.alpha = 0.0;
                         _scanMask.frame = CGRectMake(_scanMask.frame.origin.x, -(_scanMask.frame.size.height-_scanMask.frame.origin.y), _scanMask.frame.size.width, _scanMask.frame.size.height);
                         // 在底部稍微停留一点时间，再继续
                         [UIView animateWithDuration:0.5 animations:^{
                         } completion:^(BOOL finished) {
                            [self startMaskAnimation];
                         }];
                     }];
}

- (void)onClickback {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
        if ([viewControllers objectAtIndex:viewControllers.count-1] == self) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    self.isStop = YES;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSString *strValue;
    NSArray *viewControllers = self.navigationController.viewControllers;
    if ([metadataObjects count] > 0) {
        //停止扫描
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject *object = [metadataObjects objectAtIndex:0];
        strValue = object.stringValue;
        //通知代理
        if ([self.delegate respondsToSelector:@selector(NELivePlayerQRScanDidFinishScanner:)]) {
            if (viewControllers.count > 1) {
                if ([viewControllers objectAtIndex:viewControllers.count-1] == self) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            [self.delegate NELivePlayerQRScanDidFinishScanner:strValue];
            self.isStop = YES;
        }
    }
}

#pragma mark - 画面旋转
-(BOOL)shouldAutorotate
{
    return NO;
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
