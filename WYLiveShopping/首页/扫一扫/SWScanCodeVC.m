//
//  SWScanCodeVC.m
//  demo
//
//  Created by gaofu on 2017/4/10.
//  Copyright © 2017年 siruijk. All rights reserved.
//

#import "SWScanCodeVC.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+Extend.h"
#import "SWLivebroadViewController.h"

const static CGFloat animationTime = 2.5f;//扫描时长

@interface SWScanCodeVC ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,strong) AVCaptureMetadataOutput *captureMetadataOutput;
@property (nonatomic,strong) CAShapeLayer *scanPaneBgLayer;

@end

@implementation SWScanCodeVC
{
    UIImageView *_scanPane;//扫描框
    UILabel *_contentLabel;
    NSLayoutConstraint *_boxLayoutConstraint;
    UIActivityIndicatorView *_loaddingIndicatorView;
    UIImageView *_scanLine;//扫描线
}


#pragma mark -
#pragma mark  Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initScanCode];
    [self initScanLine];
    
    [self addButton];
}
- (void)addButton{
    UIButton *_returnBtn = [UIButton buttonWithType:0];
    _returnBtn.frame = CGRectMake(0, 24+statusbarHeight, 40, 40);
//    _returnBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [_returnBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
    [_returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_returnBtn];
    UIButton *dengBtn = [UIButton buttonWithType:0];
    [dengBtn addTarget:self action:@selector(lightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    dengBtn.frame = CGRectMake(_window_width/3-21, _window_height-60, 42, 50);
    [dengBtn setImage:[UIImage imageNamed:@"scancode_light"] forState:0];
    [dengBtn setImage:[UIImage imageNamed:@"scancode_light_select"] forState:UIControlStateSelected];
    [self.view addSubview:dengBtn];
    
    UIButton *photoBtn = [UIButton buttonWithType:0];
    [photoBtn addTarget:self action:@selector(photoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    photoBtn.frame = CGRectMake(_window_width/3*2-21, _window_height-60, 42, 50);
    [photoBtn setImage:[UIImage imageNamed:@"scancode_pic"] forState:0];
    [self.view addSubview:photoBtn];

}
- (void)doReturn{
    [self.captureSession stopRunning];
    _captureMetadataOutput = nil;
    _captureSession = nil;
    [_captureVideoPreviewLayer removeFromSuperlayer];
    _captureVideoPreviewLayer = nil;
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startScan];
}

-(CAShapeLayer *)scanPaneBgLayer
{
    
    if (!_scanPaneBgLayer)
    {
        _scanPaneBgLayer = [CAShapeLayer layer];
    }
    return _scanPaneBgLayer;
}

#pragma mark -
#pragma mark  Interface Components

//扫描线
-(void)initScanLine
{
    _scanPane = [UIImageView new];
    _scanPane.frame = CGRectMake(_window_width*0.2, _window_height/2-_window_width*0.3, _window_width*0.6, _window_width*0.6);
    _scanPane.image = [UIImage imageNamed:@"scancode_box"];
    [self.view addSubview:_scanPane];
    _scanLine = [UIImageView new];
    _scanLine.image = [UIImage imageNamed:@"scancode_line"];
    [_scanPane addSubview:_scanLine];
    
    [self setScanReact:YES];
    [self.view.layer insertSublayer:self.scanPaneBgLayer above:self.captureVideoPreviewLayer];
}

//绘制扫描框背景
- (void)setScanReact:(BOOL)loading
{
    
    CGRect scanRect = _scanPane.frame;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:scanRect];
    [path appendPath:[UIBezierPath bezierPathWithRect:self.view.bounds]];
    
    [self.scanPaneBgLayer setFillRule:kCAFillRuleEvenOdd];
    [self.scanPaneBgLayer setPath:path.CGPath];
    [self.scanPaneBgLayer setFillColor:[UIColor colorWithWhite:0 alpha:loading ? 1 : 0.6].CGColor];
}


#pragma mark -
#pragma mark  Target Action Methods

//开灯按钮
- (void)lightBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self turnTorchOn:sender.selected];
}

//打开相册
- (void)photoBtnAction:(UIButton *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = true;
    [self presentViewController:picker animated:true completion:nil];
}

#pragma mark -
#pragma mark  DataRequest


#pragma mark -
#pragma mark  Private Methods

//初始化扫描二维码
-(void)initScanCode
{
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error)
    {
        [self showMessage:@"摄像头不可用" title:@"温馨提示" andler:nil];
        return;
    }
    
    if ([device lockForConfiguration:nil])
    {
        //自动白平衡
        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
        {
            [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        //自动对焦
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        {
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动曝光
        if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        {
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [device unlockForConfiguration];
    }
    self.captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    [self.self.captureSession canAddInput:input] ? [self.captureSession addInput:input] : nil;
    [self.captureSession canAddOutput:self.captureMetadataOutput] ? [self.captureSession addOutput:self.captureMetadataOutput] : nil;
    
    [self.captureMetadataOutput setMetadataObjectTypes:@[
                                                         AVMetadataObjectTypeQRCode,
                                                         AVMetadataObjectTypeCode39Code,
                                                         AVMetadataObjectTypeCode128Code,
                                                         AVMetadataObjectTypeCode39Mod43Code,
                                                         AVMetadataObjectTypeEAN13Code,
                                                         AVMetadataObjectTypeEAN8Code,
                                                         AVMetadataObjectTypeCode93Code
                                                         ]];
    
    self.captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:self.captureVideoPreviewLayer atIndex:0];
    
    [self loadScan];
}

//启动扫描
-(void)loadScan
{
    [_loaddingIndicatorView startAnimating ];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession startRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_loaddingIndicatorView stopAnimating];
            [UIView animateWithDuration:0.25 animations:^{
                _contentLabel.alpha = 1;
                _boxLayoutConstraint.constant = [UIScreen mainScreen].bounds.size.width*0.6;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                _scanLine.frame = CGRectMake(0 , 0, [UIScreen mainScreen].bounds.size.width*0.6, 3);
                [_scanLine.layer addAnimation:[self moveAnimation] forKey:nil];
                [self setScanReact:NO];
            }];
            self.captureMetadataOutput.rectOfInterest = [self.captureVideoPreviewLayer metadataOutputRectOfInterestForRect:_scanPane.frame];
        });
    });
}

//开始扫描
- (void)startScan
{
    [_scanLine.layer addAnimation:[self moveAnimation] forKey:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession startRunning];
    });
}

//停止扫描
- (void)stopScan
{
    
    [_scanLine.layer removeAllAnimations];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.captureSession.isRunning )
        {
            [self.captureSession stopRunning];
        }
    });
}

//扫描动画
-(CABasicAnimation*)moveAnimation
{
    CGPoint starPoint = CGPointMake(_scanLine .center.x  , 1);
    CGPoint endPoint = CGPointMake(_scanLine.center.x, _scanPane.bounds.size.height - 2);
    
    CABasicAnimation*translation = [CABasicAnimation animationWithKeyPath:@"position"];
    translation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    translation.fromValue = [NSValue valueWithCGPoint:starPoint];
    translation.toValue = [NSValue valueWithCGPoint:endPoint];
    translation.duration = animationTime;
    translation.repeatCount = CGFLOAT_MAX;
    translation.autoreverses = YES;
    
    return translation;
}

//散光灯
- (void)turnTorchOn: (BOOL)on
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    
    if (captureDeviceClass != nil)
    {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([device hasTorch] && [device hasFlash])
        {
            [device lockForConfiguration:nil];
            if (on && device.torchMode == AVCaptureTorchModeOff)
            {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
            }
            if (!on && device.torchMode == AVCaptureTorchModeOn)
            {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

//扫描结果处理
-(void)dealwithResult:(NSString*)result
{
//    [self playScanCodeSound];
    if ([result isEqual:@"未识别!"]) {
        [MBProgressHUD showError:result];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopScan];
        [MBProgressHUD showMessage:@""];
        [SWToolClass postNetworkWithUrl:@"livekey" andParameter:@{@"key":result} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                [MBProgressHUD hideHUD];
                if (code == 200) {
                    SWLivebroadViewController *vc = [[SWLivebroadViewController alloc]init];
                    vc.keyString = result;
                    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
                }else{
                   
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showAlert:msg];
                    });
                }

        } fail:^{
            [MBProgressHUD hideHUD];
        }];
    });

}
- (void)showAlert:(NSString *)msg{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doReturn];
    }];
    [alertContro addAction:cancleAction];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"重新扫描" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startScan];
    }];
    [sureAction setValue:normalColors forKey:@"_titleTextColor"];
    [alertContro addAction:sureAction];
    [self presentViewController:alertContro animated:YES completion:nil];

}
//播放提示音
- (void)playScanCodeSound
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"scancode.caf" ofType:nil];
    
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&soundID);
    AudioServicesPlayAlertSound(soundID);
}

-(void)showMessage:(NSString*)message title:(NSString*)title andler:(void (^)(UIAlertAction *action))handler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:handler];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
    
}


#pragma mark -
#pragma mark  AVCaptureMetadataOutputObjects Delegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self stopScan];
    
    //扫完完成
    if (metadataObjects.count > 0)
    {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSString *result = obj.stringValue;
        [self dealwithResult:result];
    }
}


#pragma mark -
#pragma mark  UIImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image)
    {
        image = info[UIImagePickerControllerOriginalImage];
    }
    [_loaddingIndicatorView startAnimating];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        NSString *scanResult = [image scanCodeContent];
        
        [_loaddingIndicatorView stopAnimating];
        
        [self dealwithResult:scanResult];
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:true completion:nil];
}


#pragma mark -
#pragma mark  Dealloc

-(void)dealloc
{
    [self.captureSession stopRunning];
    _captureMetadataOutput = nil;
    _captureSession = nil;
    [_captureVideoPreviewLayer removeFromSuperlayer];
    _captureVideoPreviewLayer = nil;
}

@end
