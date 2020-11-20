//
//  NELoginViewController.m
//  LSMediaCaptureDemo
//
//  Created by emily on 16/10/20.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NELoginViewController.h"
#import "NESelectViewTableViewCell.h"
#import "NEInputTableViewCell.h"
#import "NESettingTableViewCell.h"
#import "MediaCaptureViewController.h"
#import "NELivePlayerQRScanViewController.h"
#import "NEMediaCaptureEntity.h"
#import "UIAlertView+NE.h"
#import "NEInternalMacro.h"

@interface NELoginViewController () <UITextViewDelegate, UITextFieldDelegate, NELivePlayerQRScanViewControllerDelegate> {
    LSVideoParaCtxConfiguration* paraCtx;
    LSMediaCapture *lsMedia;
}
@property(nonatomic, strong) UIView *toolBar;
@property(nonatomic, strong) UIButton *rightBtn;
@property(nonatomic, strong) UIButton *leftBtn;
@property(nonatomic, strong) UIButton *enterBtn;
@property(nonatomic, strong) UIButton *startSpeed;
@property(nonatomic, strong) UIButton *stopSpeed;

@property(nonatomic, strong) UIView *headerView;
@property(nonatomic, strong) UILabel *headerLabel;
@property(nonatomic, strong) UISwitch *aSwitch;
@property(nonatomic, copy) NSString *urlText;
@end

#define kToolBarHeight 150

@implementation NELoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    self.title = @"网易视频云";
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.frame = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight - kToolBarHeight);
    self.rightBtn = ({
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_qr_scan"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(rightBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];

    [self initData];
    [self addToolBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.toolBar.hidden = NO;
    paraCtx = [NEMediaCaptureEntity sharedInstance].videoParaCtx;
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)registerCells {
    NSArray *array = @[[NEInputTableViewCell cellIdentifier],
                       [NESelectViewTableViewCell cellIdentifier],
                       [NESettingTableViewCell cellIdentifier]];
    
    [array enumerateObjectsUsingBlock:^(NSString *cellIdetifer, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.tableView registerClass:NSClassFromString(cellIdetifer) forCellReuseIdentifier:cellIdetifer];
    }];
}

- (void)initData {
    //default params
    //默认高清 以后可根据网络状况比如wifi或4G或3G来建议用户选择不同质量
    paraCtx = [LSVideoParaCtxConfiguration defaultVideoConfiguration:LSVideoParamQuality_Super];
    [NEMediaCaptureEntity sharedInstance].encodeType = 2;//默认使用硬件编码
    [self reloadData];
    
    NSTimeInterval timeinterval = [[NSDate date] timeIntervalSince1970];
    
    NSLog(@"timeinterval = %f",timeinterval);
    
    
    /*
     推流地址
     拉流地址(HTTP)

     */
    self.urlText = @"请在后台复制填写";
    
}

- (void)addToolBar {

    self.enterBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"开始直播" forState:UIControlStateNormal];
        btn.frame = CGRectMake(self.view.frame.size.width/8, 5, self.view.frame.size.width*3/4, 40);
        [btn setBackgroundImage:[UIImage imageNamed:@"ic_start_play"] forState:UIControlStateNormal];
        btn.titleLabel.textColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [btn addTarget:self action:@selector(enterBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    self.toolBar = ({
        UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, UIScreenHeight - kToolBarHeight, UIScreenWidth, kToolBarHeight)];
//        [toolBar setBarStyle:UIBarStyleDefault];
        toolBar;
    });
    
    self.startSpeed = ({
        UIButton *startSpeed = [UIButton buttonWithType:UIButtonTypeCustom];
        startSpeed.frame = CGRectMake(self.view.frame.size.width/8, 60, self.view.frame.size.width*3/4, 40);
        [startSpeed setTitle:@"开始测速" forState:UIControlStateNormal];
        [startSpeed setBackgroundImage:[UIImage imageNamed:@"ic_start_play"] forState:UIControlStateNormal];
        startSpeed.titleLabel.textColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [startSpeed addTarget:self action:@selector(startSpeed:) forControlEvents:UIControlEventTouchUpInside];
        
        startSpeed;
    });
    
    self.stopSpeed = ({
        UIButton *stopSpeed = [UIButton buttonWithType:UIButtonTypeCustom];
        stopSpeed.frame = CGRectMake(self.view.frame.size.width/8, 110, self.view.frame.size.width*3/4, 40);
        [stopSpeed setTitle:@"结束测速" forState:UIControlStateNormal];
        [stopSpeed setBackgroundImage:[UIImage imageNamed:@"ic_start_play"] forState:UIControlStateNormal];
        stopSpeed.titleLabel.textColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [stopSpeed addTarget:self action:@selector(stopSpeed:) forControlEvents:UIControlEventTouchUpInside];
        
        stopSpeed;
    });

    [self.toolBar addSubview:self.enterBtn];
    [self.toolBar addSubview:self.startSpeed];
    [self.toolBar addSubview:self.stopSpeed];

    [self.view addSubview:self.toolBar];
}

- (void)startSpeed:(id)sender
{
    if (lsMedia == nil) {
        lsMedia = [[LSMediaCapture alloc] init];
    }
    //如果是499k，一次测速 ，可以不设置，sdk默认就是如此
    //测速之前设置测速次数和上传数据大小500k（默认可以不设）：接口android之后会统一
//    [lsMedia setSpeedCacl:1 Capacity:499*1024];

    
    if ([self.urlText length] > 0 && [self.urlText hasPrefix:@"rtmp://"]) {
        [lsMedia startSpeedCalc:self.urlText success:^(NSMutableArray *array) {
            NSLog(@"\n success!!! \n");
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"测速结果" message:[NSString  stringWithFormat:@"%@",array] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert showAlertWithCompletionHandler:^(NSInteger i) {}];
            });
        } fail:^{
            NSLog(@"failed");
        }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"推流地址不正确" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert showAlertWithCompletionHandler:^(NSInteger i) {
            if (i == 0) {
                NSLog(@"推流地址不正确");
            }
        }];
    }
}

- (void)stopSpeed:(id)sender
{
    if (lsMedia == nil) {
        lsMedia = [[LSMediaCapture alloc] init];
    }
    [lsMedia stopSpeedCalc];
}

#pragma mark - Table View data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 11;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:case 1:case 2:case 3:case 4:case 6:case 7:
            return 1;
            break;
        case 5:case 8:case 9:case 10:
        {
            return 0;
        }
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

#pragma mark - Table View delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 110;
    }
    else if (indexPath.section == 5 || indexPath.section == 8 || indexPath.section == 9 || indexPath.section == 10)
        return 0;
    else return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NERootTableViewCell *cell = nil;
    NSInteger section = indexPath.section;
    //NSInteger row = indexPath.row;
    switch (section) {
        case 0:
        {
            NEInputTableViewCell *cell1 = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NEInputTableViewCell class])];
            cell1.inputTextView.delegate = self;
            cell = cell1;
        }
            break;
        case 1:
        {
            NESettingTableViewCell *cell1 = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NESettingTableViewCell class])];
            cell1.textLabel.text = @"帧率";
            cell1.inputTF.placeholder = @"默认15";
            cell1.inputTF.delegate = self;
            cell = cell1;
        }
            break;
        case 2:
        {
            NESelectViewTableViewCell *cell1 = [NESelectViewTableViewCell dequeueReuseableCellForTabelView:tableView];
            [cell1.button1 setTitle:@"超清" forState:UIControlStateNormal];
            [cell1.button2 setTitle:@"高清" forState:UIControlStateNormal];
            [cell1.button3 setTitle:@"标清" forState:UIControlStateNormal];
            [cell1.button4 setTitle:@"流畅" forState:UIControlStateNormal];
            [@[cell1.button1, cell1.button2, cell1.button3, cell1.button4] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
                btn.selected = NO;
            }];
            [@[cell1.button1, cell1.button2, cell1.button3, cell1.button4] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
                [btn addTarget:self action:@selector(qualityBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
            }];
            NSInteger quality = [NEMediaCaptureEntity sharedInstance].videoParaCtx.videoStreamingQuality;
            switch (quality) {
                case 3:
                {
                    cell1.button1.selected = YES;
                    
                }
                    break;
                case 2:
                {
                    cell1.button2.selected = YES;
                }
                    break;
                case 1:
                {
                    cell1.button3.selected = YES;
                }
                    break;
                case 0:
                {
                    cell1.button4.selected = YES;
                }
                    break;
                default:
                    break;
            }
            cell = cell1;
        }
            
            break;
        case 3:
        {
            NESelectViewTableViewCell *cell1 = [NESelectViewTableViewCell dequeueReuseableCellForTabelView:tableView];
            [cell1.button1 setTitle:@"宽屏" forState:UIControlStateNormal];
            [cell1.button3 setTitle:@"非宽屏" forState:UIControlStateNormal];
            [@[cell1.button1, cell1.button2, cell1.button3, cell1.button4] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
                btn.selected = NO;
            }];
            [@[cell1.button1, cell1.button3] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
                [btn addTarget:self action:@selector(scaleSelectBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
            }];
            NSInteger scaletype = [NEMediaCaptureEntity sharedInstance].videoParaCtx.videoRenderMode;
            switch (scaletype) {
                case 1://宽屏
                    cell1.button1.selected = YES;
                    cell1.button3.selected = NO;
                    break;
                case 0://其他
                    cell1.button1.selected = NO;
                    cell1.button3.selected = YES;
                    break;
                default:
                    break;
            }
            cell1.button2.hidden = YES;
            cell1.button4.hidden = YES;
            cell = cell1;
        }
            break;
        case 4:
        {
            NESelectViewTableViewCell *cell1 = [NESelectViewTableViewCell dequeueReuseableCellForTabelView:tableView];
            [cell1.button1 setTitle:@"软编码" forState:UIControlStateNormal];
            [cell1.button3 setTitle:@"硬编码" forState:UIControlStateNormal];
            [@[cell1.button1, cell1.button2, cell1.button3, cell1.button4] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
                btn.selected = NO;
            }];
            [@[cell1.button1, cell1.button3] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
                [btn addTarget:self action:@selector(encodeSelectBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
            }];
            cell1.button2.hidden = YES;
            cell1.button4.hidden = YES;

            NSInteger encodeType = [NEMediaCaptureEntity sharedInstance].encodeType;
            switch (encodeType) {
                case 0:
                    cell1.button1.selected = YES;
                    cell1.button3.selected = NO;
                    break;
                case 2:
                    cell1.button1.selected = NO;
                    cell1.button3.selected = YES;
                    break;
                default:
                    break;
            }
            cell = cell1;
        }
            break;

        case 6:
        {
            NESelectViewTableViewCell *cell1 = [NESelectViewTableViewCell dequeueReuseableCellForTabelView:tableView];
            [cell1.button1 setTitle:@"黑白" forState:UIControlStateNormal];
            [cell1.button2 setTitle:@"自然" forState:UIControlStateNormal];
            [cell1.button3 setTitle:@"粉嫩" forState:UIControlStateNormal];
            [cell1.button4 setTitle:@"怀旧" forState:UIControlStateNormal];
            [@[cell1.button1, cell1.button2, cell1.button3, cell1.button4] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
                btn.selected = NO;
            }];
            [@[cell1.button1, cell1.button2, cell1.button3, cell1.button4] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
                [btn addTarget:self action:@selector(filterSelectBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
            }];
            NSUInteger filterType = [NEMediaCaptureEntity sharedInstance].videoParaCtx.filterType;
            switch (filterType) {
                case 1:
                    cell1.button1.selected = YES;
                    break;
                case 2:
                    cell1.button2.selected = YES;
                    break;
                case 3:
                    cell1.button3.selected = YES;
                    break;
                case 4:
                    cell1.button4.selected = YES;
                    break;
                default:
                    break;
            }
            cell = cell1;
        }
            break;
        case 7:
        {
            NESelectViewTableViewCell *cell1 = [NESelectViewTableViewCell dequeueReuseableCellForTabelView:tableView];
            [cell1.button1 setTitle:@"portrait" forState:UIControlStateNormal];
            [cell1.button2 setTitle:@"updown" forState:UIControlStateNormal];
            [cell1.button3 setTitle:@"right" forState:UIControlStateNormal];
            [cell1.button4 setTitle:@"left" forState:UIControlStateNormal];
            [@[cell1.button1, cell1.button2, cell1.button3, cell1.button4] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
                btn.selected = NO;
            }];
            [@[cell1.button1, cell1.button2, cell1.button3, cell1.button4] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
                [btn addTarget:self action:@selector(orientationChanged:) forControlEvents:UIControlEventTouchUpInside];
            }];
            NSUInteger orientType = [NEMediaCaptureEntity sharedInstance].videoParaCtx.interfaceOrientation;
            switch (orientType) {
                case 0:
                    cell1.button1.selected = YES;
                    break;
                case 1:
                    cell1.button2.selected = YES;
                    break;
                case 2:
                    cell1.button3.selected = YES;
                    break;
                case 3:
                    cell1.button4.selected = YES;
                    break;
                default:
                    break;
            }
            cell = cell1;
        }
            break;
        default:
            break;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    self.headerView.backgroundColor = [UIColor colorWithRed:0.808 green:0.851 blue:0.906 alpha:1.00];
    self.headerLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, _headerView.frame.size.width, 20)];
        label.font = FONT(16.f);
        label;
    });
    [self.headerView addSubview:self.headerLabel];
    self.aSwitch = ({
        UISwitch *switch1 = [[UISwitch alloc] initWithFrame:CGRectMake(self.headerView.frame.size.width - 70, 5, 60, 30)];
        switch1;
    });
    switch (section) {
        case 0:
            self.headerLabel.text = @"键入直播地址";
            break;
        case 1:
            self.headerLabel.text = @"参数设置";
            break;
        case 2:
            self.headerLabel.text = @"清晰度选择";
            break;
        case 3:
            self.headerLabel.text = @"屏幕宽度选择";
            break;
        case 4:
            self.headerLabel.text = @"编码方式选择";
            break;
        case 5:
            self.headerLabel.text = @"开启变焦功能";
            [self.headerView addSubview:self.aSwitch];
            self.aSwitch.on = paraCtx.isCameraZoomPinchGestureOn;
            [self.aSwitch addTarget:self action:@selector(zoomSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            [self.headerView addSubview:self.aSwitch];
            break;
        case 6:
        {
            self.headerLabel.text = @"使用滤镜";
            [self.headerView addSubview:self.aSwitch];
            if (paraCtx.isVideoFilterOn) {
                self.aSwitch.on = YES;
            }
            self.aSwitch.tag = section;
            [self.aSwitch addTarget:self action:@selector(filterSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case 7:
            self.headerLabel.text = @"视频采集方向选择";
            break;
        case 8:
            self.headerLabel.text = @"添加水印";
            [self.headerView addSubview:self.aSwitch];
            self.aSwitch.on = paraCtx.isVideoWaterMarkEnabled;
            [self.aSwitch addTarget:self action:@selector(addWaterMark:) forControlEvents:UIControlEventValueChanged];
            [self.headerView addSubview:self.aSwitch];
            break;
        case 9:
        {
            self.headerLabel.text = @"开启Qos功能";
            [self.headerView addSubview:self.aSwitch];
            self.aSwitch.on = paraCtx.isQosOn;
            [self.aSwitch addTarget:self action:@selector(qosFunctionChanged:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case 10:
            self.headerLabel.text = @"默认使用镜像前置摄像头";
            [self.headerView addSubview:self.aSwitch];
            self.aSwitch.on = paraCtx.isFrontCameraMirroredPreView;
            [self.aSwitch addTarget:self action:@selector(cameraMirroredChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        default:
            break;
    }
    return self.headerView;
}

- (void)reloadData {
    [NEMediaCaptureEntity sharedInstance].videoParaCtx = paraCtx;
}

#pragma mark - textView delegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.urlText = textView.text;
}

#pragma mark - Buttons and Switch methods

-(void)rightBtnTapped:(UIButton *)sender {
    NELivePlayerQRScanViewController *scanVC = [NELivePlayerQRScanViewController new];
    scanVC.delegate = self;
    scanVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:scanVC animated:YES completion:nil];
}

//- (void)leftBtnTapped:(UIButton *)sender {
//    NELogFileViewController *vc = [NELogFileViewController new];
//    [self.navigationController pushViewController:vc animated:YES];
//}

- (void)enterBtnTapped:(UIButton *)sender {
    
    NSLog(@"urlText = %@",self.urlText);
    
    if ([self.urlText isEqualToString:@""] || (self.urlText == nil)) {
       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                           message:@"请键入直播地址"
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
        [alertView show];
        return;
    }
    else {
        if (paraCtx.fps == 0) {
            paraCtx.fps = 15;
        }else if (paraCtx.fps < 10 || paraCtx.fps > 24) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                                message:@"帧率，建议在10~24之间"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
            [alertView show];
            return;
        }
        [self reloadData];
        
        MediaCaptureViewController *mediaCaptureVC = [[MediaCaptureViewController alloc] initWithUrl:self.urlText sLSctx:[NEMediaCaptureEntity sharedInstance].videoParaCtx];
        mediaCaptureVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:mediaCaptureVC animated:YES completion:nil];
    }
}

#pragma mark -每一次对paraCtx的操作都直接保存，防止进入二维码页面，再次回到该页面时viewWillAppear，paraCtx为原来的值
- (void)zoomSwitchChanged:(UISwitch *)sender {
    paraCtx.isCameraZoomPinchGestureOn = sender.isOn;
    [self reloadData];
}

- (void)filterSwitchChanged:(UISwitch *)sender {
    if (sender.isOn) {
        paraCtx.isVideoFilterOn = YES;
    }
    else {
        paraCtx.isVideoFilterOn = NO;
    }
    [self reloadData];
}

- (void)addWaterMark:(UISwitch *)sender {
    paraCtx.isVideoWaterMarkEnabled = sender.isOn;
    [self reloadData];
}

-(void)qosFunctionChanged:(UISwitch *)sender {
    paraCtx.isQosOn = sender.isOn;
    [self reloadData];
}

- (void)cameraMirroredChanged:(UISwitch *)sender {
    paraCtx.isFrontCameraMirroredPreView = sender.isOn;
    [self reloadData];
}


- (void)qualityBtnTapped:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            paraCtx.bitrate = SQBITRATE;
            paraCtx.videoStreamingQuality = LS_VIDEO_QUALITY_SUPER;
            break;
        case 2:
            paraCtx.bitrate = HQBITRATE;
            paraCtx.videoStreamingQuality = LS_VIDEO_QUALITY_HIGH;
            break;
        case 3:
            paraCtx.bitrate = MQBITRATE;
            paraCtx.videoStreamingQuality = LS_VIDEO_QUALITY_MEDIUM;
            break;
        case 4:
            paraCtx.bitrate = LQBITRATE;
            paraCtx.videoStreamingQuality = LS_VIDEO_QUALITY_LOW;
            break;
        default:
            break;
    }
    [self reloadData];
}

- (void)scaleSelectBtnTapped:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            paraCtx.videoRenderMode = LS_VIDEO_RENDER_MODE_SCALE_16x9;
            break;
        case 3:
            paraCtx.videoRenderMode = LS_VIDEO_RENDER_MODE_SCALE_NONE;
        default:
            break;
    }
    [self reloadData];
}

- (void)encodeSelectBtnTapped:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            [NEMediaCaptureEntity sharedInstance].encodeType = 0;
            break;
        case 3:
            [NEMediaCaptureEntity sharedInstance].encodeType = 2;
            break;
        default:
            break;
    }
}

- (void)filterSelectBtnTapped:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            paraCtx.filterType = LS_GPUIMAGE_SEPIA;
            break;
        case 2:
            paraCtx.filterType = LS_GPUIMAGE_ZIRAN;
            break;
        case 3:
            paraCtx.filterType = LS_GPUIMAGE_MEIYAN1;
            break;
        case 4:
            paraCtx.filterType = LS_GPUIMAGE_MEIYAN2;
            break;
        default:
            break;
    }
    [self reloadData];
}

- (void)orientationChanged:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            paraCtx.interfaceOrientation = LS_CAMERA_ORIENTATION_PORTRAIT;
            break;
        case 2:
            paraCtx.interfaceOrientation = LS_CAMERA_ORIENTATION_UPDOWN;
            break;
        case 3:
            paraCtx.interfaceOrientation = LS_CAMERA_ORIENTATION_RIGHT;
            break;
        case 4:
            paraCtx.interfaceOrientation = LS_CAMERA_ORIENTATION_LEFT;
            break;
        default:
            break;
    }
    [self reloadData];
}

#pragma mark - textField delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    paraCtx.fps = [textField.text intValue];
    if (textField.text == nil || [textField.text isEqualToString:@""]) {
        paraCtx.fps = 15;
    }
    [self reloadData];
}

#pragma mark - NELivePlayerQRScanViewControllerDelegate

- (void)NELivePlayerQRScanDidFinishScanner:(NSString *)string {
    self.urlText = string;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NEInputTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.inputTextView.text = string;
    [self.tableView reloadData];
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
