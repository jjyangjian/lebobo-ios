//
//  SWLivebroadViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/5.
//  Copyright © 2020 IOS1. All rights reserved.
//

/// 控制器声明
#import "SWLivebroadViewController.h"
/// 直播间 socket 通道
#import "SWLiveSocket.h"

/// 腾讯直播/连麦核心 SDK
#import <TXLiteAVSDK_Professional/TXLiteAVSDK.h>
#import <TXLiteAVSDK_Professional/V2TXLivePusher.h>
#import <TXLiteAVSDK_Professional/TXLiveBase.h>
#import <TXLiteAVSDK_Professional/TRTCCloud.h>

/// 三方 UI 组件
#import "V8HorizontalPickerView.h"
#import "JJShareLiveLinkView.h"



/********************  MHSDK添加 开始 ********************/
#import "MHMeiyanMenusView.h"
#import <MHBeautySDK/MHBeautyManager.h>
//#import "MHBeautyManager.h"
#import "MHBeautyParams.h"
#import <MHBeautySDK/MHSDK.h>
#import <sys/utsname.h>
//#import "MHSDK.h"

/********************  MHSDK添加 结束 ********************/
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <CWStatusBarNotification/CWStatusBarNotification.h>

/// 页面组件与业务模块
#import "SWStartLiveClassVC.h"
#import "SWUtils.h"
#import "SWChatMsgCell.h"
#import "SWUserPopupView.h"
#import "SWLiveGoodsView.h"
#import "SWMyTextView.h"
#import "SWAnchorMoreMenuView.h"
#import "SWShareView.h"
#import "SWExpensiveGiftV.h"
#import "SWContinueGift.h"
#import "SWLiveOnlineList.h"
//#import "TZImagePickerController.h"
#import "SWLinkApplyView.h"
#import "SWLinkUserView.h"

/// 腾讯滤镜类型枚举（旧逻辑保留）
typedef NS_ENUM(NSInteger,TCLVFilterType) {
    FilterType_None         = 0,
    FilterType_white        ,   //美白滤镜
    FilterType_langman         ,   //浪漫滤镜
    FilterType_qingxin         ,   //清新滤镜
    FilterType_weimei         ,   //唯美滤镜
    FilterType_fennen         ,   //粉嫩滤镜
    FilterType_huaijiu         ,   //怀旧滤镜
    FilterType_landiao         ,   //蓝调滤镜
    FilterType_qingliang     ,   //清凉滤镜
    FilterType_rixi         ,   //日系滤镜
};
@import CoreLocation;

@interface SWLivebroadViewController ()<TXVideoCustomProcessDelegate,V2TXLivePusherObserver,V8HorizontalPickerViewDelegate,V8HorizontalPickerViewDataSource,MHMeiyanMenusViewDelegate,UITextViewDelegate,CLLocationManagerDelegate,SWLiveSocketDelegate,UITableViewDelegate,UITableViewDataSource,SWUserPopupViewDeleagte,UITextFieldDelegate,haohuadelegate,TZImagePickerControllerDelegate,LiveOnlineListDelegate,LinkAncorDelegate,tx_play_linkmic>

/********************  MHSDK添加 开始 ********************/
/// 美狐美颜菜单/管理器
@property (nonatomic, strong) MHMeiyanMenusView *menusView;
@property (nonatomic, strong) MHBeautyManager *beautyManager;
/******************** MHSDK添加 结束 ********************/
/// 开播前预览层容器
@property (nonatomic,strong)UIView *previewFrontView;
//@property(nonatomic, strong) GPUImageView *gpuPreviewView;
//@property (nonatomic, strong) GPUImageStillCamera *videoCamera;
//@property (nonatomic, strong) CIImage *outputImage;
//@property (nonatomic, assign) size_t outputWidth;
//@property (nonatomic, assign) size_t outputheight;

/***********************  腾讯SDK start **********************/
/// V2 推流核心对象与编码参数
//@property TXLivePushConfig* txLivePushonfig;
//@property TXLivePush*       txLivePublisher;
@property(nonatomic,strong)V2TXLiveVideoEncoderParam *txLiveVideoParam;
@property(nonatomic,strong)V2TXLivePusher *txLivePusher;
@property(nonatomic,strong)TXAudioEffectManager *audioEffectManager;
@property (nonatomic,strong) NSDictionary *pushConfigMap;

/// 美颜与滤镜面板
@property(nonatomic,strong)NSMutableArray *filterOptionList;//美颜数组
@property (nonatomic,strong)UIView     *beautyContainerView;

/// 系统事件与定时器
@property (nonatomic,strong)CTCallCenter     *telephonyCallCenter;
@property (nonatomic,strong) NSTimer *backgroundTimer;
@property (nonatomic,assign) int backgroundElapsedTime;
@property (nonatomic,strong) NSTimer *heartAnimationTimer;
@property (nonatomic,assign) int heartBurstCount;
@property (nonatomic,strong) NSTimer *statsRefreshTimer;

/// 开播前信息输入（封面/标题/分类）
@property (nonatomic,strong) UIButton *previewThumbButton;
@property (nonatomic,strong) UILabel *previewThumbLabel;
@property (nonatomic,strong) UITextView *liveTitleTextView;
@property (nonatomic,strong) UILabel *textPlaceholderLabel;
@property (nonatomic,strong) UIImage *previewThumbnailImage;
@property (nonatomic,strong) UILabel *locationLabel;
@property (nonatomic,strong) UIButton *startLiveButton;
@property (nonatomic,strong) UILabel *classTipLabel;
@property (nonatomic,copy) NSString *selectedLiveClassId;

/// 开播倒计时动效
@property (nonatomic,strong) UIView *animationBackView;
@property (nonatomic,strong) UILabel *countdownLabel3;
@property (nonatomic,strong) UILabel *countdownLabel2;
@property (nonatomic,strong) UILabel *countdownLabel1;

/// 主播端直播间底部操作区
@property (nonatomic,assign) BOOL isMuted;
@property (nonatomic,assign) BOOL isTorch;
@property (nonatomic,assign) BOOL hasLoadedWebSprout;
@property (nonatomic,assign) BOOL shouldShowEndLinkButton;
@property (nonatomic,strong) UIButton *closeRoomButton;
@property (nonatomic,strong) UIButton *chatButton;
@property (nonatomic,strong) UIButton *goodsButton;
@property (nonatomic,strong) UIButton *linkButton;
@property (nonatomic,strong) UIButton *linkEndButton;
@property (nonatomic,strong) UILabel *linkRequestRedDotView;
@property (nonatomic,strong) UIButton *moreButton;
@property (nonatomic,strong) UILabel *likesCountLabel;
@property (nonatomic,strong) UILabel *userCountLabel;
@property (nonatomic,strong) SWUserPopupView *userPopupView;
@property (nonatomic,strong) UILabel *soldGoodsCountLabel;
@property (nonatomic,strong) SWLiveOnlineList *onlineUserListView;
@property (nonatomic,strong) SWLiveGoodsView *liveGoodsPanelView;
@property (nonatomic,strong) SWAnchorMoreMenuView *anchorMoreMenuView;
@property (nonatomic,strong) SWShareView *liveShareView;
@property (nonatomic,strong) UIView *continueGiftContainerView;
@property (nonatomic,strong) SWContinueGift *continueGiftView;
@property (nonatomic,strong) SWExpensiveGiftV *expensiveGiftView;
@property (nonatomic,strong) SWLinkApplyView *linkRequestView;

/// 美颜参数（腾讯 SDK）
@property (nonatomic,assign) float beautyLevel;
@property (nonatomic,assign) float whiteningLevel;
@property (nonatomic,assign) float eyeEnlargeLevel;
@property (nonatomic,assign) float faceSlimLevel;
@property (nonatomic,strong) UIButton *beautyButton;
@property (nonatomic,strong) UIButton *filterButton;
@property (nonatomic,strong) UILabel *beautyLabel;
@property (nonatomic,strong) UILabel *whiteningLabel;
@property (nonatomic,strong) UISlider *beautySlider;
@property (nonatomic,strong) UISlider *whiteningSlider;
@property (nonatomic,strong) V8HorizontalPickerView *filterPickerView;
@property (nonatomic,assign) NSInteger filterType;

/// 摄像头状态
@property (nonatomic,assign) BOOL needsScale;
@property (nonatomic,assign) BOOL isFrontCamera;

/// 连麦窗口与 TRTC 订阅状态
@property (nonatomic,strong) SWLinkUserView *linkMicUserView;
@property (nonatomic,strong) TRTCCloud *trtcCloud;
@property (nonatomic,copy) NSString *linkingRemoteUserId;
@property (nonatomic,copy) NSString *expectedRemoteUserIdFromSignal;
@property (nonatomic,assign) BOOL trtcEntered;
@property (nonatomic,assign) BOOL trtcEntering;
@property (nonatomic,copy) void (^trtcEnterCompletion)(BOOL ok);

/***********************  腾讯SDK end **********************/

/// 顶部状态提示条
@property (nonatomic,strong) CWStatusBarNotification *statusBarNotification;

/// 腾讯预览渲染视图
@property (nonatomic,strong) UIView *livePreviewRenderView;

/// 推流地址
@property (nonatomic,strong) NSString *pushStreamUrl;
/// 房间 socket
@property (nonatomic,strong) SWLiveSocket *liveSocket;
///定位
@property (nonatomic,strong) CLLocationManager   *locationServiceManager;
///直播界面视图父view
@property (nonatomic,strong) UIView *liveRoomContainerView;
///直播间信息字典
@property (nonatomic,strong) NSMutableDictionary *roomInfoMap;
///聊天展示tableview
@property (nonatomic,strong) UITableView *chatTableView;
///聊天信息数组
@property (nonatomic,strong) NSMutableArray *chatMessageList;
///直播间打字聊天输入框
@property (nonatomic,strong) UIView *chatInputContainerView;
@property (nonatomic,strong) UITextField *chatInputTextField;

@end

@implementation SWLivebroadViewController

#pragma mark - TRTC（用于订阅网页端连麦画面）
- (void)trtcInitIfNeeded {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
        [_trtcCloud addDelegate:(id<TRTCCloudDelegate>)self];
    }
}

- (void)trtcEnterRoomIfNeededThen:(void (^)(BOOL ok))completion {
    // 1) 保证 TRTCCloud 已初始化
    [self trtcInitIfNeeded];
    // 2) 已经进房则直接回调
    if (_trtcEntered) {
        if (completion) completion(YES);
        return;
    }
    // 3) 进房中则只更新 completion，避免并发重复进房
    if (_trtcEntering) {
        _trtcEnterCompletion = completion;
        return;
    }
    // 4) 拉取 usersig/sdkappid 后执行进房
    _trtcEntering = YES;
    _trtcEnterCompletion = completion;
    // 复用现有接口获取 usersig/sdkappid
    NSString *url = [NSString stringWithFormat:@"livemic/url?stream=%@&liveuid=%@",
                     minstr([self.roomInfoMap valueForKey:@"stream"]),
                     minstr([self.roomInfoMap valueForKey:@"uid"])];
    [SWToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code != 200) {
            self->_trtcEntering = NO;
            if (self->_trtcEnterCompletion) self->_trtcEnterCompletion(NO);
            self->_trtcEnterCompletion = nil;
            return;
        }
        // 5) 组装 TRTC 进房参数（主播端仅订阅连麦用户画面）
        TRTCParams *params = [[TRTCParams alloc] init];
        params.sdkAppId = [minstr([info objectForKey:@"sdkappid"]) intValue];
        params.roomId = [minstr([self.roomInfoMap objectForKey:@"showid"]) intValue];
        params.userId = [SWConfig getOwnID];
        params.role = TRTCRoleAudience; // 仅订阅远端画面，不重复采集本地
        params.userSig = minstr([info objectForKey:@"usersig"]);
        NSLog(@"[TRTC] enterRoom request sdkAppId=%d roomId=%d userId=%@ expectedRemote=%@",
              params.sdkAppId, params.roomId, params.userId, self->_expectedRemoteUserIdFromSignal);
        [_trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
    } Fail:^{
        self->_trtcEntering = NO;
        if (self->_trtcEnterCompletion) self->_trtcEnterCompletion(NO);
        self->_trtcEnterCompletion = nil;
    }];
}

#pragma mark - TRTCCloudDelegate
- (void)onEnterRoom:(NSInteger)result {
    // result < 0 代表进房失败；>=0 代表耗时（ms）
    NSLog(@"[TRTC] onEnterRoom result=%ld roomId=%@ userId=%@",
          (long)result, minstr([self.roomInfoMap objectForKey:@"showid"]), [SWConfig getOwnID]);
    _trtcEntering = NO;
    _trtcEntered = result >= 0;
    if (_trtcEnterCompletion) {
        _trtcEnterCompletion(_trtcEntered);
        _trtcEnterCompletion = nil;
    }
    // 进房成功后，如果已经收到上麦用户，尝试拉取一次
    if (_trtcEntered && _linkingRemoteUserId.length > 0 && _linkMicUserView) {
        [_trtcCloud startRemoteView:_linkingRemoteUserId
                         streamType:TRTCVideoStreamTypeBig
                               view:_linkMicUserView.videoContainerView];
    }
}

- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(NSDictionary *)extInfo {
    NSLog(@"[TRTC] onError code=%ld msg=%@ ext=%@", (long)errCode, errMsg, extInfo);
}

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    NSLog(@"[TRTC] onUserVideoAvailable userId=%@ available=%d", userId, available);
    if (!available) {
        if (_linkingRemoteUserId.length > 0 && [userId isEqualToString:_linkingRemoteUserId]) {
            [_trtcCloud stopRemoteView:userId streamType:TRTCVideoStreamTypeBig];
        }
        return;
    }
    if (!_linkMicUserView) return;

    // 优先使用信令里的 uid（预期远端 userId）
    if (_expectedRemoteUserIdFromSignal.length > 0) {
        if ([userId isEqualToString:_expectedRemoteUserIdFromSignal]) {
            _linkingRemoteUserId = userId;
        } else if (_linkingRemoteUserId.length == 0) {
            // 兜底：信令 uid 与 TRTC userId 不一致时，先显示第一个可用的远端画面，避免一直黑屏
            NSLog(@"[TRTC] WARNING: signal uid(%@) != trtc userId(%@). Auto-bind remote userId.",
                  _expectedRemoteUserIdFromSignal, userId);
            _linkingRemoteUserId = userId;
        }
    } else if (_linkingRemoteUserId.length == 0) {
        _linkingRemoteUserId = userId;
    }

    if (_linkingRemoteUserId.length > 0 && [userId isEqualToString:_linkingRemoteUserId]) {
        NSLog(@"[TRTC] startRemoteView userId=%@ -> linkWindow", userId);
        [_trtcCloud startRemoteView:userId
                         streamType:TRTCVideoStreamTypeBig
                               view:_linkMicUserView.videoContainerView];
    }
}
#pragma mark -- 退出登录
- (void)doSignOut{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark -- 定位相关
/*
- (void)stopLbs {
    [_locationServiceManager stopUpdatingHeading];
    _locationServiceManager.delegate = nil;
    _locationServiceManager = nil;
}
- (void)locationServiceManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        [self stopLbs];
    } else {
        [_locationServiceManager startUpdatingLocation];
    }
}
- (void)locationServiceManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self stopLbs];
}
- (void)locationServiceManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocatioin = locations[0];
    SWLiveCity *cityU = [SWCityDefault myProfile];
    cityU.lat = [NSString stringWithFormat:@"%f",newLocatioin.coordinate.latitude];
    cityU.lng = [NSString stringWithFormat:@"%f",newLocatioin.coordinate.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocatioin completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error)
        {
            CLPlacemark *placeMark = placemarks[0];
            NSString *city      = placeMark.locality;
            NSString *addr = [NSString stringWithFormat:@"%@%@%@%@%@",placeMark.country,placeMark.administrativeArea,placeMark.locality,placeMark.subLocality,placeMark.thoroughfare];
            cityU.addr = addr;
            cityU.city = city;
            [SWCityDefault saveProfile:cityU];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.locationLabel.text = city;
            });
        }
    }];
     [self stopLbs];
}
-(void)location{
    if (!_locationServiceManager) {
        _locationServiceManager = [[CLLocationManager alloc] init];
        [_locationServiceManager setDesiredAccuracy:kCLLocationAccuracyBest];
        _locationServiceManager.delegate = self;
        // 兼容iOS8定位
        SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [_locationServiceManager respondsToSelector:requestSelector]) {
            [_locationServiceManager requestWhenInUseAuthorization];  //调用了这句,就会弹出允许框了.
        } else {
            [_locationServiceManager startUpdatingLocation];
        }
    }
}
*/
#pragma mark -- 定位结束

#pragma mark -- 腾讯直播相关
-(void)txBaseBeauty {
    // 初始化滤镜数据源（横向选择器）
    _filterOptionList = [NSMutableArray new];
    [_filterOptionList addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"原图";
        v.face = [UIImage imageNamed:@"orginal"];
        v;
    })];
    [_filterOptionList addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"美白";
        v.face = [UIImage imageNamed:@"fwhite"];
        v;
    })];
    [_filterOptionList addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"浪漫";
        v.face = [UIImage imageNamed:@"langman"];
        v;
    })];
    [_filterOptionList addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"清新";
        v.face = [UIImage imageNamed:@"qingxin"];
        v;
    })];
    [_filterOptionList addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"唯美";
        v.face = [UIImage imageNamed:@"weimei"];
        v;
    })];
    [_filterOptionList addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"粉嫩";
        v.face = [UIImage imageNamed:@"fennen"];
        v;
    })];
    [_filterOptionList addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"怀旧";
        v.face = [UIImage imageNamed:@"huaijiu"];
        v;
    })];
    [_filterOptionList addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"蓝调";
        v.face = [UIImage imageNamed:@"landiao"];
        v;
    })];
    [_filterOptionList addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"清凉";
        v.face = [UIImage imageNamed:@"qingliang"];
        v;
    })];
    [_filterOptionList addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"日系";
        v.face = [UIImage imageNamed:@"rixi"];
        v;
    })];
    
    
    
    // 组装美颜/滤镜面板 UI（按钮、滑杆、选择器）
    //美颜拉杆浮层
    float   beauty_btn_width  = 65;
    float   beauty_btn_height = 30;//19;
    
    float   beauty_btn_count  = 2;
    
    float   beauty_center_interval = (self.view.width - 30 - beauty_btn_width)/(beauty_btn_count - 1);
    float   first_beauty_center_x  = 15 + beauty_btn_width/2;
    int ib = 0;
    _beautyContainerView = [[UIView  alloc] init];
    _beautyContainerView.frame = CGRectMake(0, self.view.height-185-statusbarHeight, self.view.width, 185+statusbarHeight);
    [_beautyContainerView setBackgroundColor:[UIColor whiteColor]];
    float   beauty_center_y = _beautyContainerView.height - 30;//35;
    _beautyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _beautyButton.center = CGPointMake(first_beauty_center_x, beauty_center_y);
    _beautyButton.bounds = CGRectMake(0, 0, beauty_btn_width, beauty_btn_height);
    [_beautyButton setImage:[UIImage imageNamed:@"white_beauty"] forState:UIControlStateNormal];
    [_beautyButton setImage:[UIImage imageNamed:@"white_beauty_press"] forState:UIControlStateSelected];
    [_beautyButton setTitle:@"美颜" forState:UIControlStateNormal];
    [_beautyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_beautyButton setTitleColor:normalColors forState:UIControlStateSelected];
    _beautyButton.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    _beautyButton.titleLabel.font = [UIFont systemFontOfSize:16];
    _beautyButton.tag = 0;
    _beautyButton.selected = YES;
    [_beautyButton addTarget:self action:@selector(selectBeauty:) forControlEvents:UIControlEventTouchUpInside];
    ib++;
    _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _filterButton.center = CGPointMake(first_beauty_center_x + ib*beauty_center_interval, beauty_center_y);
    _filterButton.bounds = CGRectMake(0, 0, beauty_btn_width, beauty_btn_height);
    [_filterButton setImage:[UIImage imageNamed:@"beautiful"] forState:UIControlStateNormal];
    [_filterButton setImage:[UIImage imageNamed:@"beautiful_press"] forState:UIControlStateSelected];
    [_filterButton setTitle:@"滤镜" forState:UIControlStateNormal];
    [_filterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_filterButton setTitleColor:normalColors forState:UIControlStateSelected];
    _filterButton.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    _filterButton.titleLabel.font = [UIFont systemFontOfSize:16];
    _filterButton.tag = 1;
    [_filterButton addTarget:self action:@selector(selectBeauty:) forControlEvents:UIControlEventTouchUpInside];
    ib++;
    _beautyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,  _beautyButton.top - 95, 40, 20)];
    _beautyLabel.text = @"美白";
    _beautyLabel.font = [UIFont systemFontOfSize:12];
    _beautySlider = [[UISlider alloc] init];
    _beautySlider.frame = CGRectMake(_beautyLabel.right, _beautyButton.top - 95, self.view.width - _beautyLabel.right - 10, 20);
    _beautySlider.minimumValue = 0;
    _beautySlider.maximumValue = 9;
    _beautySlider.value = 6.3;
    [_beautySlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [_beautySlider setMinimumTrackImage:[SWToolClass getImgWithColor:normalColors] forState:UIControlStateNormal];
    [_beautySlider setMaximumTrackImage:[UIImage imageNamed:@"gray"] forState:UIControlStateNormal];
    [_beautySlider addTarget:self action:@selector(txsliderValueChange:) forControlEvents:UIControlEventValueChanged];
    _beautySlider.tag = 0;
    
    
    _whiteningLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _beautyButton.top - 55, 40, 20)];
    
    _whiteningLabel.text = @"美颜";
    _whiteningLabel.font = [UIFont systemFontOfSize:12];
    _whiteningSlider = [[UISlider alloc] init];
    
    _whiteningSlider.frame =  CGRectMake(_whiteningLabel.right, _beautyButton.top - 55, self.view.width - _whiteningLabel.right - 10, 20);
    
    _whiteningSlider.minimumValue = 0;
    _whiteningSlider.maximumValue = 9;
    _whiteningSlider.value = 2.7;
    [_whiteningSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [_whiteningSlider setMinimumTrackImage:[SWToolClass getImgWithColor:normalColors] forState:UIControlStateNormal];//[UIImage imageNamed:@"green"]
    [_whiteningSlider setMaximumTrackImage:[UIImage imageNamed:@"gray"] forState:UIControlStateNormal];
    [_whiteningSlider addTarget:self action:@selector(txsliderValueChange:) forControlEvents:UIControlEventValueChanged];
    _whiteningSlider.tag = 1;
    
    _filterPickerView = [[V8HorizontalPickerView alloc] initWithFrame:CGRectMake(0, 10, self.view.width, 115)];
    _filterPickerView.textColor = [UIColor grayColor];
    _filterPickerView.elementFont = [UIFont fontWithName:@"" size:14];
    _filterPickerView.delegate = self;
    _filterPickerView.dataSource = self;
    _filterPickerView.hidden = YES;
    
    UIImageView *sel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filter_selected"]];
    
    _filterPickerView.selectedMaskView = sel;
    _filterType = 0;
    
    [_beautyContainerView addSubview:_beautyLabel];
    [_beautyContainerView addSubview:_whiteningLabel];
    [_beautyContainerView addSubview:_whiteningSlider];
    [_beautyContainerView addSubview:_beautySlider];
    [_beautyContainerView addSubview:_beautyButton];
    [_beautyContainerView addSubview:_filterPickerView];
    [_beautyContainerView addSubview:_filterButton];
    _beautyContainerView.hidden = YES;
    [self.view addSubview: _beautyContainerView];
}
-(void)userTXBase {
    if (!_beautyContainerView) {
        [self txBaseBeauty];
    }
    _previewFrontView.hidden = YES;
    _beautyContainerView.hidden = NO;
    [self.view bringSubviewToFront:_beautyContainerView];
}
-(void)txRtmpPush{
    // 1) 创建预览渲染层并置于底层
    _livePreviewRenderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    _livePreviewRenderView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_livePreviewRenderView];
    [self.view sendSubviewToBack:_livePreviewRenderView];
    /*
     {
     "codingmode": "2",
     "resolution": "5",
     "fps": "15",
     "fps_min": "15",
     "fps_max": "30",
     "gop": "3",
     "bitrate": "800",
     "bitrate_min": "800",
     "bitrate_max": "1200",
     "audiorate": "44100",
     "audiobitrate": "48",
     "preview_fps": "15",
     "preview_resolution": "1"
     }
     */
    //配置推流参数
    /*
    _txLivePushonfig = [[TXLivePushConfig alloc] init];
    _txLivePushonfig.frontCamera = YES;
    _txLivePushonfig.enableAutoBitrate = YES;
    int videoResolution = [minstr([_pushConfigMap valueForKey:@"resolution"]) intValue];
    if (videoResolution == 0) {
        _txLivePushonfig.videoResolution = VIDEO_RESOLUTION_TYPE_360_640 ;
    }
    else if (videoResolution == 1){
        _txLivePushonfig.videoResolution = VIDEO_RESOLUTION_TYPE_540_960 ;
    }
    else{
        _txLivePushonfig.videoResolution = VIDEO_RESOLUTION_TYPE_720_1280 ;
    }
    _txLivePushonfig.videoEncodeGop = [minstr([_pushConfigMap valueForKey:@"gop"]) intValue];
    _txLivePushonfig.videoFPS = [minstr([_pushConfigMap valueForKey:@"fps"]) intValue];
    _txLivePushonfig.videoBitratePIN = [minstr([_pushConfigMap valueForKey:@"bitrate"]) intValue];
    _txLivePushonfig.videoBitrateMax = [minstr([_pushConfigMap valueForKey:@"bitrate_max"]) intValue];
    _txLivePushonfig.videoBitrateMin = [minstr([_pushConfigMap valueForKey:@"bitrate_min"]) intValue];
    _txLivePushonfig.audioSampleRate = [minstr([_pushConfigMap valueForKey:@"audiorate"]) intValue];
    _txLivePushonfig.pauseTime = 60;
    //background push
    _txLivePushonfig.pauseFps = 5;
    _txLivePushonfig.pauseTime = 300;
    //耳返
    _txLivePushonfig.enableAudioPreview = NO;
    _txLivePushonfig.pauseImg = [UIImage imageNamed:@"pause_publish.jpg"];
    _txLivePublisher = [[TXLivePush alloc] initWithConfig:_txLivePushonfig];
    if (isMHSDK) {
        _txLivePublisher.videoProcessDelegate = self;
        [_txLivePublisher setBeautyStyle:0 beautyLevel:0 whitenessLevel:0 ruddinessLevel:0];
        [_txLivePublisher setMirror:YES];
    }else{
        _beautyLevel = 9;
        _whiteningLevel = 3;
        [_txLivePublisher setBeautyStyle:0 beautyLevel:_beautyLevel whitenessLevel:_whiteningLevel ruddinessLevel:0];
    }
    
    [_txLivePublisher startPreview:_livePreviewRenderView];
    //[self txStartRtmp];
    _statusBarNotification = [CWStatusBarNotification new];
    _statusBarNotification.notificationLabelBackgroundColor = [UIColor redColor];
    _statusBarNotification.notificationLabelTextColor = [UIColor whiteColor];
    */

    // 2) 根据服务端下发参数设置编码配置
    _txLiveVideoParam = [[V2TXLiveVideoEncoderParam alloc]init];
    int videoResolution = [minstr([_pushConfigMap valueForKey:@"resolution"]) intValue];
    if (videoResolution == 0) {
        _txLiveVideoParam.videoResolution =V2TXLiveVideoResolution640x360;
    }
    else if (videoResolution == 1){
        _txLiveVideoParam.videoResolution =V2TXLiveVideoResolution960x540;
    }
    else if (videoResolution == 2){
        _txLiveVideoParam.videoResolution =V2TXLiveVideoResolution1280x720;
    }else  if (videoResolution == 3){
        _txLiveVideoParam.videoResolution =V2TXLiveVideoResolution1920x1080;
    }else {
        _txLiveVideoParam.videoResolution =V2TXLiveVideoResolution960x540;

    }
    _txLiveVideoParam.videoFps = [minstr([_pushConfigMap valueForKey:@"fps"]) intValue];
    _txLiveVideoParam.videoBitrate = [minstr([_pushConfigMap valueForKey:@"bitrate"]) intValue];
    _txLiveVideoParam.minVideoBitrate = [minstr([_pushConfigMap valueForKey:@"bitrate_min"]) intValue];

    // 3) 初始化推流器并绑定渲染/采集/观察者
    _txLivePusher = [[V2TXLivePusher alloc]initWithLiveMode:V2TXLiveMode_RTC];
    V2TXLiveCode videoCode = [_txLivePusher setVideoQuality:_txLiveVideoParam];
    V2TXLiveCode cusVideoCode =[_txLivePusher enableCustomVideoProcess:true pixelFormat:V2TXLivePixelFormatTexture2D bufferType:V2TXLiveBufferTypeTexture];
    V2TXLiveCode mirrorCode = [_txLivePusher setEncoderMirror:YES];

    //
    V2TXLiveCode code =  [_txLivePusher setRenderView:_livePreviewRenderView];

    V2TXLiveCode cameraCode = [_txLivePusher startCamera:YES];
    [_txLivePusher setRenderMirror:V2TXLiveMirrorTypeEnable];
    [_txLivePusher startMicrophone];

    //
    // 4) 保存音效管理器并监听推流状态
    _audioEffectManager =[_txLivePusher getAudioEffectManager];
    [_txLivePusher setObserver:self];
    NSLog(@"=========>videoCode:%ld===cusCode:%ld===mirrorCode:%ld===cameraCode:%ld===render:%ld",(long)videoCode,(long)cusVideoCode,(long)mirrorCode,(long)cameraCode,(long)code);
    //
    _statusBarNotification = [CWStatusBarNotification new];
    _statusBarNotification.notificationLabelBackgroundColor = [UIColor redColor];
    _statusBarNotification.notificationLabelTextColor = [UIColor whiteColor];

}

// 备份原方法
- (void)txStartRtmp{
    /*
    if(_txLivePublisher != nil)
    {
        _txLivePublisher.delegate = self;
        [self.txLivePublisher setVideoQuality:VIDEO_QUALITY_HIGH_DEFINITION adjustBitrate:YES adjustResolution:YES];
        //连麦混流
//        self.pushStreamUrl = [NSString stringWithFormat:@"%@&mix=session_id:%@",self.pushStreamUrl,[SWConfig getOwnID]];
        [_txLivePublisher startPush:self.pushStreamUrl];
        if ([_txLivePublisher startPush:self.pushStreamUrl] != 0) {
            [_statusBarNotification displayNotificationWithMessage:@"推流器启动失败" forDuration:5];
            NSLog(@"推流器启动失败");
        }
//        if ([[SWCommon getIsTXfiter]isEqual:@"1"]) {
//            [_txLivePublisher setEyeScaleLevel:_eyeEnlargeLevel];
//            [_txLivePublisher setFaceScaleLevel:_faceSlimLevel];
//        }
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    */
    if (_txLivePusher != nil) {
        // self.pushStreamUrl = [NSString stringWithFormat:@"%@&mix=session_id:%@",self.pushStreamUrl,[SWConfig getOwnID]];
        V2TXLiveCode pushStatus = [_txLivePusher startPush:self.pushStreamUrl];
        [self pushLiveStateCode:pushStatus];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}

//调整创建直播间-修改后
-(void)__txStartRtmp{
    // 替换为TRTC房间进入逻辑
    [self trtcEnterRoomIfNeededThen:^(BOOL ok) {
        if (ok) {
            // 进入房间成功后更新状态
            [self changePlayState:1];
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        } else {
            // 进入房间失败处理
            [_statusBarNotification displayNotificationWithMessage:@"进入直播间失败" forDuration:5];
        }
    }];
}
-(void)pushLiveStateCode:(V2TXLiveCode)pushStatus {
    if (pushStatus == V2TXLIVE_OK) {
        NSLog(@"LIVEBROADCAST --:推流成功、停止推流");
    }else if (pushStatus == V2TXLIVE_ERROR_INVALID_PARAMETER){
        [_statusBarNotification displayNotificationWithMessage:@"操作失败，url 不合法" forDuration:5];
        NSLog(@"推流器启动失败");
    }else if (pushStatus == V2TXLIVE_ERROR_INVALID_LICENSE){
        [_statusBarNotification displayNotificationWithMessage:@"操作失败，license 不合法，鉴权失败" forDuration:5];
        NSLog(@"推流器启动失败");
    }else if (pushStatus == V2TXLIVE_ERROR_REFUSED){
        [_statusBarNotification displayNotificationWithMessage:@"操作失败，RTC 不支持同一设备上同时推拉同一个 StreamId" forDuration:5];
        NSLog(@"推流器启动失败");
    }else if (pushStatus == V2TXLIVE_WARNING_NETWORK_BUSY){
        [_statusBarNotification displayNotificationWithMessage:
         @"您当前的网络环境不佳，请尽快更换网络保证正常直播" forDuration:5];
    }
}
- (void)txStopRtmp {
    /*
    if(_txLivePublisher != nil)
    {
        [_txLivePublisher stopBGM];
        _txLivePublisher.delegate = nil;
        [_txLivePublisher stopPreview];
        [_txLivePublisher stopPush];
        _txLivePublisher.config.pauseImg = nil;
        _txLivePublisher = nil;
    }*/
    if(_txLivePusher != nil) {
        [_audioEffectManager stopPlayMusic:666];
        [_txLivePusher stopCamera];
        [_txLivePusher stopMicrophone];
        [_txLivePusher stopPush];
        _txLivePusher = nil;
    }
    [self destroyLinkUserView];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}


#pragma mark --直播推流监听
/**
 * 直播推流器错误通知，推流器出现错误时，会回调该通知
 *
 * @param code      错误码 {@link V2TXLiveCode}。
 * @param msg       错误信息。
 * @param extraInfo 扩展信息。
 */
- (void)onError:(V2TXLiveCode)code message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo;
{
    NSLog(@"rtcManager Error ==:%ld =msg=:%@  =map=%@",code,msg,extraInfo);
}
/**
 * 麦克风采集音量值回调
 *
 * @param volume 音量大小。
 * @note  调用 {@link enableVolumeEvaluation} 开启采集音量大小提示之后，会收到这个回调通知。
 */
- (void)onMicrophoneVolumeUpdate:(NSInteger)volume{

}
/**
 * 推流器连接状态回调通知
 *
 * @param status    推流器连接状态 {@link V2TXLivePushStatus}。
 * @param msg       连接状态信息。
 * @param extraInfo 扩展信息。
 */
- (void)onPushStatusUpdate:(V2TXLivePushStatus)status message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == V2TXLivePushStatusDisconnected) {
            /// 与服务器断开连接
            NSLog(@"PUSH_EVT_PUSH_BEGIN网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启推流");
            [_statusBarNotification displayNotificationWithMessage:@"网络断连" forDuration:5];
            [self getCloseShow];

        }else if(status == V2TXLivePushStatusConnecting){
            /// 正在连接服务器

        }else if(status == V2TXLivePushStatusConnectSuccess){
            /// 连接服务器成功
            [self changePlayState:1];


        }else if(status == V2TXLivePushStatusConnectSuccess){
            ///  重连服务器中
            [_statusBarNotification displayNotificationWithMessage:@"网络断连, 已启动自动重连" forDuration:5];
        }
    });
}
/**
 * 直播推流器统计数据回调
 *
 * @param statistics 推流器统计数据 {@link V2TXLivePusherStatistics}
 */
- (void)onStatisticsUpdate:(V2TXLivePusherStatistics *)statistics; {

}
-(void)onWarning:(V2TXLiveCode)code message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo {
    if (code == V2TXLIVE_WARNING_NETWORK_BUSY) {
        [self pushLiveStateCode:code];
    }
}
#pragma mark -美狐回调
-(void)onProcessVideoFrame:(V2TXLiveVideoFrame *)srcFrame dstFrame:(V2TXLiveVideoFrame *)dstFrame{
    
}


-(void) onNetStatus:(NSDictionary*) param{
    
}
-(void) onPushEvent:(int)EvtID withParam:(NSDictionary*)param {
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"onPushEvent:(int)EvtID withParam:(NSDictionary*)param = \n%d",EvtID);
        if (EvtID >= 0) {
            if (EvtID == PUSH_WARNING_HW_ACCELERATION_FAIL) {
                _txLivePublisher.config.enableHWAcceleration = false;
                NSLog(@"PUSH_EVT_PUSH_BEGIN硬编码启动失败，采用软编码");
            }else if (EvtID == PUSH_EVT_CONNECT_SUCC) {
                // 已经连接推流服务器
                NSLog(@" PUSH_EVT_PUSH_BEGIN已经连接推流服务器");
            }else if (EvtID == PUSH_EVT_PUSH_BEGIN) {
                // 已经与服务器握手完毕,开始推流
                [self changePlayState:1];
                NSLog(@"liveshow已经与服务器握手完毕,开始推流");
            }else if (EvtID == PUSH_WARNING_RECONNECT){
                // 网络断连, 已启动自动重连 (自动重连连续失败超过三次会放弃)
                NSLog(@"网络断连, 已启动自动重连 (自动重连连续失败超过三次会放弃)");
            }else if (EvtID == PUSH_WARNING_NET_BUSY) {
                [_statusBarNotification displayNotificationWithMessage:@"您当前的网络环境不佳，请尽快更换网络保证正常直播" forDuration:5];
            }else if (EvtID == WARNING_RTMP_SERVER_RECONNECT) {
                [_statusBarNotification displayNotificationWithMessage:@"网络断连, 已启动自动重连" forDuration:5];
            }
        }else {
            if (EvtID == PUSH_ERR_NET_DISCONNECT) {
                NSLog(@"PUSH_EVT_PUSH_BEGIN网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启推流");
                [_statusBarNotification displayNotificationWithMessage:@"网络断连" forDuration:5];
                [self getCloseShow];
            }
        }
    });
    */
}

//调整创建直播间-修改后
//推流成功后更新直播状态 1开播
-(void)changePlayState:(int)status{
    
    NSDictionary *changelive = @{
                                 @"islive":@"1",
                                 @"room_type":@"2" // 设置为小程序类型的房间
                                 };
    [SWToolClass postNetworkWithUrl:@"live/upLive" andParameter:changelive success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {

        if (code == 200) {
            //
            [[SWLinkmicManager shareInstance] livemicCdn];
        }
    } fail:^{        
    }];
}

-(void) txsliderValueChange:(UISlider*) obj {
    // todo
    TXBeautyManager *beautyManager = [_txLivePusher getBeautyManager];

    if (obj.tag == 1) { //美颜
        _beautyLevel = obj.value;
        // [_txLivePublisher setBeautyStyle:0 beautyLevel:_beautyLevel whitenessLevel:_whiteningLevel ruddinessLevel:0];
        [beautyManager setBeautyStyle:0];
        [beautyManager setBeautyLevel:_beautyLevel];
        [beautyManager setWhitenessLevel:_whiteningLevel];
        [beautyManager setRuddyLevel:0];

    } else if (obj.tag == 0) { //美白
        _whiteningLevel = obj.value;
        //[_txLivePublisher setBeautyStyle:0 beautyLevel:_beautyLevel whitenessLevel:_whiteningLevel ruddinessLevel:0];
        // [_txLivePublisher setBeautyFilterDepth:_beauty_level setWhiteningFilterDepth:_whitening_level];
        [beautyManager setBeautyStyle:0];
        [beautyManager setBeautyLevel:_beautyLevel];
        [beautyManager setWhitenessLevel:_whiteningLevel];
        [beautyManager setRuddyLevel:0];

    } else if (obj.tag == 2) { //大眼
        _eyeEnlargeLevel = obj.value;
        // [_txLivePublisher setEyeScaleLevel:_eyeEnlargeLevel];
        [beautyManager setEyeScaleLevel:_eyeEnlargeLevel];
    } else if (obj.tag == 3) { //瘦脸
        _faceSlimLevel = obj.value;
        // [_txLivePublisher setFaceScaleLevel:_faceSlimLevel];
        [beautyManager setFaceVLevel:_faceSlimLevel];
    } else if (obj.tag == 4) {// 背景音乐音量
        // [_txLivePublisher setBGMVolume:(obj.value/obj.maximumValue)];
        [_audioEffectManager setVoiceVolume:(obj.value/obj.maximumValue)];
    } else if (obj.tag == 5) { // 麦克风音量
        // [_txLivePublisher setMicVolume:(obj.value/obj.maximumValue)];
    }
}

-(void)selectBeauty:(UIButton *)button{
    switch (button.tag) {
        case 0: {
            _whiteningSlider.hidden = NO;
            _beautySlider.hidden    = NO;
            _beautyLabel.hidden = NO;
            _whiteningLabel.hidden  = NO;
            _beautyButton.selected  = YES;
            _filterButton.selected = NO;
            _filterPickerView.hidden = YES;
            _beautyContainerView.frame = CGRectMake(0, self.view.height-185-statusbarHeight, self.view.width, 185+statusbarHeight);
        }break;
        case 1: {
            _whiteningSlider.hidden = YES;
            _beautySlider.hidden    = YES;
            _beautyLabel.hidden = YES;
            _whiteningLabel.hidden  = YES;
            _beautyButton.selected  = NO;
            _filterButton.selected = YES;
            _filterPickerView.hidden = NO;
            [_filterPickerView scrollToElement:_filterType animated:NO];
        }
            _beautyButton.center = CGPointMake(_beautyButton.center.x, _beautyContainerView.frame.size.height - 35-statusbarHeight);
            _filterButton.center = CGPointMake(_filterButton.center.x, _beautyContainerView.frame.size.height - 35-statusbarHeight);
    }
}
//设置美颜滤镜
#pragma mark - HorizontalPickerView DataSource Methods/Users/annidy/Work/RTMPDemo_PituMerge/RTMPSDK/webrtc
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    return [_filterOptionList count];
}
#pragma mark - HorizontalPickerView Delegate Methods
- (UIView *)horizontalPickerView:(V8HorizontalPickerView *)picker viewForElementAtIndex:(NSInteger)index {
    
    V8LabelNode *v = [_filterOptionList objectAtIndex:index];
    return [[UIImageView alloc] initWithImage:v.face];
    
}
- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    
    return 90;
}
- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    _filterType = index;
    [self filterSelected:index];
}
- (void)filterSelected:(NSInteger)index {
    NSString* lookupFileName = @"";
    switch (index) {
        case FilterType_None:
            break;
        case FilterType_white:
            lookupFileName = @"filter_white";
            break;
        case FilterType_langman:
            lookupFileName = @"filter_langman";
            break;
        case FilterType_qingxin:
            lookupFileName = @"filter_qingxin";
            break;
        case FilterType_weimei:
            lookupFileName = @"filter_weimei";
            break;
        case FilterType_fennen:
            lookupFileName = @"filter_fennen";
            break;
        case FilterType_huaijiu:
            lookupFileName = @"filter_huaijiu";
            break;
        case FilterType_landiao:
            lookupFileName = @"filter_landiao";
            break;
        case FilterType_qingliang:
            lookupFileName = @"filter_qingliang";
            break;
        case FilterType_rixi:
            lookupFileName = @"filter_rixi";
            break;
        default:
            break;
    }
    TXBeautyManager *beautyManager = [_txLivePusher getBeautyManager];
    NSString * path = [[NSBundle mainBundle] pathForResource:lookupFileName ofType:@"png"];
    if (path != nil && index != FilterType_None && _txLivePusher != nil) {
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        // [_txLivePublisher setFilter:image];
        [beautyManager setFilter:image];
    }
    else if(_txLivePusher != nil) {
        [beautyManager setFilter:nil];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    if (self.anchorMoreMenuView) {
        self.anchorMoreMenuView.hidden = YES;
        self.moreButton.selected = NO;
    }
    //腾讯基础美颜
    if (_beautyContainerView && _beautyContainerView.hidden == NO) {
        _beautyContainerView.hidden = YES;
         _previewFrontView.hidden = NO;
    }
    if (isMHSDK) {
        [self.menusView showMenuView:NO];
        _previewFrontView.hidden = self.menusView.isShow;
    }

}

#pragma mark ================ TXVideoProcessDelegate ===============
- (GLuint)onPreProcessTexture:(GLuint)texture width:(CGFloat)width height:(CGFloat)height{

    if (isMHSDK) {
//        GLuint newTexture = [_beautyManager processWithTexture:texture width:width height:height scale:0.75];
//        return newTexture;
//        [self.beautyManager processWithTexture:texture width:width height:height];
        GLuint newTexture = texture;
        if (_needsScale){
            newTexture = [self.beautyManager processWithTexture:texture width:width height:height scale:0.75];
        }else{
            [self.beautyManager processWithTexture:texture width:width height:height];
        }
        
        return newTexture;
    }
    return texture;
}
- (MHBeautyManager *)beautyManager {
    if (!_beautyManager) {
        _beautyManager = [[MHBeautyManager alloc] init];
    }
    return _beautyManager;
}
- (void)checkDevice{
    /*获取当前机型，判断是否为iPhone7及以上*/
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    NSArray *symbols = [platform componentsSeparatedByString:@","];
    if (symbols.count > 0){
        NSCharacterSet *characterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSInteger number = [[[symbols[0] componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""] integerValue];
        //iPhone9,1 -> iPhone 7
        if (number >= 9){
            _needsScale = NO;
        }else{
            _needsScale = YES;
        }
    }
}
#pragma mark - MHMenuViewDelegate
- (void)beautyEffectWithLevel:(NSInteger)beauty whitenessLevel:(NSInteger)white ruddinessLevel:(NSInteger)ruddiness {
    //暂时用腾讯的美颜
    _beautyLevel = 9;
    _whiteningLevel = 3;
    // [_txLivePublisher setBeautyStyle:0 beautyLevel:beauty whitenessLevel:white ruddinessLevel:ruddiness];
    TXBeautyManager *beautyManager = [_txLivePusher getBeautyManager];
    [beautyManager setBeautyStyle:0];
    [beautyManager setBeautyLevel:_beautyLevel];
    [beautyManager setWhitenessLevel:_whiteningLevel];
    [beautyManager setRuddyLevel:0];
}



- (void)onTextureDestoryed{
    NSLog(@"[self.tiSDKManager destroy];");
}
#pragma mark ===========================   腾讯推流end   =======================================
-(void)viewWillAppear:(BOOL)animated{
    [[IQKeyboardManager sharedManager] setEnable:NO];
}
-(void)viewWillDisappear:(BOOL)animated{
    [[IQKeyboardManager sharedManager] setEnable:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    //弹出相机权限
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
     
    }];
    //弹出麦克风权限
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
      
    }];

    //开始定位
//    [self location];
    //初始化一些基本信息
    [self chushihua];
    //注册通知
    [self configNotificationAndObserver];

    //创建预览视图
    [self creatPreFrontView];
    WeakSelf;
    AFNetworkReachabilityManager *managerAFH = [AFNetworkReachabilityManager sharedManager];
    [managerAFH setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未识别的网络");
                [weakSelf backGround];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"不可达的网络(未连接)");
                [weakSelf backGround];
                break;
            case  AFNetworkReachabilityStatusReachableViaWWAN:
                [weakSelf forwardGround];

                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [weakSelf forwardGround];
                break;
            default:
                break;
        }
    }];
    [managerAFH startMonitoring];
   

#pragma mark 回到后台+来电话
    self.telephonyCallCenter = [CTCallCenter new];
    
    self.telephonyCallCenter.callEventHandler = ^(CTCall *call) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([call.callState isEqualToString:CTCallStateDialing]) {
                NSLog(@"电话主动拨打电话");
                [weakSelf reciverPhoneCall];
            } else if ([call.callState isEqualToString:CTCallStateConnected]) {
                NSLog(@"电话接通");
                [weakSelf reciverPhoneCall];
            } else if ([call.callState isEqualToString:CTCallStateDisconnected]) {
                NSLog(@"电话挂断");
                [weakSelf phoneCallEnd];
            } else if ([call.callState isEqualToString:CTCallStateIncoming]) {
                NSLog(@"电话被叫");
                [weakSelf reciverPhoneCall];
            } else {
                NSLog(@"电话其他状态");
            }
        });
    };
    
    [MBProgressHUD hideHUD];
//    [self creatPreFrontView];
    [self getHomeConfig];
    
}
- (void)getHomeConfig{
    [SWToolClass getQCloudWithUrl:@"/live/config" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            //腾讯
            _pushConfigMap = [info valueForKey:@"ios"];
            [self txRtmpPush];

        }
    } Fail:^{
        
    }];
}
- (void)chushihua{
    self.shouldShowEndLinkButton = false;
    self.selectedLiveClassId = @"未选择";
    _chatMessageList = [NSMutableArray array];
    _isFrontCamera = YES;
    [self checkDevice];
}
-(void)configNotificationAndObserver{
    //注册进入后台的处理
    NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self
           selector:@selector(appactive)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
    [notification addObserver:self
           selector:@selector(appnoactive)
               name:UIApplicationWillResignActiveNotification
             object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [notification addObserver:self
           selector:@selector(shajincheng)
               name:@"shajincheng"
             object:nil];


}
#pragma mark ================ 直播开始之前的预览 ===============
- (void)creatPreFrontView{
    // 1) 预开播页面根容器
    _previewFrontView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    _previewFrontView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_previewFrontView];
//    UIView *zhezhaoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
//    zhezhaoView.backgroundColor = RGB_COLOR(@"#000000", 0.4);
//    [_previewFrontView addSubview:zhezhaoView];
    /*
    UIImageView *loactionImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 42+statusbarHeight, 16, 16)];
    loactionImgView.image = [UIImage imageNamed:@"pre_location"];
    [_previewFrontView addSubview:loactionImgView];
    UIView *locationLabelView = [[UIView alloc]init];
    locationLabelView.backgroundColor = RGB_COLOR(@"#000000", 0.3);
    locationLabelView.layer.cornerRadius = 8;
    locationLabelView.layer.masksToBounds = YES;
    [_previewFrontView addSubview:locationLabelView];
    [locationLabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(loactionImgView);
        make.left.equalTo(loactionImgView.mas_right).offset(-8);
        make.height.mas_equalTo(16);
    }];

    self.locationLabel = [[UILabel alloc]init];
    self.locationLabel.text = @"  ";
    self.locationLabel.font = [UIFont systemFontOfSize:11];
    self.locationLabel.textColor = [UIColor whiteColor];
    self.locationLabel.text = [SWCityDefault getMyCity];
    [locationLabelView addSubview:self.locationLabel];
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(locationLabelView);
        make.height.mas_equalTo(16);
        make.left.equalTo(locationLabelView).offset(10);
        make.right.equalTo(locationLabelView).offset(-10);
    }];
    [_previewFrontView insertSubview:locationLabelView belowSubview:loactionImgView];
    UIButton *locationSwitchBtn = [UIButton buttonWithType:0];
    [locationSwitchBtn addTarget:self action:@selector(locationSwitchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_previewFrontView addSubview:locationSwitchBtn];
    [locationSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.height.equalTo(loactionImgView);
        make.right.equalTo(locationLabelView);
    }];
     */
    // 2) 顶部快捷操作（切摄像头、退出登录）
    UIButton *switchBtn = [UIButton buttonWithType:0];
//    switchBtn.frame = CGRectMake(locationLabel.right+20, loactionImgView.top, loactionImgView.height, loactionImgView.height);
    [switchBtn setImage:[UIImage imageNamed:@"pre_camer"] forState:0];
    [switchBtn addTarget:self action:@selector(rotateCamera) forControlEvents:UIControlEventTouchUpInside];
    [_previewFrontView addSubview:switchBtn];
    [switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_previewFrontView).offset(15);
        make.top.equalTo(_previewFrontView).offset(40+statusbarHeight);
        make.height.width.mas_equalTo(20);
    }];
    
    UIButton *signOutbtn = [UIButton buttonWithType:0];
    [signOutbtn setImage:[UIImage imageNamed:@"pre_退出登录"] forState:0];
    [signOutbtn addTarget:self action:@selector(doSignOut) forControlEvents:UIControlEventTouchUpInside];
    signOutbtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [_previewFrontView addSubview:signOutbtn];
    [signOutbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_previewFrontView).offset(-10);
        make.centerY.equalTo(switchBtn);
        make.height.width.mas_equalTo(40);
    }];
    
    
    // 3) 中部信息区（封面 + 标题输入）
    UIView *preMiddleView = [[UIView alloc]initWithFrame:CGRectMake(10, 110+statusbarHeight, _window_width-20, (_window_width-20)*0.4)];
    preMiddleView.backgroundColor = RGB_COLOR(@"#000000", 0.15);
    preMiddleView.layer.cornerRadius = 5;
    [_previewFrontView addSubview:preMiddleView];
    
    self.previewThumbButton = [UIButton buttonWithType:0];
    self.previewThumbButton.frame = CGRectMake(10, 15, (preMiddleView.height-30)*0.91, preMiddleView.height-30);
    [self.previewThumbButton setImage:[UIImage imageNamed:@"pre_uploadThumb"] forState:0];
//    self.previewThumbButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.previewThumbButton addTarget:self action:@selector(doUploadPicture) forControlEvents:UIControlEventTouchUpInside];
    self.previewThumbButton.layer.cornerRadius = 5.0;
    self.previewThumbButton.layer.masksToBounds = YES;
    [preMiddleView addSubview:self.previewThumbButton];
    self.previewThumbLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.previewThumbButton.height*0.75, self.previewThumbButton.width, self.previewThumbButton.height/4)];
    self.previewThumbLabel.textColor = RGB_COLOR(@"#ffffff", 1);
    self.previewThumbLabel.textAlignment = NSTextAlignmentCenter;
    self.previewThumbLabel.text = @"添加封面";
    self.previewThumbLabel.font = [UIFont systemFontOfSize:12];
    [self.previewThumbButton addSubview:self.previewThumbLabel];
    

//    UILabel *preTitlelabel = [[UILabel alloc]initWithFrame:CGRectMake(previewThumbButton.right+5, previewThumbButton.top, 100, previewThumbButton.height/4)];
//    preTitlelabel.font = [UIFont systemFontOfSize:13];
//    preTitlelabel.textColor = RGB_COLOR(@"#c8c8c8", 1);
//    preTitlelabel.text = @"直播标题";
//    [preMiddleView addSubview:preTitlelabel];
    self.liveTitleTextView = [[UITextView alloc]initWithFrame:CGRectMake(self.previewThumbButton.right+5, self.previewThumbButton.top + 5, preMiddleView.width-10-self.previewThumbButton.right, self.previewThumbButton.height-10)];
    self.liveTitleTextView.delegate = self;
    self.liveTitleTextView.font = [UIFont systemFontOfSize:17];
    self.liveTitleTextView.textColor = [UIColor whiteColor];
    self.liveTitleTextView.backgroundColor = [UIColor clearColor];
    [preMiddleView addSubview:self.liveTitleTextView];
    self.textPlaceholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 10, self.liveTitleTextView.width, 22)];
    self.textPlaceholderLabel.font = [UIFont systemFontOfSize:17];
    self.textPlaceholderLabel.textColor = [UIColor whiteColor];
    self.textPlaceholderLabel.text = @"给直播写个标题吧";
    [self.liveTitleTextView addSubview:self.textPlaceholderLabel];

    // 4) 直播分类选择区
    UIView *liveClassView = [[UIView alloc]initWithFrame:CGRectMake(preMiddleView.left, preMiddleView.bottom + 10, preMiddleView.width, 50)];
    liveClassView.backgroundColor = RGB_COLOR(@"#000000", 0.15);
    liveClassView.layer.cornerRadius = 5;
    [_previewFrontView addSubview:liveClassView];
    self.classTipLabel = [[UILabel alloc]init];
    self.classTipLabel.text = @"请选择直播分类";
    self.classTipLabel.textColor = RGB_COLOR(@"#ffffff", 1);
    self.classTipLabel.font = SYS_Font(14);
    [liveClassView addSubview:self.classTipLabel];
    [self.classTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(liveClassView).offset(15);
        make.centerY.equalTo(liveClassView);
        make.right.equalTo(liveClassView).offset(-35);
    }];
    UIImageView *classRightImgV = [[UIImageView alloc]init];
    classRightImgV.image = [UIImage imageNamed:@"pre_right"];
    [liveClassView addSubview:classRightImgV];
    [classRightImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(liveClassView);
        make.right.equalTo(liveClassView).offset(-13);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(14);
    }];
    UIButton *liveClassBtn = [UIButton buttonWithType:0];
    liveClassBtn.frame = CGRectMake(0, 0, liveClassView.width, liveClassView.height);
    [liveClassBtn addTarget:self action:@selector(showAllClassView) forControlEvents:UIControlEventTouchUpInside];
    [liveClassView addSubview:liveClassBtn];

    // 5) 开播主按钮
    //开播按钮
    self.startLiveButton = [UIButton buttonWithType:0];
    self.startLiveButton.layer.cornerRadius = 20.0;
    self.startLiveButton.layer.masksToBounds = YES;
    [self.startLiveButton setBackgroundColor:normalColors];
//    [self.startLiveButton setBackgroundImage:[UIImage imageNamed:@"startLive_back"]];
    [self.startLiveButton addTarget:self action:@selector(doHidden:) forControlEvents:UIControlEventTouchUpInside];
    [self.startLiveButton setTitle:@"开始直播" forState:0];
    self.startLiveButton.userInteractionEnabled = NO;
    self.startLiveButton.alpha = 0.5;
    self.startLiveButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_previewFrontView addSubview:self.startLiveButton];
    [self.startLiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_previewFrontView).offset(-80-ShowDiff);
        make.width.equalTo(_previewFrontView).multipliedBy(0.8);
        make.height.mas_equalTo(40);
        make.centerX.equalTo(_previewFrontView);
    }];
    // 6) 美颜入口
    //美颜
    UIButton *preFitterBtn = [UIButton buttonWithType:0];
    [preFitterBtn setTitle:@"美颜" forState:0];
    [preFitterBtn setImage:[UIImage imageNamed:@"pre_fitter"] forState:0];
    preFitterBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [preFitterBtn addTarget:self action:@selector(showFitterView) forControlEvents:UIControlEventTouchUpInside];
    [_previewFrontView addSubview:preFitterBtn];
    [preFitterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.startLiveButton.mas_top).offset(-15);
        make.centerX.equalTo(self.startLiveButton);
        make.height.mas_equalTo(30);
    }];
}
#pragma mark ============定位开关=============
- (void)locationSwitchBtnClick{
//    if ([locationLabel.text isEqual:YZMsg(@"开定位")]) {
//        loactionImgView.image = [UIImage imageNamed:@"pre_location"];
//        locationLabel.text = [SWCityDefault getMyCity];
//        locationSwitch = YES;
//    }else{
//        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:@"关闭定位，直播不会被附近的人看到，直播间人数可能会减少，确认关闭吗？" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            locationSwitch = YES;
//        }];
//        [cancleAction setValue:RGB_COLOR(@"#969696", 1) forKey:@"_titleTextColor"];
//
//        [alertContro addAction:cancleAction];
//        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"坚决关闭" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            loactionImgView.image = [UIImage imageNamed:@"pre_location_off"];
//            locationLabel.text = YZMsg(@"开定位");
//            locationSwitch = NO;
//         }];
//        [sureAction setValue:normalColors forKey:@"_titleTextColor"];
//        [alertContro addAction:sureAction];
//        [self presentViewController:alertContro animated:YES completion:nil];
//
//    }
}
#pragma mark -- 切换摄像头

-(void)rotateCamera{
    /*
    [_txLivePublisher switchCamera];
    [_txLivePublisher setMirror:_txLivePublisher.config.frontCamera];
    */
    _isFrontCamera = !_isFrontCamera;
    TXDeviceManager *deviceManager = [_txLivePusher getDeviceManager];
    [deviceManager switchCamera:_isFrontCamera];
    [_txLivePusher setEncoderMirror:_isFrontCamera];
}

#pragma mark -- 选择封面
-(void)doUploadPicture{
    TZImagePickerController *imagePC = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    imagePC.allowCameraLocation = YES;
    imagePC.allowTakeVideo = NO;
    imagePC.allowPickingVideo = NO;
    imagePC.showSelectBtn = NO;
    imagePC.allowCrop = YES;
    imagePC.allowPickingOriginalPhoto = NO;
    imagePC.scaleAspectFillCrop = YES;
    imagePC.photoWidth = 350;
    imagePC.photoPreviewMaxWidth = 300;
    imagePC.cropRect = CGRectMake(0, (_window_height-_window_width*1.1)/2, _window_width, _window_width*1.1);
    [self presentViewController:imagePC animated:YES completion:nil];

}
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    if (photos.count > 0) {
        self.previewThumbnailImage = [photos firstObject];
        [self.previewThumbButton setImage:self.previewThumbnailImage forState:UIControlStateNormal];
        self.previewThumbLabel.text = @"更换封面";
        self.previewThumbLabel.backgroundColor = RGB_COLOR(@"#0000000", 0.3);
    }
    [self changeStartLiveButtonState];

}



- (void)textViewDidChange:(UITextView *)textView

{
    if (textView.text.length == 0) {
        self.textPlaceholderLabel.text = @"给直播写个标题吧";
    }else{
        self.textPlaceholderLabel.text = @"";
    }
    [self changeStartLiveButtonState];

}
#pragma mark -- 选择直播分类

- (void)showAllClassView{
    SWStartLiveClassVC *vc = [[SWStartLiveClassVC alloc]init];
    vc.classID = self.selectedLiveClassId;
    vc.block = ^(NSDictionary * _Nonnull classMap) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectedLiveClassId = minstr([classMap valueForKey:@"id"]);
            self.classTipLabel.text = minstr([classMap valueForKey:@"name"]);
            [self changeStartLiveButtonState];
        });
    };
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];

}
#pragma mark -- 展示美颜

- (void)showFitterView{
    _previewFrontView.hidden = YES;
    if (isMHSDK) {
        [self.menusView showMenuView:YES];
    }else{
        [self userTXBase];
    }
}
#pragma mark -初始化美颜UI
-(MHMeiyanMenusView *)menusView{
    if (!_menusView) {
        _menusView = [[MHMeiyanMenusView alloc] initWithFrame:CGRectMake(0, window_height - MHMeiyanMenuHeight - BottomIndicatorHeight, window_width, MHMeiyanMenuHeight) superView:self.view delegate:self beautyManager:self.beautyManager isTXSDK:YES];
    }
    return _menusView;
}
#pragma mark -- 开播按钮点击
-(void)doHidden:(UIButton *)sender{
    // 开播前权限校验（相机 + 麦克风）
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        NSLog(@"相机权限受限");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"权限受阻" message:@"请在设置中开启相机权限" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
        
        return;
    }
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        
        if (granted) {
            
            // 用户同意获取麦克风
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"权限受阻" message:@"请在设置中开启麦克风权限" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alert show];
            
            return ;
            
        }
        
    }];
    [self creatRoom];
}
//创建房间
-(void)creatRoom{
    // Step 1: 上传封面图
    [MBProgressHUD showMessage:@""];
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@upload/image",purl];
    [session POST:url parameters:nil headers:@{@"Authori-zation":[NSString stringWithFormat:@"Bearer %@",[SWConfig getOwnToken]]} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (self.previewThumbnailImage) {
            
//            UIImage *img = UIImagePNGRepresentation(previewThumbnailImage);
            [formData appendPartWithFileData:UIImageJPEGRepresentation(self.previewThumbnailImage,0.5) name:@"file" fileName:[SWToolClass getNameBaseCurrentTime:@"livethumb.png"] mimeType:@"image/jpeg"];
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUD];

        NSDictionary *data = [responseObject valueForKey:@"data"];
        NSString *code = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"status"]];
        if ([code isEqual:@"200"]) {
            [self creatRommStepSecond:minstr([data valueForKey:@"url"])];
        }else{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[data valueForKey:@"msg"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络错误"];
    }];

}
- (void)creatRommStepSecond:(NSString *)thumbUrl{
    // Step 2: 创建直播间并缓存房间信息
    NSString *deviceinfo = [NSString stringWithFormat:@"%@_%@_%@",[SWToolClass getCurrentDeviceModel],[[UIDevice currentDevice] systemVersion],[SWToolClass getNetworkType]];
    NSDictionary *requestMap = @{
        @"title":minstr(self.liveTitleTextView.text),
        @"thumb":thumbUrl,
        @"classid":self.selectedLiveClassId,
        @"province":@"",
        @"city":@"",//minstr([SWCityDefault getMyCity])
        @"deviceinfo":deviceinfo,
        @"source":@"2",
        @"key":_keyString?_keyString:@""
    };
    [SWToolClass postNetworkWithUrl:@"live/start" andParameter:requestMap success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        [_previewFrontView removeFromSuperview];
        _previewFrontView = nil;
        self.roomInfoMap = [info mutableCopy];
        [self.roomInfoMap setObject:[SWConfig getOwnID] forKey:@"uid"];
        [self.roomInfoMap setObject:[SWConfig getavatar] forKey:@"avatar"];
        [self.roomInfoMap setObject:[SWConfig getOwnNicename] forKey:@"nickname"];
        [self.roomInfoMap setObject:thumbUrl forKey:@"thumb"];
        [self.roomInfoMap setObject:minstr([requestMap valueForKey:@"title"]) forKey:@"title"];
        //
        [SWLinkmicManager shareInstance].roomMap = [NSDictionary dictionaryWithDictionary:self.roomInfoMap];
        [SWLinkmicManager shareInstance].linkSwitch = NO;
        [SWLinkmicManager shareInstance].isLinking = NO;
        [self startUI];
    } fail:^{
        
    }];
}
-(void)startUI{
    // 1) 创建直播间主容器
    self.liveRoomContainerView = [[UIView alloc]initWithFrame:CGRectMake(0,0, _window_width, _window_height)];
    self.liveRoomContainerView.clipsToBounds = YES;
    [self.view addSubview:self.liveRoomContainerView];
    [self.view insertSubview:self.liveRoomContainerView atIndex:3];

    // 2) 加载主直播间 UI（按钮、聊天区、顶部信息区）
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setView];//加载信息页面
        [self hideBTN];
    });
    // 3) 开播前 3-2-1 倒计时动画层
    //倒计时动画
    self.animationBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    self.animationBackView.opaque = YES;
    self.countdownLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2 -100, _window_height/2-200, 100, 100)];
    self.countdownLabel3.textColor = [UIColor whiteColor];
    self.countdownLabel3.font = [UIFont systemFontOfSize:90];
    self.countdownLabel3.text = @"3";
    self.countdownLabel3.textAlignment = NSTextAlignmentCenter;
    self.countdownLabel3.center = self.animationBackView.center;
    self.countdownLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2 -100, _window_height/2-200, 100, 100)];
    self.countdownLabel2.textColor = [UIColor whiteColor];
    self.countdownLabel2.font = [UIFont systemFontOfSize:90];
    self.countdownLabel2.text = @"2";
    self.countdownLabel2.textAlignment = NSTextAlignmentCenter;
    self.countdownLabel2.center = self.animationBackView.center;
    self.countdownLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2 -100, _window_height/2-200, 100, 100)];
    self.countdownLabel1.textColor = [UIColor whiteColor];
    self.countdownLabel1.font = [UIFont systemFontOfSize:90];
    self.countdownLabel1.text = @"1";
    self.countdownLabel1.textAlignment = NSTextAlignmentCenter;
    self.countdownLabel1.center = self.animationBackView.center;
    self.countdownLabel3.hidden = YES;
    self.countdownLabel2.hidden = YES;
    self.countdownLabel1.hidden = YES;
    [self.animationBackView addSubview:self.countdownLabel1];
    [self.animationBackView addSubview:self.countdownLabel3];
    [self.animationBackView addSubview:self.countdownLabel2];
    [self.liveRoomContainerView addSubview:self.animationBackView];
    [self kaishidonghua];
    self.view.backgroundColor = [UIColor clearColor];
}
//开始321
-(void)kaishidonghua{
    // 分段触发 3-2-1 文本动画，结束后正式进房与推流
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.countdownLabel3.hidden = NO;
        [self donghua:self.countdownLabel3];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.countdownLabel3.hidden = YES;
        self.countdownLabel2.hidden = NO;
        [self donghua:self.countdownLabel2];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.countdownLabel2.hidden = YES;
        self.countdownLabel1.hidden = NO;
        [self donghua:self.countdownLabel1];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.countdownLabel1.hidden = YES;
        self.animationBackView.hidden = YES;
        [self.animationBackView removeFromSuperview];
        self.animationBackView = nil;
        [self showBTN];
        [self getStartShow];//请求直播
    });
}
//请求直播
-(void)getStartShow
{
    // 1) 缓存推流地址
    self.pushStreamUrl = minstr([self.roomInfoMap valueForKey:@"push"]);

    // 2) 初始化并接入房间 socket
    self.liveSocket = [[SWLiveSocket alloc]init];
    self.liveSocket.delegate = self;
    [self.liveSocket addNodeListen:minstr([self.roomInfoMap valueForKey:@"chatserver"]) andRoomMessage:self.roomInfoMap];

    // 3) 启动推流
    [self txStartRtmp];
    // for test
    // [self changePlayState:1];
}

-(void)donghua:(UILabel *)labels{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.8;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(4.0, 4.0, 4.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(3.0, 3.0, 3.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(2.0, 2.0, 2.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 0.1)]];
    animation.values = values;
    animation.removedOnCompletion = NO;//是不是移除动画的效果
    animation.fillMode = kCAFillModeForwards;//保持最新状态
    [labels.layer addAnimation:animation forKey:nil];
}
//创建直播间视图按钮
- (void)setView{
    // 1) 顶部主播信息区
    [self addLeftView];
    // 2) 顶部右侧控制（关闭 + 在线人数）
    self.closeRoomButton = [UIButton buttonWithType:0];
    [self.closeRoomButton setImage:[UIImage imageNamed:@"live_关闭"] forState:0];
    [self.closeRoomButton addTarget:self action:@selector(showCloseAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.liveRoomContainerView addSubview:self.closeRoomButton];
    [self.closeRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.liveRoomContainerView).offset(27+statusbarHeight);
        make.right.equalTo(self.liveRoomContainerView).offset(-10);
        make.width.height.mas_equalTo(30);
    }];
    self.userCountLabel = [[UILabel alloc]init];
    self.userCountLabel.font = SYS_Font(10);
    self.userCountLabel.textColor = [UIColor whiteColor];
    self.userCountLabel.textAlignment = NSTextAlignmentCenter;
    self.userCountLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    self.userCountLabel.text = @"  0人  ";
    self.userCountLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkUseList)];
    [self.userCountLabel addGestureRecognizer:tap];
    self.userCountLabel.layer.cornerRadius = 15;
    self.userCountLabel.layer.masksToBounds = YES;
    [self.liveRoomContainerView addSubview:self.userCountLabel];
    [self.userCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.closeRoomButton.mas_left).offset(-10);
        make.centerY.height.equalTo(self.closeRoomButton);
        make.width.mas_greaterThanOrEqualTo(40);
    }];
    
    // 3) 底部输入与操作按钮区
    self.chatButton = [UIButton buttonWithType:0];
    [self.chatButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
    [self.chatButton addTarget:self action:@selector(showToolbarView) forControlEvents:UIControlEventTouchUpInside];
    [self.chatButton setTitle:@"  说点什么..." forState:0];
    self.chatButton.titleLabel.font = SYS_Font(14);
    self.chatButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.chatButton.layer.cornerRadius = 18;
    self.chatButton.layer.masksToBounds = YES;
    [self.liveRoomContainerView addSubview:self.chatButton];
    [self.chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.liveRoomContainerView).offset(10);
        make.bottom.equalTo(self.liveRoomContainerView).offset(-10-ShowDiff);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(128);
    }];
    
    self.moreButton = [UIButton buttonWithType:0];
    [self.moreButton setBackgroundImage:[UIImage imageNamed:@"功能"] forState:UIControlStateNormal];
    [self.moreButton setBackgroundImage:[UIImage imageNamed:@"功能_s"] forState:UIControlStateSelected];
    [self.moreButton addTarget:self action:@selector(showmoreview) forControlEvents:UIControlEventTouchUpInside];
    [self.liveRoomContainerView addSubview:self.moreButton];
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.chatButton);
        make.right.equalTo(self.liveRoomContainerView).offset(-10);
        make.width.height.mas_equalTo(36);
    }];
    
    self.goodsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.goodsButton setBackgroundImage:[UIImage imageNamed:@"live_小黄车底"] forState:UIControlStateNormal];
    [self.goodsButton setImage:[UIImage imageNamed:@"live_小黄车"] forState:0];
    [self.goodsButton addTarget:self action:@selector(showgoodsShowView) forControlEvents:UIControlEventTouchUpInside];
    [self.liveRoomContainerView addSubview:self.goodsButton];
    [self.goodsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.chatButton);
        make.right.equalTo(self.moreButton.mas_left).offset(-10);
        make.width.height.mas_equalTo(36);
    }];
    [self showGoodsBtnAnimaition];

    //
    self.linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.linkButton setBackgroundImage:[UIImage imageNamed:@"live_link"] forState:UIControlStateNormal];
    [self.linkButton setBackgroundImage:[UIImage imageNamed:@"live_link"] forState:UIControlStateSelected];
    [self.linkButton addTarget:self action:@selector(clickLinkBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.liveRoomContainerView addSubview:self.linkButton];
    [self.linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.chatButton);
        make.right.equalTo(self.goodsButton.mas_left).offset(-10);
        make.width.height.mas_equalTo(36);
    }];
    self.linkRequestRedDotView = [[UILabel alloc] init];
    self.linkRequestRedDotView.backgroundColor = RGB_COLOR(@"#ff0000", 1);
    self.linkRequestRedDotView.layer.cornerRadius = 4;
    self.linkRequestRedDotView.layer.masksToBounds = YES;
    self.linkRequestRedDotView.hidden = YES;
    [self.linkButton addSubview:self.linkRequestRedDotView];
    [self.linkRequestRedDotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(8);
        make.top.equalTo(self.linkButton.mas_top);
        make.right.equalTo(self.linkButton.mas_right);
    }];

    self.linkEndButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.linkEndButton setBackgroundImage:[UIImage imageNamed:@"endLink"] forState:UIControlStateNormal];
    [self.linkEndButton setBackgroundImage:[UIImage imageNamed:@"endLink"] forState:UIControlStateSelected];
    [self.linkEndButton addTarget:self action:@selector(endLinkMaic) forControlEvents:UIControlEventTouchUpInside];
    self.linkEndButton.hidden = YES;
    [self.liveRoomContainerView addSubview:self.linkEndButton];
    [self.linkEndButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.chatButton);
        make.right.equalTo(self.linkButton.mas_left).offset(-10);
        make.width.height.mas_equalTo(36);
    }];
    
    // 4) 聊天展示区 + 礼物展示区
    [self.liveRoomContainerView addSubview:self.chatTableView];
    [_chatTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.liveRoomContainerView).offset(10);
        make.width.equalTo(self.liveRoomContainerView).multipliedBy(0.7);
        make.height.mas_equalTo(190);
        make.bottom.equalTo(self.chatButton.mas_top).offset(-35);
    }];
    self.continueGiftContainerView = [[UIView alloc]init];
    [self.liveRoomContainerView addSubview:self.continueGiftContainerView];
    [self.continueGiftContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.liveRoomContainerView);
        make.bottom.equalTo(_chatTableView.mas_top).offset(-10);
        make.width.mas_equalTo(_window_width/2);
        make.height.mas_equalTo(140);
    }];

    // 5) 输入容器与定时任务（飘心 + 统计刷新）
    [self.view addSubview:self.chatInputContainerView];
    self.heartAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(showHeart) userInfo:nil repeats:YES];
    self.statsRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(reloadRoomMessage) userInfo:nil repeats:YES];

}
-(void)clickLinkBtn {
    BOOL micSwitch = [SWLinkmicManager shareInstance].linkSwitch;
    if (micSwitch == NO) {
        [self showLinkAlert];
    }else {
        [self showApplyView];
    }
}

-(void)showApplyView {
    // 展示连麦申请面板并清理红点状态
    BOOL isLinking = [SWLinkmicManager shareInstance].isLinking;
    if(_linkMicUserView){
        [MBProgressHUD showError:@"当前用户正在连麦，请先结束连麦"];
        return;
    }
    if (self.anchorMoreMenuView) {
        self.anchorMoreMenuView.hidden = YES;
    }
    if (!self.linkRequestView) {
        self.linkRequestView = [[SWLinkApplyView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andLiveUid:[SWConfig getOwnID]];
        self.linkRequestView.delegate = self;
        [self.view addSubview:self.linkRequestView];
    }
    [self.linkRequestView show];
    [self.view bringSubviewToFront:self.linkRequestView];

    // 已读
    [[SWLinkmicManager shareInstance] resetNums];
    [self judgeRedShow];
}
-(void)showLinkAlert {
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:@"确定开启观众连麦吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertContro addAction:cancleAction];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 开启
        [[SWLinkmicManager shareInstance] livemicSwitch:1];
        // socket
        [self.liveSocket linkMicSocket:8 andParam:@{}];
    }];
    [cancleAction setValue:RGB_COLOR(@"#323232", 1) forKey:@"_titleTextColor"];
    [sureAction setValue:normalColors forKey:@"_titleTextColor"];
    [alertContro addAction:sureAction];
    [self presentViewController:alertContro animated:YES completion:nil];
}


-(UIView *)chatInputContainerView{
    if (!_chatInputContainerView) {
        _chatInputContainerView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, 50)];
        _chatInputContainerView.backgroundColor = [UIColor whiteColor];
        _chatInputTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 7, _window_width-20, 36)];
        _chatInputTextField.font = SYS_Font(14);
        _chatInputTextField.placeholder = @"说点什么...";
        _chatInputTextField.delegate = self;
        _chatInputTextField.returnKeyType = UIReturnKeySend;
        _chatInputTextField.layer.cornerRadius = 18;
        _chatInputTextField.layer.masksToBounds = YES;
        _chatInputTextField.leftViewMode = UITextFieldViewModeAlways;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 18, 36)];
        _chatInputTextField.leftView = view;
        _chatInputTextField.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
        [_chatInputContainerView addSubview:_chatInputTextField];
    }
    return _chatInputContainerView;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.isMuted) {
        [MBProgressHUD showError:@"你已被禁言"];
        [textField resignFirstResponder];
        return NO;
    }
    
    [textField resignFirstResponder];
    if (textField.text.length > 0) {
        [self.liveSocket sendMessage:textField.text andisAtt:@"0" userType:kAnchorUser];
        textField.text = @"";
    }
    return YES;
}
-(UITableView *)chatTableView{
    if (!_chatTableView) {
        _chatTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _chatTableView.delegate = self;
        _chatTableView.dataSource = self;
        _chatTableView.backgroundColor = [UIColor clearColor];
        _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _chatTableView.showsVerticalScrollIndicator = NO;
        _chatTableView.estimatedRowHeight = 80.0;
        _chatTableView.clipsToBounds = YES;

    }
    return _chatTableView;;
}
- (void)showGoodsBtnAnimaition{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //速度控制函数，控制动画运行的节奏
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = 0.7;       //执行时间
    animation.repeatCount = 99999999;      //执行次数
    animation.autoreverses = YES;    //完成动画后会回到执行动画之前的状态
    animation.fromValue = [NSNumber numberWithFloat:0.7];   //初始伸缩倍数
    animation.toValue = [NSNumber numberWithFloat:1.1];     //结束伸缩倍数
    [self.goodsButton.imageView.layer addAnimation:animation forKey:nil];
}

//直播间左上角视图
- (void)addLeftView{
    UIView *leftView = [[UIView alloc]init];
    leftView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    leftView.layer.cornerRadius = 17;
    [self.liveRoomContainerView addSubview:leftView];
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.liveRoomContainerView).offset(10);
        make.top.equalTo(self.liveRoomContainerView).offset(25+statusbarHeight);
        make.height.mas_equalTo(34);
    }];
    UIImageView *iconImgView = [[UIImageView alloc]init];
    iconImgView.layer.cornerRadius = 15;
    iconImgView.layer.masksToBounds = YES;
    iconImgView.contentMode = UIViewContentModeScaleAspectFill;
    iconImgView.clipsToBounds = YES;
    [iconImgView sd_setImageWithURL:[NSURL URLWithString:[SWConfig getavatar]]];
    [leftView addSubview:iconImgView];
    [iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(leftView).offset(2);
        make.width.height.mas_equalTo(30);
    }];
    
    UILabel *nameL = [[UILabel alloc]init];
    nameL.font = SYS_Font(14);
    nameL.textColor = [UIColor whiteColor];
    nameL.text = [SWConfig getOwnNicename];
    [leftView addSubview:nameL];
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconImgView).offset(3);
        make.left.equalTo(iconImgView.mas_right).offset(4);
        make.right.lessThanOrEqualTo(leftView).offset(-14);
    }];
    
    UIImageView *likeImgView = [[UIImageView alloc]init];
    likeImgView.image = [UIImage imageNamed:@"likeImage"];
    likeImgView.contentMode = UIViewContentModeScaleAspectFit;
    [leftView addSubview:likeImgView];
    [likeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameL);
        make.width.height.mas_equalTo(9);
        make.bottom.equalTo(iconImgView).offset(-1);
    }];
    self.likesCountLabel = [[UILabel alloc]init];
    self.likesCountLabel.font = SYS_Font(10);
    self.likesCountLabel.textColor = [UIColor whiteColor];
    self.likesCountLabel.text = @"0";
    [leftView addSubview:self.likesCountLabel];
    [self.likesCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(likeImgView);
        make.left.equalTo(likeImgView.mas_right).offset(4);
        make.right.lessThanOrEqualTo(leftView).offset(-14);
    }];
    
    UIView *sellerGoodsNumsView = [[UIView alloc]init];
    sellerGoodsNumsView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    sellerGoodsNumsView.layer.cornerRadius = 11;
    [self.liveRoomContainerView addSubview:sellerGoodsNumsView];
    [sellerGoodsNumsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftView);
        make.top.equalTo(leftView.mas_bottom).offset(10);
        make.height.mas_equalTo(22);
    }];
    UILabel *sellerTipsL = [[UILabel alloc]init];
    sellerTipsL.font = SYS_Font(10);
    sellerTipsL.textColor = [UIColor whiteColor];
    sellerTipsL.text = @"本场销售商品：";
    [sellerGoodsNumsView addSubview:sellerTipsL];
    [sellerTipsL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sellerGoodsNumsView);
        make.left.equalTo(sellerGoodsNumsView).offset(10);
    }];

    self.soldGoodsCountLabel = [[UILabel alloc]init];
    self.soldGoodsCountLabel.font = SYS_Font(10);
    self.soldGoodsCountLabel.textColor = normalColors;
    self.soldGoodsCountLabel.text = @"0";
    [sellerGoodsNumsView addSubview:self.soldGoodsCountLabel];
    [self.soldGoodsCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sellerGoodsNumsView);
        make.left.equalTo(sellerTipsL.mas_right);
        make.right.lessThanOrEqualTo(sellerGoodsNumsView).offset(-10);
    }];

}
//展示底部按钮
- (void)showBTN{
    self.closeRoomButton.hidden = NO;
    self.userCountLabel.hidden = NO;
    self.chatButton.hidden = NO;
    self.moreButton.hidden = NO;
    self.goodsButton.hidden = NO;
    self.linkButton.hidden = NO;
    self.linkEndButton.hidden = !self.shouldShowEndLinkButton;
}
//隐藏底部按钮
- (void)hideBTN{
    self.closeRoomButton.hidden = YES;
    self.userCountLabel.hidden = YES;
    self.chatButton.hidden = YES;
    self.moreButton.hidden = YES;
    self.goodsButton.hidden = YES;
    self.linkButton.hidden = YES;
    self.linkEndButton.hidden = YES;
}
#pragma mark - 警告弹窗
- (void)jinggaoUser:(NSString *)content{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:content preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - 在线用户列表相关
- (void)checkUseList{
    if (!self.onlineUserListView) {
        self.onlineUserListView = [[SWLiveOnlineList alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height) stream:self.roomInfoMap[@"stream"] liveUID:[SWConfig getOwnID]];
        self.onlineUserListView.delegate = self;
    }
    [self.onlineUserListView requestData];
    [self.view addSubview:self.onlineUserListView];
}
//delegate
- (void)showUserToast:(SWChatModel *)model {
    [self showUserPopupView:model isonline:YES];
}

#pragma mark -- 改变开播按钮的状态
- (void)changeStartLiveButtonState{
    if (self.previewThumbnailImage && self.liveTitleTextView.text.length > 0 && ![self.selectedLiveClassId isEqual:@"未选择"]) {
        self.startLiveButton.userInteractionEnabled = YES;
        self.startLiveButton.alpha = 1;
    }else{
        self.startLiveButton.userInteractionEnabled = NO;
        self.startLiveButton.alpha = 0.5;
    }
}
#pragma mark -- tableView相关
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _chatMessageList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
       SWChatMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatMsgCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWChatMsgCell" owner:nil options:nil] lastObject];
    }
    
    SWChatModel *models = _chatMessageList[indexPath.row];

    cell.model =models;
    
    return cell;


}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SWChatModel *model = _chatMessageList[indexPath.row];
    if (model.userID && model.userID.length > 0 && ![model.userID isEqual:[SWConfig getOwnID]]) {
        [self showUserPopupView:model isonline:NO];
    }
}
#pragma mark -- 用户弹窗相关
- (void)showUserPopupView:(SWChatModel *)model isonline:(BOOL)isOnline{
    if (self.userPopupView) {
        [self.userPopupView removeFromSuperview];
        self.userPopupView = nil;
    }
    self.userPopupView = [[SWUserPopupView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andModel:model liveUid:[SWConfig getOwnID]];
    self.userPopupView.delegate = self;
    self.userPopupView.isOnlineUser = isOnline;
    [self.view addSubview:self.userPopupView];
}
- (void)removeUserPopupView{
    [self.userPopupView removeFromSuperview];
    self.userPopupView = nil;
}
- (void)doShutupUser:(NSString *)userID andUserName:(NSString *)uname content:(nonnull NSString *)content{
    [self.liveSocket shutUpUser:userID andName:uname andAction:@"1" content:content];
}
-(void)doKickUser:(NSString *)userID andUserName:(NSString *)uname{
    [self.liveSocket kickUser:userID andName:uname];
}
- (void)doCancleShutupUser:(NSString *)userID andUserName:(NSString *)uname{
    NSString *content = [NSString stringWithFormat:@"%@被解除禁言",uname];
    [self.liveSocket shutUpUser:userID andName:uname andAction:@"2" content:content];
}
//禁言
- (void)anchorShutUser:(NSString *)touid andAction:(int)action content:(NSString *)content{
    if ([touid isEqual:[SWConfig getOwnID]]) {
        if (action == 1) {
            self.isMuted = YES;
            [MBProgressHUD showError:@"你已被禁言"];
        }else if (action == 2){
            self.isMuted = NO;
            [MBProgressHUD showError:@"你已解除禁言"];
        }
    }
    NSDictionary *chatMap = @{
        @"contentChat":content,
        @"userName":@"",
        @"userID":@"",
        @"type":@"1",
        @"icon":@"",
        @"isattent":@"0",
    };
    SWChatModel *model = [[SWChatModel alloc]initWithDictionary:chatMap];
    [_chatMessageList addObject:model];
    if (_chatMessageList.count > 100) {
        [_chatMessageList removeObjectAtIndex:1];
    }
    [_chatTableView reloadData];
    [self jumpLast];
    
}
//踢出房间
- (void)anchorKickUser:(NSString *)touid{
    
}
- (void)setAdminUser:(NSString *)userID andUserName:(NSString *)uname{
    [self.liveSocket setAdmin:userID andName:uname];
}
-(void)cancelAdminUser:(NSString *)userID andUserName:(NSString *)uname{
    [self.liveSocket cancelSetAdmin:userID andName:uname];
}
#pragma mark -- 回到后台
-(void)backgroundselector{
    self.backgroundElapsedTime +=1;
    NSLog(@"返回后台时间%d",self.backgroundElapsedTime);
    if (self.backgroundElapsedTime > 60) {
        [self getCloseShow];
    }
}
-(void)backGround{
    //进入后台
    if (!self.backgroundTimer) {
        [self sendEmccBack];
        self.backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(backgroundselector) userInfo:nil repeats:YES];
    }
}
-(void)forwardGround{
    if (self.backgroundElapsedTime != 0) {
//        [self.liveSocket sendMessage:@"主播回来了"];
    }
    //进入前台
    if (self.backgroundElapsedTime > 60) {
        [self getCloseShow];
    }
    [self.backgroundTimer invalidate];
    self.backgroundTimer  = nil;
    self.backgroundElapsedTime = 0;
}
-(void)appactive{
    NSLog(@"哈哈哈哈哈哈哈哈哈哈哈哈 app回到前台");
    [self.liveSocket sendRoomSystemNotMessage:@"主播回来了！"];
    [_txLivePusher resumeVideo];
}
-(void)appnoactive{
    [self.liveSocket sendRoomSystemNotMessage:@"主播离开一下，精彩不中断，不要走开哦"];
    [_txLivePusher pauseVideo];
    NSLog(@"0000000000000000000 app进入后台");
}
-(void)sendEmccBack {
//    [self.liveSocket phoneCall:YZMsg(@"主播离开一下，精彩不中断，不要走开哦")];
}

#pragma mark ============电话监听=============
- (void)reciverPhoneCall{
    [self appnoactive];
}
- (void)phoneCallEnd{
    [self appactive];

}
#pragma mark -- 关闭直播
- (void)showCloseAlert{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:@"确定退出直播吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertContro addAction:cancleAction];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getCloseShow];
    }];
    [sureAction setValue:normalColors forKey:@"_titleTextColor"];
    [alertContro addAction:sureAction];
    [self presentViewController:alertContro animated:YES completion:nil];

}
-(void)getCloseShow
{
    // 1) 请求服务端关播并清理本地资源
    [MBProgressHUD showMessage:@""];
    [SWToolClass postNetworkWithUrl:@"live/stop" andParameter:@{@"stream":minstr([self.roomInfoMap valueForKey:@"stream"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        [self.liveSocket closeRoom];//发送关闭直播的socket
        [self.liveSocket closeSocket];//注销socket
        self.liveSocket = nil;//注销socket
        [self txStopRtmp];
        [self invalidateTimer];
        [self requestLiveAllTimeandVotes];
        // 服务端在关播处处理
        [[SWLinkmicManager shareInstance] livemicStop];
    } fail:^{
        [self.liveSocket closeRoom];//发送关闭直播的socket
        [self.liveSocket closeSocket];//注销socket
        self.liveSocket = nil;//注销socket
        [self txStopRtmp];
        [self invalidateTimer];
        [self requestLiveAllTimeandVotes];
        //
        [[SWLinkmicManager shareInstance] livemicStop];
    }];
    [SWLinkmicManager shareInstance].isLinking = NO;

#warning rk_是否需要？
    // 关播-关闭连麦开关
    if ([SWLinkmicManager shareInstance].linkSwitch) {
        [[SWLinkmicManager shareInstance] livemicSwitch:0];
    }

}
#pragma mark -- 注销计时器
- (void)invalidateTimer{
    if (self.heartAnimationTimer) {
        [self.heartAnimationTimer invalidate];
        self.heartAnimationTimer = nil;
    }
    if (self.backgroundTimer) {
        [self.backgroundTimer invalidate];
        self.backgroundTimer = nil;
    }
    if (self.statsRefreshTimer) {
        [self.statsRefreshTimer invalidate];
        self.statsRefreshTimer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
#pragma mark ================ 直播结束 ===============
- (void)requestLiveAllTimeandVotes{
    NSString *url = [NSString stringWithFormat:@"live/stopinfo?stream=%@",minstr([self.roomInfoMap valueForKey:@"stream"])];
    [SWToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [self lastview:info];
        }else{
            [self lastview:nil];
        }
    } Fail:^{
        [self lastview:nil];
    }];
    

}
-(void)lastview:(NSDictionary *)summaryMap{
    //无数据都显示0
    if (!summaryMap) {
        summaryMap = @{@"length":@"0",@"nums":@"0"};
    }
    UIImageView *lastView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    lastView.userInteractionEnabled = YES;
    [lastView sd_setImageWithURL:[NSURL URLWithString:minstr([self.roomInfoMap valueForKey:@"thumb"])]];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = CGRectMake(0, 0,_window_width,_window_height);
    [lastView addSubview:effectview];
    
    
    UILabel *labell= [[UILabel alloc]initWithFrame:CGRectMake(0,24+statusbarHeight, _window_width, _window_height*0.17)];
    labell.textColor = normalColors;
    labell.text = @"直播已结束";
    labell.textAlignment = NSTextAlignmentCenter;
    labell.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    [lastView addSubview:labell];
    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(_window_width*0.1, labell.bottom+50, _window_width*0.8, _window_width*0.8*8/13)];
    backView.backgroundColor = RGB_COLOR(@"#000000", 0.2);
    backView.layer.cornerRadius = 5.0;
    backView.layer.masksToBounds = YES;
    [lastView addSubview:backView];
    
    UIImageView *headerImgView = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width/2-50, labell.bottom, 100, 100)];
    [headerImgView sd_setImageWithURL:[NSURL URLWithString:[SWConfig getavatar]] placeholderImage:[UIImage imageNamed:@"bg1"]];
    headerImgView.layer.masksToBounds = YES;
    headerImgView.layer.cornerRadius = 50;
    [lastView addSubview:headerImgView];

    
    UILabel *nameL= [[UILabel alloc]initWithFrame:CGRectMake(0,50, backView.width, backView.height*0.55-50)];
    nameL.textColor = [UIColor whiteColor];
    nameL.text = [SWConfig getOwnNicename];
    nameL.textAlignment = NSTextAlignmentCenter;
    nameL.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    [backView addSubview:nameL];

    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(10, nameL.bottom, backView.width-20, 1) andColor:RGB_COLOR(@"#585452", 1) andView:backView];
    
    NSArray *labelArray = @[@"直播时长",@"观看人数"];
    for (int i = 0; i < labelArray.count; i++) {
        UILabel *topLabel = [[UILabel alloc]initWithFrame:CGRectMake(i*backView.width/2, nameL.bottom, backView.width/2, backView.height/4)];
        topLabel.font = [UIFont boldSystemFontOfSize:18];
        topLabel.textColor = [UIColor whiteColor];
        topLabel.textAlignment = NSTextAlignmentCenter;
        if (i == 0) {
            topLabel.text = minstr([summaryMap valueForKey:@"length"]);
        }
//        if (i == 1) {
//            topLabel.text = minstr([dic valueForKey:@"votes"]);
//        }
        if (i == 1) {
            topLabel.text = minstr([summaryMap valueForKey:@"nums"]);
        }
        [backView addSubview:topLabel];
        UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(topLabel.left, topLabel.bottom, topLabel.width, 14)];
        footLabel.font = [UIFont systemFontOfSize:13];
        footLabel.textColor = RGB_COLOR(@"#cacbcc", 1);
        footLabel.textAlignment = NSTextAlignmentCenter;
        footLabel.text = labelArray[i];
        [backView addSubview:footLabel];
    }
    
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(_window_width*0.1,_window_height *0.75, _window_width*0.8,40);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(doNewRoom) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:normalColors];
//    [button setBackgroundImage:[UIImage imageNamed:@"startLive_back"]];

    [button setTitle:@"返回首页" forState:0];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.layer.cornerRadius = 20;
    button.layer.masksToBounds  =YES;
    [lastView addSubview:button];
    [self.view addSubview:lastView];
    
}
- (void)doNewRoom{
    [self.navigationController popToRootViewControllerAnimated:YES];
//    SWLivebroadViewController *vc = [[SWLivebroadViewController alloc]init];
//    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

}
#pragma mark ================ 直播结束 ===============

#pragma mark -- 展示输入框
- (void)showToolbarView{
    if (self.anchorMoreMenuView) {
        self.anchorMoreMenuView.hidden = YES;
        self.moreButton.selected = NO;
    }
    [_chatInputTextField becomeFirstResponder];
//    NSDictionary *dic = @{
//        @"id":@"1",
//        @"userName":@"张三",
//        @"contentChat":@"sdffwewfewffw水电费舒舒服服是分身乏术分身乏术三方分身乏术分身乏术防辐射啥地方放松放松放松",
//        @"type":@"1",
//        @"isAnchor":@"1",
//        @"uhead":@""
//    };
//    SWChatModel *model = [[SWChatModel alloc]initWithDictionary:dic];
//    [_chatMessageList addObject:model];
//    [_chatTableView reloadData];
//    [self jumpLast];
}
- (void)jumpLast{
    [_chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_chatMessageList.count-1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom animated:NO];

}
#pragma mark -- 底部更多按钮点击
- (void)showmoreview{
    if (!self.anchorMoreMenuView) {
        self.anchorMoreMenuView = [[SWAnchorMoreMenuView alloc]initWithFrame:CGRectMake(10, _window_height-46-ShowDiff-100, _window_width-20, 97.5)];
        WeakSelf;
        self.anchorMoreMenuView.block = ^(NSString * _Nonnull name) {
            if ([name isEqual:@"翻转"]) {
                [weakSelf rotateCamera];
            }
            if ([name isEqual:@"闪光灯"]) {
                [weakSelf toggleTorch];
            }
            if ([name isEqual:@"美颜"]) {
                [weakSelf showFitterView];
            }
            if ([name isEqual:@"分享"]) {
                [weakSelf doShare];
            }
            self.anchorMoreMenuView.hidden = YES;
            self.moreButton.selected = NO;
        };
        [self.view addSubview:self.anchorMoreMenuView];
    }
    self.anchorMoreMenuView.isTorch = self.isTorch;
    self.anchorMoreMenuView.hidden = NO;
    self.moreButton.selected = YES;

}
#pragma mark -- 闪光灯
-(void)toggleTorch{
    self.isTorch = !self.isTorch;
    /*
    if (![_txLivePublisher toggleTorch:isTorch]) {
        self.isTorch = !self.isTorch;
    }
    */
    TXDeviceManager *deviceManager = [_txLivePusher getDeviceManager];
    BOOL isTorSupported = [deviceManager isCameraTorchSupported];
    if (isTorSupported) {
        [deviceManager enableCameraTorch:self.isTorch];
    }else{
        self.isTorch = !self.isTorch;
        [MBProgressHUD showError:@"只有后置摄像头才能开启闪光灯"];
    }

}
#pragma mark -- 分享

- (void)showShareAlert:(NSString *)linkText{
    JJShareLiveLinkView *SWShareView = JJShareLiveLinkView.new;
    SWShareView.linkText = linkText;
    SWShareView.doneBlock = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD showSuccess:@"复制链接成功"];
        });
    };
    [SWShareView show];
}

- (void)doShare{
    //杨剑修改，分享
    [MBProgressHUD showMessage:@""];
    NSString *uid = minstr([self.roomInfoMap valueForKey:@"uid"]);
    NSString *stream = minstr([self.roomInfoMap valueForKey:@"stream"]);
    NSString *restApiPath = [NSString stringWithFormat:@"/#/home?redirect=%%2Flive%%2Fdetail%%3Fuid%%3D%@%%26stream%%3D%@",uid,stream];
    [SWToolClass getQCloudNoTokenWithUrl:@"/frontend" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        NSString *restApi = h5share_url;
        if (code == 200) {
            NSString *newRestApi = minstr([info valueForKey:@"frontend_url"] );
            restApi = newRestApi;
        }
        NSString *linkText = [NSString stringWithFormat:@"%@%@",restApi,restApiPath];
        [self showShareAlert:linkText];
    } Fail:^{
        [MBProgressHUD hideHUD];
        NSString *linkText = [NSString stringWithFormat:@"%@%@",h5share_url,restApiPath];
        [self showShareAlert:linkText];
    }];

    
    

//    if (!shareV) {
//        shareV = [[SWShareView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andRoomMessage:self.roomInfoMap];
//        [self.view addSubview:shareV];
//    }else{
//        [shareV show];
//    }
}
#pragma mark -- 底部商品按钮点击
- (void)showgoodsShowView{
    if (self.anchorMoreMenuView) {
        self.anchorMoreMenuView.hidden = YES;
    }
    if (!self.liveGoodsPanelView) {
        self.liveGoodsPanelView = [[SWLiveGoodsView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andLiveUid:[SWConfig getOwnID]];
        [self.view addSubview:self.liveGoodsPanelView];
    }
    [self.liveGoodsPanelView show];
}
#pragma mark -- 飘心展示
- (void)showHeart{
    self.heartBurstCount = arc4random()%5 + 1;
    [self socketLight];
}
-(void)socketLight{
    CGFloat starX = self.goodsButton.frame.origin.x ;
    CGFloat starY = self.goodsButton.frame.origin.y - 30;
    UIImageView *starImage = [[UIImageView alloc]initWithFrame:CGRectMake(starX, starY, 30, 30)];
    starImage.contentMode = UIViewContentModeScaleAspectFit;
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"plane_heart_no1.png",@"plane_heart_no2.png",@"plane_heart_no3.png",@"plane_heart_no4.png",@"plane_heart_no5.png", nil];
    NSInteger random = arc4random()%array.count;
    starImage.image = [UIImage imageNamed:[array objectAtIndex:random]];
    [UIView animateWithDuration:0.2 animations:^{
        starImage.alpha = 1.0;
        starImage.frame = CGRectMake(starX+random - 10, starY-random - 30, 30, 30);
        CGAffineTransform transfrom = CGAffineTransformMakeScale(1.3, 1.3);
        starImage.transform = CGAffineTransformScale(transfrom, 1, 1);
    }];
    [self.liveRoomContainerView addSubview:starImage];
    CGFloat finishX = _window_width - round(arc4random() % 200);
    //  动画结束点的Y值
    CGFloat finishY = 200;
    //  imageView在运动过程中的缩放比例
    CGFloat scale = round(arc4random() % 2) + 0.7;
    // 生成一个作为速度参数的随机数
    CGFloat speed = 1 / round(arc4random() % 900) + 0.6;
    //  动画执行时间
    NSTimeInterval duration = 4 * speed;
    //  如果得到的时间是无穷大，就重新附一个值（这里要特别注意，请看下面的特别提醒）
    if (duration == INFINITY) duration = 2.412346;
    //  开始动画
    [UIView beginAnimations:nil context:(__bridge void *_Nullable)(starImage)];
    //  设置动画时间
    [UIView setAnimationDuration:duration];
    
    
    //  设置imageView的结束frame
    starImage.frame = CGRectMake( finishX, finishY, 30 * scale, 30 * scale);
    
    //  设置渐渐消失的效果，这里的时间最好和动画时间一致
    [UIView animateWithDuration:duration animations:^{
        starImage.alpha = 0;
    }];
    
    //  结束动画，调用onAnimationComplete:finished:context:函数
    [UIView setAnimationDidStopSelector:@selector(onAnimationComplete:finished:context:)];
    //  设置动画代理
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
    self.heartBurstCount --;
    if (self.heartBurstCount > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self socketLight];
        });
    }
}
/// 动画完后销毁iamgeView
- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    UIImageView *imageViewsss = (__bridge UIImageView *)(context);
    [imageViewsss removeFromSuperview];
    imageViewsss = nil;
}
#pragma mark -- 键盘通知
- (void)keyboardWillShow:(NSNotification *)aNotification
{

    [self hideBTN];
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.origin.y;
    WeakSelf;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.chatInputContainerView.y = height-50;
    }];
}
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [self showBTN];
    WeakSelf;
    [UIView animateWithDuration:0.1 animations:^{
        weakSelf.chatInputContainerView.y = _window_height;
    }];
}
#pragma mark -- 送礼物效果
-(void)sendGift:(NSDictionary *)msg andLiansong:(NSString *)liansong andTotalCoin:(NSString *)votestotal andGiftInfo:(NSDictionary *)giftInfo andCt:(NSDictionary *)ct{

    NSString *type = minstr([ct valueForKey:@"type"]);
    NSMutableDictionary *giftMap = [NSMutableDictionary dictionaryWithDictionary:ct];
    [giftMap setObject:msg[@"uhead"] forKey:@"avatar"];
    [giftMap setObject:giftInfo[@"nicename"] forKey:@"nicename"];
    if ([type isEqual:@"1"]) {
        [self expensiveGift:giftMap.copy isPlatGift:NO];
    }else{
        if (!self.continueGiftView) {
            self.continueGiftView = [[SWContinueGift alloc]init];
            [self.continueGiftContainerView addSubview:self.continueGiftView];
            //初始化礼物空位
            [self.continueGiftView initGift];
        }
        [self.continueGiftView GiftPopView:giftMap.copy andLianSong:liansong];
    }
}
-(void)expensiveGiftdelegate:(NSDictionary *)giftData{
    if (!self.expensiveGiftView) {
        self.expensiveGiftView = [[SWExpensiveGiftV alloc]initWithIsPlat:NO];
        self.expensiveGiftView.delegate = self;
        [self.view addSubview:self.expensiveGiftView];
        CGAffineTransform t = CGAffineTransformMakeTranslation(_window_width, 0);
        self.expensiveGiftView.transform = t;
    }
    if (giftData == nil) {
        
        
        
    }
    else
    {
        [self.expensiveGiftView addArrayCount:giftData];
    }
    if(self.expensiveGiftView.haohuaCount == 0){
        [self.expensiveGiftView enGiftEspensive:NO];
    }
}
-(void)expensiveGift:(NSDictionary *)giftData isPlatGift:(BOOL)isPlat{
    
    
    if (!self.expensiveGiftView) {
        self.expensiveGiftView = [[SWExpensiveGiftV alloc]initWithIsPlat:isPlat];
        self.expensiveGiftView.delegate = self;
        [self.view insertSubview:self.expensiveGiftView atIndex:8];
    }
    if (giftData == nil) {
    }
    else
    {
        [self.expensiveGiftView addArrayCount:giftData];
    }
    if(self.expensiveGiftView.haohuaCount == 0){
        [self.expensiveGiftView enGiftEspensive:isPlat];
    }
}

#pragma mark -- 获取直播间人数
- (void)getRoomUserNums{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"livenums?stream=%@",minstr([self.roomInfoMap valueForKey:@"stream"])] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.userCountLabel.text = [NSString stringWithFormat:@"  %@人  ",minstr([info valueForKey:@"nums"])];

        }
    } Fail:^{
        
    }];
}
#pragma mark -- 获取直播间点赞数
- (void)getRoomLikeNums{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"livelikes?stream=%@",minstr([self.roomInfoMap valueForKey:@"stream"])] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.likesCountLabel.text = minstr([info valueForKey:@"nums"]);
        }
    } Fail:^{
        
    }];

}
#pragma mark -- 获取直播间销售商品数
- (void)getRoomSellerGoodsNums{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"livegoodsnums?stream=%@",minstr([self.roomInfoMap valueForKey:@"stream"])] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.soldGoodsCountLabel.text = minstr([info valueForKey:@"nums"]);
        }
    } Fail:^{
        
    }];

}
#pragma mark -- 检测直播状态，防止断流或者其他情况服务端给主播关播了 主播还在直播
- (void)checkLiveState{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"checklive?stream=%@",minstr([self.roomInfoMap valueForKey:@"stream"])] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            if (![minstr([info valueForKey:@"islive"]) isEqual:@"1"]) {
                [self getCloseShow];
            }
        }
    } Fail:^{
        
    }];

}
- (void)reloadRoomMessage{
    // 定时拉取直播间统计数据
    [self getRoomLikeNums];
    [self getRoomUserNums];
    [self getRoomSellerGoodsNums];
    // 移除自动检测直播状态，防止误判退出
    // [self checkLiveState];
}


#pragma mark -- socket代理相关
-(void)setAdmin:(NSDictionary *)msg action:(NSString *)action{
    NSString *touid = [NSString stringWithFormat:@"%@",[msg valueForKey:@"touid"]];

    if ([touid isEqual:[SWConfig getOwnID]]) {
//        if ([action isEqual:@"0"]) {
//            usertype = @"0";
//        }else{
//            usertype = @"40";
//        }
    }
    /*
    NSDictionary *chatMap = @{
        @"contentChat":minstr(msg[@"ct"]),
        @"userName":@"",
        @"userID":@"",
        @"type":@"1",
        @"icon":@"",
        @"isattent":@"0",
        
    };
    SWChatModel *model = [[SWChatModel alloc]initWithDictionary:chatMap];
    [_chatMessageList addObject:model];
    if (_chatMessageList.count > 100) {
        [_chatMessageList removeObjectAtIndex:1];
    }
    [_chatTableView reloadData];
    [self jumpLast];
     */
}
//聊天消息
- (void)receiveMessage:(NSDictionary *)messageMap {
    // 统一将 socket 原始消息映射为聊天模型
    NSDictionary *chatMap;
    if ([minstr([messageMap valueForKey:@"_method_"]) isEqual:@"SystemNot"]) {
        chatMap = @{
            @"contentChat":minstr([messageMap valueForKey:@"ct"]),
            @"userName":@"",
            @"userID":@"",
            @"type":@"1",
            @"icon":@"",
            @"isattent":@"0",
        };
    }
    else if ([minstr([messageMap valueForKey:@"_method_"]) isEqual:@"SendMsg"]) {
        chatMap = @{
            @"contentChat":minstr([messageMap valueForKey:@"content"]),
            @"userName":minstr([messageMap valueForKey:@"usernickname"]),
            @"userID":minstr([messageMap valueForKey:@"uid"]),
            @"type":@"2",
            @"icon":minstr([messageMap valueForKey:@"avatar"]),
            @"isattent":minstr([messageMap valueForKey:@"isattent"]),
            @"usertype":minstr(messageMap[@"usertype"])
        };
    }
    else if ([minstr([messageMap valueForKey:@"_method_"]) isEqual:@"SendLight"]) {
        chatMap = @{
            @"contentChat":@"点亮了",
            @"userName":minstr([messageMap valueForKey:@"usernickname"]),
            @"userID":minstr([messageMap valueForKey:@"uid"]),
            @"type":@"4",
            @"icon":minstr([messageMap valueForKey:@"avatar"]),
            @"isattent":minstr([messageMap valueForKey:@"isattent"]),
        };

    }
    if (chatMap) {
        SWChatModel *model = [[SWChatModel alloc]initWithDictionary:chatMap];
        [_chatMessageList addObject:model];
        if (_chatMessageList.count > 100) {
            [_chatMessageList removeObjectAtIndex:1];
        }
        [_chatTableView reloadData];
        [self jumpLast];
    }
}
//用户进入
- (void)userEnterRoom:(NSDictionary *)userMap {
    NSDictionary *ct = [userMap valueForKey:@"ct"];
    if (![minstr([ct valueForKey:@"uid"]) isEqual:[SWConfig getOwnID]]) {
        NSDictionary *chatMap = @{
            @"contentChat":@"进入了直播间",
            @"userName":minstr([ct valueForKey:@"name"]),
            @"userID":minstr([ct valueForKey:@"uid"]),
            @"type":@"3",
            @"icon":minstr([ct valueForKey:@"avatar"]),
            @"isattent":minstr([ct valueForKey:@"isattent"]),
        };
        SWChatModel *model = [[SWChatModel alloc]initWithDictionary:chatMap];
        [_chatMessageList addObject:model];
        if (_chatMessageList.count > 100) {
            [_chatMessageList removeObjectAtIndex:1];
        }
        [_chatTableView reloadData];
        [self jumpLast];
    }

}
//用户离开
- (void)userLeaveRoom {
}
///直播关闭
- (void)LiveEnd{
    [self getCloseShow];
}

- (void)shajincheng{
    [self getCloseShow];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - 连麦
// 同意连麦
- (void)agreeUserLink:(NSDictionary *)userInfo {
    if (self.linkRequestView) {
        [self.linkRequestView diHide];
    }
    NSString *userid = minstr([userInfo valueForKey:@"uid"]);
    [[SWLinkmicManager shareInstance] livemicManage:YES andUserid:userid handle:^(LinkEvent event, int eventCode, NSDictionary *eventMap) {
        if (eventCode == 0) {
            self.shouldShowEndLinkButton = true;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.linkEndButton.hidden = NO;
            });
            
            // socket
            [self.liveSocket linkMicSocket:3 andParam:@{
                @"to_uid":userid,
            }];
            [SWLinkmicManager shareInstance].isLinking = YES;
            BOOL isLinking = [SWLinkmicManager shareInstance].isLinking;
            NSLog(@"-----------------%ld",[SWLinkmicManager shareInstance].isLinking);
        }
    }];
}
- (void)closeLinkSwitch {
    self.shouldShowEndLinkButton = false;
    self.linkEndButton.hidden = YES;
    if (self.linkRequestView) {
        [self.linkRequestView diHide];
    }
    // socket
    [self.liveSocket linkMicSocket:9 andParam:@{}];
}
// 连麦窗口
-(void)createLinkUserView:(NSDictionary *)infoMap {
    [self destroyLinkUserView];

    NSDictionary *subMap = @{
        @"playurl":minstr([infoMap valueForKey:@"playurl"]),
        @"pushurl":@"0",
        @"userid":minstr([infoMap valueForKey:@"userid"]),
    };
    _linkMicUserView = [[SWLinkUserView alloc]initWithRTMPURL:subMap andFrame:CGRectMake(_window_width - 100, _window_height - 110 - ShowDiff - 150 , 100, 150) andisHOST:NO andAnToAn:NO];
    _linkMicUserView.delegate = self;
    _linkMicUserView.tag = 1500 + [[SWConfig getOwnID] intValue];
    [_linkMicUserView ctrCloseBtn:YES];
    [self.view addSubview:_linkMicUserView];
}

-(void)createTRTCLinkUserViewWithUserId:(NSString *)userId {
    // 创建 TRTC 连麦小窗（用于展示网页端用户画面）
    [self destroyLinkUserView];
    _linkMicUserView = [[SWLinkUserView alloc] initWithTRTCRemoteUserId:userId
                                                         andFrame:CGRectMake(_window_width - 100, _window_height - 110 - ShowDiff - 150 , 100, 150)
                                                        andisHOST:YES];
    _linkMicUserView.delegate = self;
    _linkMicUserView.tag = 1500 + [[SWConfig getOwnID] intValue];
    [_linkMicUserView ctrCloseBtn:YES];
    [self.view addSubview:_linkMicUserView];
}
- (void)endLinkMaic{
    NSString *uid = @"";
    if(_linkMicUserView){
        uid = _linkMicUserView.subMap[@"userid"];
    }
    // 主播关闭
    //socekt
    [self.liveSocket linkMicSocket:7 andParam:@{
        @"to_uid":uid,
    }];
    //
    [self destroyLinkUserView];
    [SWLinkmicManager shareInstance].isLinking = NO;
}
//
- (void)tx_closeuserconnect:(NSString *)uid {
    // 主播关闭
    //socekt
    [self.liveSocket linkMicSocket:7 andParam:@{
        @"to_uid":uid,
    }];
    //
    [self destroyLinkUserView];
    [SWLinkmicManager shareInstance].isLinking = NO;
}
-(void)destroyLinkUserView {
    // 关闭连麦窗口并停止 TRTC 远端订阅
    if (_linkMicUserView) {
        self.shouldShowEndLinkButton = false;
        self.linkEndButton.hidden = YES;
        if (_linkingRemoteUserId.length > 0) {
            [self trtcInitIfNeeded];
            [_trtcCloud stopRemoteView:_linkingRemoteUserId streamType:TRTCVideoStreamTypeBig];
            _linkingRemoteUserId = nil;
        }
        [_linkMicUserView stopConnect];
        [_linkMicUserView stopPush];
        [_linkMicUserView removeFromSuperview];
        _linkMicUserView = nil;
        [SWLinkmicManager shareInstance].isLinking = NO;
    }
}
//
- (void)linkmicEventSoc:(NSDictionary *)linkMap {
    // 连麦信令事件分发：申请、取消、上麦、下麦
    int action = [minstr([linkMap valueForKey:@"action"]) intValue];
    NSString *userId = minstr([linkMap valueForKey:@"uid"]);
    if (action == 1) {
        // 显示红点+1
        [[SWLinkmicManager shareInstance] applyNumsChange:YES];
        [self judgeRedShow];
    }else if(action == 2) {
        // 显示红点-1
        [[SWLinkmicManager shareInstance] applyNumsChange:NO];
        [self judgeRedShow];
    }else if (action == 5){
        // TRTC 互动连麦：直接订阅远端用户画面（网页端 TRTC Web SDK）
        _expectedRemoteUserIdFromSignal = userId;
        _linkingRemoteUserId = nil;
        [self createTRTCLinkUserViewWithUserId:userId];
        __weak typeof(self) weakSelf = self;
        [self trtcEnterRoomIfNeededThen:^(BOOL ok) {
            if (!ok) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) return;
                [strongSelf trtcInitIfNeeded];
                // 真正开始拉取以 onUserVideoAvailable 为准，这里先尝试一次（有些情况下可直接出画面）
                NSLog(@"[TRTC] try startRemoteView (signal uid=%@)", userId);
                TRTCCloud *cloud = strongSelf->_trtcCloud;
                SWLinkUserView *linkView = strongSelf->_linkMicUserView;
                if (!cloud || !linkView) return;
                [cloud startRemoteView:userId
                            streamType:TRTCVideoStreamTypeBig
                                  view:linkView.videoContainerView];
            });
        }];

    }else if(action == 6) {
        // 用户下麦
        [self destroyLinkUserView];
    }
}

-(void)judgeRedShow {
    if ([SWLinkmicManager shareInstance].currentApplayNums<=0) {
        self.linkRequestRedDotView.hidden = YES;
    }else {
        self.linkRequestRedDotView.hidden = NO;
    }
}

@end
