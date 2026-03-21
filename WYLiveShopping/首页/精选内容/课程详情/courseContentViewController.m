//
//  courseContentViewController.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/13.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "courseContentViewController.h"
#import "WMPlayer.h"
#import "audioPlayView.h"
//#import "WYScrollView.h"

@interface courseContentViewController ()<WMPlayerDelegate,audioPlayViewDelegate>{
    
    UIView *headerView;
    UIScrollView *bottomScrollView;
    audioPlayView *voiceView;
    UIButton *tryBuyButton;
    BOOL isTry;
    WKWebView *webView;
    UILabel *jianjieLabel;
    UILabel *timeLabel;
}
@property (nonatomic,strong) WMPlayer *wmPlayer;

@end

@implementation courseContentViewController
- (void)creatHeaderView{
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_width*0.56)];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];
//    if (_fromWhere == 1) {
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        [dic setObject:_model.type forKey:@"type"];
//        [dic setObject:_model.url forKey:@"url"];
//        [dic setObject:_model.name forKey:@"name"];
//        [dic setObject:_thumb forKey:@"thumb"];
//        _courseMsgDic = dic;
//    }
    if ([_model.type isEqual:@"1"] || [_model.type isEqual:@"3"]) {
        
        if ([_model.type isEqual:@"3"]) {
            UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, headerView.height)];
            [imgV sd_setImageWithURL:[NSURL URLWithString:minstr([_courseMsgDic valueForKey:@"thumb"])]];
            imgV.clipsToBounds = YES;
            imgV.userInteractionEnabled = YES;
            [headerView addSubview:imgV];

            headerView.height = _window_width*0.56 +125;
            voiceView = [[[NSBundle mainBundle] loadNibNamed:@"audioPlayView" owner:nil options:nil] lastObject];
            voiceView.frame = CGRectMake(0, imgV.bottom, _window_width, 120);
            voiceView.delegate = self;
            voiceView.courseDic = _courseMsgDic;
            [headerView addSubview:voiceView];
            [[WYToolClass sharedInstance]lineViewWithFrame:CGRectMake(0, voiceView.bottom, _window_width, 5) andColor:colorf0 andView:headerView];
        }else{
            headerView.height = 0;
        }
        [self creatBottomView];
    }else if ([_model.type isEqual:@"2"]){
        [self creatBottomView];

        //获取设备旋转方向的通知,即使关闭了自动旋转,一样可以监测到设备的旋转方向
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        //旋转屏幕通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDeviceOrientationChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil
         ];
        WMPlayerModel *model = [[WMPlayerModel alloc]init];
        
        model.videoURL = [NSURL URLWithString:_model.url];
        model.title = _model.name;
        if(self.wmPlayer==nil){
            self.wmPlayer = [[WMPlayer alloc] initPlayerModel:model];
        }
        self.wmPlayer.backBtnStyle = BackBtnStylePop;
        self.wmPlayer.loopPlay = NO;//设置是否循环播放
        self.wmPlayer.tintColor = normalColors;//改变播放器着色
        self.wmPlayer.enableBackgroundMode = YES;//开启后台播放模式
        self.wmPlayer.delegate = self;
        self.wmPlayer.topView.hidden = YES;
        [self.wmPlayer setPlayerLayerGravity:WMPlayerLayerGravityResizeAspect];
        [self.view addSubview:self.wmPlayer];
        [self.wmPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.wmPlayer.superview);
            make.top.equalTo(headerView);
            make.height.mas_equalTo(self.wmPlayer.mas_width).multipliedBy(0.56);
        }];

    }

}
- (void)creatBottomView{
    bottomScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, headerView.bottom, _window_width, _window_height-ShowDiff-(headerView.bottom))];
    [self.view addSubview:bottomScrollView];
    UILabel *titleL = [[UILabel alloc]init];
    titleL.numberOfLines = 0;
    titleL.font = [UIFont boldSystemFontOfSize:16];
    titleL.textColor = color32;
    titleL.text = _model.name;
    [bottomScrollView addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomScrollView).offset(15);
        make.top.equalTo(bottomScrollView).offset(15);
        make.width.equalTo(bottomScrollView).offset(-30);
    }];
    jianjieLabel = [[UILabel alloc]init];
    [bottomScrollView addSubview:jianjieLabel];
    jianjieLabel.textColor = color96;
    jianjieLabel.font = SYS_Font(11);
    jianjieLabel.numberOfLines = 0;
    [jianjieLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleL.mas_bottom).offset(20);
        make.left.width.equalTo(titleL);
    }];

    timeLabel = [[UILabel alloc]init];
    [bottomScrollView addSubview:timeLabel];
    timeLabel.textColor = color96;
    timeLabel.font = SYS_Font(11);
//    timeLabel.text = _model.time_date;
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(jianjieLabel.mas_bottom).offset(20);
        make.left.equalTo(titleL);
    }];
    UIView *lineV = [[UIView alloc]init];
    lineV.backgroundColor = colorf0;
    [bottomScrollView addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeLabel.mas_bottom).offset(7);
        make.left.width.equalTo(titleL);
        make.height.mas_equalTo(1);
    }];
    webView = [[WKWebView alloc]init];
    webView.scrollView.bounces = NO;
    [bottomScrollView addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineV.mas_bottom).offset(20);
        make.left.width.equalTo(bottomScrollView);
        make.height.equalTo(bottomScrollView);
    }];
//    NSURLRequest *request;
//    if (_fromWhere == 1) {
//        titleL.text = _model.name;
//        jianjieLabel.text = _model.des;
//        timeLabel.text = _model.time_date;
//
//        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/appapi/course/lesson?uid=%@&token=%@&lessonid=%@",h5url,[Config getOwnID],[Config getOwnToken],_model.lessonID]]];
//
//    }else{
//        titleL.text = minstr([_courseMsgDic valueForKey:@"name"]);
//        jianjieLabel.text = minstr([_courseMsgDic valueForKey:@"des"]);
//        timeLabel.text = minstr([_courseMsgDic valueForKey:@"add_time"]);
//        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/appapi/course/content?uid=%@&token=%@&courseid=%@",h5url,[Config getOwnID],[Config getOwnToken],minstr([_courseMsgDic valueForKey:@"id"])]]];
//
//    }
//    [webView loadRequest:request];

//    UILabel *contentLabel = [[UILabel alloc]init];
//    [bottomScrollView addSubview:contentLabel];
//    contentLabel.textColor = color32;
//    contentLabel.font = SYS_Font(13);
//    contentLabel.numberOfLines = 0;
//    contentLabel.text = @"这是补充说明内容这是补充说明内容这是补充说明内容这是补 充说明内容这是补充说明内容这是补充说明内容这是补充说明 内容这是补充说";
//    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(lineV.mas_bottom).offset(15);
//        make.left.width.equalTo(titleL);
//    }];
//    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1582889778179&di=1071c6b6ef5ad42f12e9a1af6bc5072c&imgtype=0&src=http%3A%2F%2Ft7.baidu.com%2Fit%2Fu%3D3204887199%2C3790688592%26fm%3D79%26app%3D86%26f%3DJPEG%3Fw%3D4610%26h%3D2968"]]];
//    UIImageView *imgV = [[UIImageView alloc]init];
//    imgV.image = image;
//    [bottomScrollView addSubview:imgV];
//    [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.width.equalTo(contentLabel);
//        make.top.equalTo(contentLabel.mas_bottom).offset(15);
//        make.height.equalTo(imgV.mas_width).multipliedBy(image.size.height/image.size.width);
//    }];
    [bottomScrollView layoutIfNeeded];
    bottomScrollView.contentSize = CGSizeMake(0, webView.bottom + ShowDiff + 20);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"内容详情";
    [self creatHeaderView];
    [self requestCourseDetaile];
}
- (void)requestCourseDetaile{
    [MBProgressHUD showMessage:@""];
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"lessondetail&lessonid=%@",_model.lessonID] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_model.type intValue] == 2) {
                    WMPlayerModel *model = [[WMPlayerModel alloc]init];
//                    model.videoURL = [NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
                    model.videoURL = [NSURL URLWithString:minstr([info valueForKey:@"url"])];
                    model.title = _model.name;
                    _wmPlayer.playerModel = model;
                    [_wmPlayer play];
                }
                if ([_model.type intValue] == 3) {
                    [voiceView playerReadyToPlay:minstr([info valueForKey:@"url"])];
                }
                jianjieLabel.text = minstr([info valueForKey:@"des"]);
                timeLabel.text = minstr([info valueForKey:@"add_time"]);

                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:minstr([info valueForKey:@"content_url"])]];
                [webView loadRequest:request];


            });
        }
    } Fail:^{
        [MBProgressHUD hideHUD];

    }];
}


//全屏的时候hidden底部homeIndicator
-(BOOL)prefersHomeIndicatorAutoHidden{
    return self.wmPlayer.isFullscreen;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}
-(BOOL)prefersStatusBarHidden{
    return self.wmPlayer.prefersStatusBarHidden;
}
//视图控制器实现的方法
- (BOOL)shouldAutorotate{
//    if (self.forbidRotate) {
//        return NO;
//    }
//    if (self.wmPlayer.playerModel.verticalVideo) {
//        return NO;
//    }
     return !self.wmPlayer.isLockScreen;
}
//viewController所支持的全部旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    //对于present出来的控制器，要主动的（强制的）旋转VC，让wmPlayer全屏
//    UIInterfaceOrientationLandscapeLeft或UIInterfaceOrientationLandscapeRight
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    return UIInterfaceOrientationLandscapeRight;
}
///播放器事件
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    if (wmplayer.isFullscreen) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        //刷新
//        [UIViewController attemptRotationToDeviceOrientation];
    }else{
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
///播放暂停
-(void)wmplayer:(WMPlayer *)wmplayer clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn{
    NSLog(@"clickedPlayOrPauseButton");
}
///全屏按钮
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    if (self.wmPlayer.isFullscreen) {//全屏
        //强制翻转屏幕，Home键在下边。
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }else{//非全屏
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}
///单击播放器
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap{
    [self setNeedsStatusBarAppearanceUpdate];
}
///双击播放器
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap{
    NSLog(@"didDoubleTaped");
    if (wmplayer.isLockScreen) {
        return;
    }
    [wmplayer playOrPause:[wmplayer valueForKey:@"playOrPauseBtn"]];
}
///播放状态
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidFailedPlay");
}
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{

}
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    NSLog(@"wmplayerDidFinishedPlay");
}
-(void)wmplayerGotVideoSize:(WMPlayer *)wmplayer videoSize:(CGSize )presentationSize{
    
}
//操作栏隐藏或者显示都会调用此方法
-(void)wmplayer:(WMPlayer *)wmplayer isHiddenTopAndBottomView:(BOOL)isHidden{
    [self setNeedsStatusBarAppearanceUpdate];
}
//播放进度的代理方法
-(void)wmplayerPlayTime:(WMPlayer *)wmplayer currentTime:(CGFloat)time{
//    if (isTry) {
//        if (time >= [minstr([_courseMsgDic valueForKey:@"trialval"]) intValue]) {
//            [wmplayer seekToTimeToPlay:[minstr([_courseMsgDic valueForKey:@"trialval"]) intValue]];
//            [_wmPlayer pause];
//            tryBuyButton.hidden = NO;
//        }
//    }

}

/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange:(NSNotification *)notification{
    if (self.wmPlayer.isLockScreen){
        return;
    }
//    if (self.forbidRotate) {
//        return ;
//    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
            [self toOrientation:UIInterfaceOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
            [self toOrientation:UIInterfaceOrientationLandscapeLeft];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
            [self toOrientation:UIInterfaceOrientationLandscapeRight];
        }
            break;
        default:
            break;
    }
}

//点击进入,退出全屏,或者监测到屏幕旋转去调用的方法
-(void)toOrientation:(UIInterfaceOrientation)orientation{
    if (orientation ==UIInterfaceOrientationPortrait) {
        [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.wmPlayer.superview);
            make.top.equalTo(headerView);
            make.height.mas_equalTo(self.wmPlayer.mas_width).multipliedBy(0.56);
        }];
        self.wmPlayer.isFullscreen = NO;
        self.wmPlayer.topView.hidden = YES;

    }else{
        [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.width.equalTo(self.view);
            make.height.equalTo(_wmPlayer.mas_width).multipliedBy(_window_height/_window_width);

//            if([WMPlayer IsiPhoneX]){
//                make.edges.mas_equalTo(UIEdgeInsetsMake(self.wmPlayer.playerModel.verticalVideo?14:0, 0, 0, 0));
//            }else{
//            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
//            }
        }];
        self.wmPlayer.isFullscreen = YES;
        self.wmPlayer.topView.hidden = NO;

    }
//    self.enablePanGesture = !self.wmPlayer.isFullscreen;
//    self.nextBtn.hidden = self.wmPlayer.isFullscreen;
    if (@available(iOS 11.0, *)) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
}

- (void)releaseWMPlayer{
    [self.wmPlayer pause];
    [self.wmPlayer removeFromSuperview];
    self.wmPlayer = nil;
}
- (void)dealloc{
    [self releaseWMPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"DetailViewController dealloc");
}

#pragma mark -- audioPlayViewDelegate

- (void)tryPlayOver{
    tryBuyButton.hidden = NO;
}
-(void)doReturn{
    if (self.block) {
        self.block();
    }
    [super doReturn];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
