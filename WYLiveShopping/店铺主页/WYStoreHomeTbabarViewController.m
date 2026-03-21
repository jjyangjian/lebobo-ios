//
//  WYStoreHomeTbabarViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYStoreHomeTbabarViewController.h"
#import "StoreHomeViewController.h"
#import "WYStoreClassViewController.h"

@interface WYStoreHomeTbabarViewController ()<UITabBarControllerDelegate>{
    StoreHomeViewController *home;
}

@end

@implementation WYStoreHomeTbabarViewController
- (void)doReturn{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}
-(instancetype)initWithID:(NSString *)sid{
    if (self = [super init]) {
        _mer_id = sid;
        [self setUpAllChildVc];
        [self setCusTintColor];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
}
#pragma mark  在这里更换 左右tabbar的image
- (void)setUpAllChildVc {
    home = [StoreHomeViewController new];
    home.mer_id = _mer_id;
    WeakSelf;
    home.block = ^{
        [weakSelf doReturn];
    };
    WYStoreClassViewController *class = [WYStoreClassViewController new];
    class.mer_id = _mer_id;
    class.block = ^{
        [weakSelf doReturn];
    };
    [self setUpOneChildVcWithVc:home Image:@"store-tabbar-home-nor" selectedImage:@"store-tabbar-home-sel" title:@"首页" andTag:0];
    [self setUpOneChildVcWithVc:class Image:@"store-tabbar-class-nor" selectedImage:@"store-tabbar-class-sel" title:@"分类" andTag:1];
    [self setUpOneChildVcWithVc:[UIViewController new] Image:@"store-tabbar-kefu-nor" selectedImage:@"store-tabbar-kefu-nor" title:@"客服" andTag:2];

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
    myImage = [myImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //tabBarItem，是系统提供模型，专门负责tabbar上按钮的文字以及图片展示
    Vc.tabBarItem.image = myImage;
    UIImage *mySelectedImage = [UIImage imageNamed:selectedImage];
    mySelectedImage = [mySelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
        [self.tabBar setTintColor:normalColors];
        [self.tabBar setUnselectedItemTintColor:RGB_COLOR(@"#969696", 1)];
    } else {
    // Override point for customization after application launch.
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10], NSForegroundColorAttributeName:RGB_COLOR(@"#969696", 1)} forState:UIControlStateNormal];
        // 选中状态的标题颜色
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10], NSForegroundColorAttributeName:normalColors} forState:UIControlStateSelected];
    }

}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    UINavigationController *nav = (UINavigationController *)viewController;
    UIViewController *VC =nav.topViewController;
    if ([VC isKindOfClass:[StoreHomeViewController class]] || [VC isKindOfClass:[WYStoreClassViewController class]]) {
                
        return YES;
    }else{
        [self doKefu];
        return NO;
    }
    return YES;
    
}
- (void)doKefu{
    if ([_mer_id isEqual:[Config getOwnID]]) {
        [MBProgressHUD showError:@"不能与自己发送私信"];
        return;
    }
    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.userID = _mer_id;    // 如果是单聊会话，传入对方用户 ID
    if (home && home.mer_name) {
        data.title = home.mer_name;
    }
    TUIChatController *chat = [[TUIChatController alloc] init];
    [chat setConversationData:data];
//    chat.title = conversationCell.convData.title;
    [[MXBADelegate sharedAppDelegate] pushViewController:chat animated:YES];

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
