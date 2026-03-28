//
//  ZYTabBarController.m
//  tabbar增加弹出bar
//
//  Created by tarena on 16/7/2.
//  Copyright © 2016年 张永强. All rights reserved.
//
#import "WYTabBarController.h"
#import "JJMerchantHomeVC.h"
#import "JJMineVC.h"
#import "JJStartLiveVC.h"
#import "JJHomeLiveListVC.h"
//#import "ZYTabBar.h"
#import <MHBeautySDK/MHSDK.h>
//#import "homeViewController.h"
//@import CoreLocation;
#import "JJAppConfigManager.h"
#import "JJUserConfigManager.h"
#import <TXLiteAVSDK_Professional/TXLiveBase.h>

@interface WYTabBarController ()<UITabBarDelegate,UITabBarControllerDelegate>//ZYTabBarDelegate
{
    UIAlertController *alertupdate;
}
@property(nonatomic,strong)NSString *Build;

@end
@implementation WYTabBarController
#pragma mark ============定位=============
//点击开始直播
//- (void)pathButton:(MXtabbar *)MXtabbar clickItemButtonAtIndex:(NSUInteger)itemButtonIndex {
//    if ([[Config getIsShop] isEqualToString:@"1"]) {
//        [[WYToolClass sharedInstance] removeSusPlayer];
//        LivebroadViewController *vc = [[LivebroadViewController alloc]init];
//        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
//    }else{
//        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:@"提示" message:@"你未认证开通店铺，无法进行直播" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        }];
//        [cancleAction setValue:color96 forKey:@"_titleTextColor"];
//        [alertContro addAction:cancleAction];
//        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"前往认证" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self doAuth];
//        }];
//        [sureAction setValue:normalColors forKey:@"_titleTextColor"];
//        [alertContro addAction:sureAction];
//        [self presentViewController:alertContro animated:YES completion:nil];
//
//    }
//}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self.tabBar setBackgroundColor:[UIColor whiteColor]];

    [self buildUpdate];

    self.view.backgroundColor = [UIColor whiteColor];
//    //设置子视图
    [self setUpAllChildVc];
    [self setCusTintColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [JJAppConfigManager configHomeConfigWithCompletion:^{
        if ([common tx_sdkappid]) {
            [JJAppConfigManager configTXIM];
            if ([Config getOwnUserTXIMSign]) {
                [JJUserConfigManager configIMLogin];
            }
        }
    }];
    
//    [self setTXIMSetting];
    NSLog(@"[TXLiveBase getSDKVersionStr] = %@",[TXLiveBase getSDKVersionStr]);

//    [JPUSHService setBadge:0];
//
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//
//    AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
//    [netManager startMonitoring];  //开始监听 防止第一次安装不显示
//    [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
//        if (status == AFNetworkReachabilityStatusNotReachable)
//        {
//            [self buildUpdate];
//            return;
//        }else if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable){
//            NSLog(@"nonetwork-------");
//            [self buildUpdate];
//        }else if ((status == AFNetworkReachabilityStatusReachableViaWWAN)||(status == AFNetworkReachabilityStatusReachableViaWiFi)){
//            [self buildUpdate];
//            NSLog(@"wifi-------");
//        }
//    }];

}

#pragma mark  在这里更换 左右tabbar的image
- (void)setUpAllChildVc {
    JJMerchantHomeVC *home = [JJMerchantHomeVC new];
    JJHomeLiveListVC *liveList = [JJHomeLiveListVC new];
    JJStartLiveVC *startLive = [JJStartLiveVC new];
    JJMineVC *mine = [JJMineVC new];

    [self setUpOneChildVcWithVc:home Image:@"tab_home" selectedImage:@"tab_home_sel" title:@"首页" andTag:0];
    [self setUpOneChildVcWithVc:liveList Image:@"tab_class" selectedImage:@"tab_class_sel" title:@"直播" andTag:1];
    [self setUpOneChildVcWithVc:startLive Image:@"tab_class" selectedImage:@"tab_class_sel" title:@"开始直播" andTag:2];
    [self setUpOneChildVcWithVc:mine Image:@"tab_mine" selectedImage:@"tab_mine_sel" title:@"我的" andTag:3];
}
#pragma mark - 初始化设置tabBar上面单个按钮的方法
/**
 *  @author li bo, 16/05/10
 *
 *  设置单个tabBarButton
 *
 *  @param Vc            每一个按钮对应的控制器
 *  @param image         每一个按钮对应的普通状态下图片
 *  @param selectedImage 每一个按钮对应的选中状态下的图片
 *  @param title         每一个按钮对应的标题
 */

- (void)setUpOneChildVcWithVc:(UIViewController *)Vc Image:(NSString *)image selectedImage:(NSString *)selectedImage title:(NSString *)title andTag:(int)tttttt
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:Vc];
    UIImage *myImage = [UIImage imageNamed:image];
    myImage = [myImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //tabBarItem，是系统提供模型，专门负责tabbar上按钮的文字以及图片展示
    Vc.tabBarItem.image = myImage;
    UIImage *mySelectedImage = [UIImage imageNamed:selectedImage];
    mySelectedImage = [mySelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    Vc.tabBarItem.selectedImage = mySelectedImage;
    Vc.tabBarItem.title = title;
    Vc.navigationController.navigationBar.hidden = YES;
    Vc.tabBarItem.tag = tttttt;
//    Vc.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -7);
    [Vc.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -5)];
//    [Vc.tabBarItem setImageInsets:UIEdgeInsetsMake(-5, 0, 5, 0)];
    
    [self addChildViewController:nav];
}
-(void)setCusTintColor {
    if (@available(iOS 13.0, *)) {
//        ZYTabBar *tabBar = [ZYTabBar appearance];
        [self.tabBar setTintColor:JJAPPTHEMECOLOR];
        [self.tabBar setUnselectedItemTintColor:RGB_COLOR(@"#c8c8c8", 1)];
    } else {
    // Override point for customization after application launch.
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10], NSForegroundColorAttributeName:RGB_COLOR(@"#c8c8c8", 1)} forState:UIControlStateNormal];
        // 选中状态的标题颜色
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10], NSForegroundColorAttributeName:JJAPPTHEMECOLOR} forState:UIControlStateSelected];
    }

}
//点击开始直播
-(void)buildUpdate{
   
}

//- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
//
//    NSArray * sss = self.tabBar.subviews;
//
//
//    UIView *tabbarbutton = sss[item.tag+1];
//
//
//    for (UIView *view in tabbarbutton.subviews) {
//
//
//
//        if ([view isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
//
//
//            [self.animation removeFromSuperview];
//            NSString * name = self.imgParr[item.tag];
//            CGFloat scale = [[UIScreen mainScreen] scale];
//            name = 3.0 == scale ? [NSString stringWithFormat:@"%@@3x", name] : [NSString stringWithFormat:@"%@@2x", name];
//            LOTAnimationView *animation = [LOTAnimationView animationNamed:name];
//            [view addSubview:animation];
//            animation.bounds = CGRectMake(0, 0,view.bounds.size.width,view.bounds.size.width);
//            animation.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
//            [animation playWithCompletion:^(BOOL animationFinished) {
//                // Do Something
//            }];
//            self.animation = animation;
//        }
//
//    }
//
//}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    UINavigationController *nav = (UINavigationController *)viewController;
    UIViewController *VC =nav.topViewController;
    if ([VC isKindOfClass:[JJMerchantHomeVC class]]) {
        return YES;
    }
    if (![Config getOwnID] || [[Config getOwnID] intValue] == 0) {
        [[WYToolClass sharedInstance] showLoginView];
        return NO;
    }
    return YES;
    
}
//-(NSArray *)imgParr
//{
//    if (!_imgParr) {
//        _imgParr =@[@"shouye",@"faxian",@"xiaoxi",@"wode"];
//    }
//    return _imgParr;
//}
//- (void)playVoice{
//    NSURL *soundUrl = [[NSBundle mainBundle] URLForResource:@"messageVioce" withExtension:@"mp3"];
//    SystemSoundID soundID;
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundUrl,&soundID);
//    AudioServicesPlaySystemSound(soundID);
//}
 
@end
