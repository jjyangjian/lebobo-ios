#import "JJAppConfigManager.h"
#import "AppDelegate.h"
#import <Bugly/Bugly.h>
#import <TXLiteAVSDK_Professional/TXLiveBase.h>
#import <TXLiteAVSDK_Professional/V2TXLivePremier.h>

@implementation JJAppConfigManager

+ (void)configIQKeyboardManager {
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

+ (void)configBugly {
    [Bugly startWithAppId:BuglyId];
}

+ (void)configNotificationsWithApplication:(UIApplication *)application appDelegate:(AppDelegate *)appDelegate {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }

    [NSNotificationCenter.defaultCenter addObserver:appDelegate selector:@selector(onTotalUnreadCountChanged:) name:TUIKitNotification_onTotalUnreadMessageCountChanged object:nil];
}

+ (void)configShareSDK {
    [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {
        [platformsRegister setupQQWithAppId:QQAppId appkey:QQAppKey enableUniversalLink:NO universalLink:QQUniversalLink];
        [platformsRegister setupWeChatWithAppId:WechatAppId appSecret:WechatAppSecret universalLink:WechatUniversalLink];
    }];
}

+ (void)configVRtxLiveParamWithAppDelegate:(AppDelegate *)appDelegate {
    [TXLiveBase sharedInstance].delegate = appDelegate;
    [V2TXLivePremier setLicence:LicenceURL key:LicenceKey];
    [V2TXLivePremier setObserver:(id)appDelegate];
    NSLog(@"[V2TXLivePremier getSDKVersionStr] = %@", [V2TXLivePremier getSDKVersionStr]);
}

+ (void)configHomeConfigWithCompletion:(void (^ __nullable)(void))completion {
    [WYToolClass getQCloudWithUrl:@"config" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            liveCommon *commons = [[liveCommon alloc] initWithDic:info];
            [common saveProfile:commons];
            if (completion) {
                completion();
            }
        }
    } Fail:^{
    }];
}

+ (void)configTXIM {
    [[TUIKit sharedInstance] setupWithAppId:[[common tx_sdkappid] integerValue]];
    TUIKitConfig *config = TUIKitConfig.defaultConfig;
    config.avatarType = 1;
    config.defaultAvatarImage = [WYToolClass getAppIcon];
}

@end
