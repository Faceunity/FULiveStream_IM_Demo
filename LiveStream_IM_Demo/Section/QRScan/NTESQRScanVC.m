//
//  NTESQRScanVC.m
//  NELivePlayerDemo
//
//  Created by NetEase on 16/10/10.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NTESQRScanVC.h"
#import <AVFoundation/AVFoundation.h>

@interface NTESQRScanVC () <AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) UIImageView *scanMask;
@property (nonatomic, assign) BOOL isStop;

@property (nonatomic, assign) CGSize  screenSize;
@property (nonatomic, assign) CGFloat scanFrameW;
@property (nonatomic, assign) CGFloat scanFrameH;
@property (nonatomic, assign) CGFloat scanFrameX;
@property (nonatomic, assign) CGFloat scanFrameY;



@end

@implementation NTESQRScanVC

- (void)dealloc
{
    NSLog(@"QR 释放了");
}

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

    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    // 设置扫描框
    _screenSize = [[UIScreen mainScreen] bounds].size;
    _scanFrameW = _screenSize.width - 80;
    _scanFrameH = _screenSize.width - 80;
    _scanFrameX = (_screenSize.width - _scanFrameW) / 2;
    _scanFrameY = (_screenSize.height - _scanFrameH) / 2;
    CGRect scanFrame = CGRectMake(_scanFrameX, _scanFrameY, _scanFrameW, _scanFrameH);
    
    //申请权限
    __weak typeof(self) weakSelf = self;
    [NTESAuthorizationHelper requestMediaCapturerAccessWithHandler:^(NSError *error) {
    
        if (!error)
        {
            if ([weakSelf.session canAddInput:weakSelf.input]) {
                [weakSelf.session addInput:weakSelf.input];
            }
            if ([weakSelf.session canAddOutput:weakSelf.output]) {
                [weakSelf.session addOutput:weakSelf.output];
            }
            
            weakSelf.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                                    AVMetadataObjectTypeEAN13Code,
                                                    AVMetadataObjectTypeEAN8Code,
                                                    AVMetadataObjectTypeCode128Code];
            
            // 设置扫描区域
            CGRect ScanInterest = CGRectMake(scanFrame.origin.y / weakSelf.screenSize.height,
                                             scanFrame.origin.x / weakSelf.screenSize.width,
                                             weakSelf.scanFrameH / weakSelf.screenSize.height,
                                             weakSelf.scanFrameW / weakSelf.screenSize.width);
            weakSelf.output.rectOfInterest = ScanInterest;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注意"
                                                                    message:@"请开启相机权限"
                                                                   delegate:nil cancelButtonTitle:@"确定"
                                                          otherButtonTitles: nil];
                [alertView showAlertWithCompletionHandler:^(NSInteger index) {
                    [weakSelf dissmissQRScan];
                }];
            });
        }
    }];
    
    
    //扫描框周围颜色设置
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenSize.width, scanFrame.origin.y)];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, scanFrame.origin.y, scanFrame.origin.x, _scanFrameH)];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(scanFrame), scanFrame.origin.y, CGRectGetWidth(leftView.frame), _scanFrameH)];
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(leftView.frame), _screenSize.width, CGRectGetHeight(topView.frame))];
    
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
    UIImageView *scanMask = [[UIImageView alloc] initWithFrame:CGRectMake((_screenSize.width - _scanFrameW) / 2,
                                                                          scanFrame.origin.y,
                                                                          _scanFrameW,
                                                                          _scanFrameW)];
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
    [back setImage:[UIImage imageNamed:@"btn_player_quit"] forState:UIControlStateNormal];
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
    self.scanMask.alpha = 0.25;
    [UIView animateWithDuration:1.5 animations:^{
        self.scanMask.transform = CGAffineTransformTranslate(_scanMask.transform, 0, _scanMask.frame.size.height);
        self.scanMask.alpha = 1.0;
    } completion:^(BOOL finished) {
        
        if (finished)
        {
            self.scanMask.alpha = 0.0;
            self.scanMask.frame = CGRectMake(_scanMask.frame.origin.x,
                                             -(_scanMask.frame.size.height-_scanMask.frame.origin.y),
                                             _scanMask.frame.size.width,
                                             _scanMask.frame.size.height);
            
            // 在底部稍微停留一点时间，再继续
            [self performSelector:@selector(startMaskAnimation) withObject:nil afterDelay:0.5];
        }

    }];
}

- (void)stopMaskAnimation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self.scanMask.layer removeAllAnimations];
}

- (void)dissmissQRScan
{
    [self stopMaskAnimation];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
        if ([viewControllers objectAtIndex:viewControllers.count-1] == self) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)onClickback
{
    [self dissmissQRScan];
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

@end
