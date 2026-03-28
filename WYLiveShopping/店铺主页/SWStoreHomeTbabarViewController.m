//
//  SWStoreHomeTbabarViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWStoreHomeTbabarViewController.h"
#import "SWStoreHomeViewController.h"
#import "SWStoreClassViewController.h"

@interface SWStoreHomeTbabarViewController ()<UITabBarControllerDelegate>
@property (nonatomic, strong) SWStoreHomeViewController *homeViewController;
@end

@implementation SWStoreHomeTbabarViewController

- (void)doReturn {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (instancetype)initWithID:(NSString *)sid {
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

#pragma mark - 在这里更换左右tabbar的image

- (void)setUpAllChildVc {
    self.homeViewController = [SWStoreHomeViewController new];
    self.homeViewController.mer_id = self.mer_id;
    WeakSelf;
    self.homeViewController.block = ^{
        [weakSelf doReturn];
    };

    SWStoreClassViewController *classViewController = [SWStoreClassViewController new];
    classViewController.mer_id = self.mer_id;
    classViewController.block = ^{
        [weakSelf doReturn];
    };

    [self setUpOneChildVcWithVc:self.homeViewController Image:@"store-tabbar-home-nor" selectedImage:@"store-tabbar-home-sel" title:@"首页" andTag:0];
    [self setUpOneChildVcWithVc:classViewController Image:@"store-tabbar-class-nor" selectedImage:@"store-tabbar-class-sel" title:@"分类" andTag:1];
    [self setUpOneChildVcWithVc:[UIViewController new] Image:@"store-tabbar-kefu-nor" selectedImage:@"store-tabbar-kefu-nor" title:@"客服" andTag:2];
}

#pragma mark - 初始化设置tabBar上面单个按钮的方法

- (void)setUpOneChildVcWithVc:(UIViewController *)vc Image:(NSString *)image selectedImage:(NSString *)selectedImage title:(NSString *)title andTag:(int)tag {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    UIImage *normalImage = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.image = normalImage;

    UIImage *selectedTabImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.selectedImage = selectedTabImage;
    vc.tabBarItem.title = title;
    vc.navigationController.navigationBar.hidden = YES;
    vc.tabBarItem.tag = tag;
    [vc.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -5)];

    [self addChildViewController:nav];
}

- (void)setCusTintColor {
    if (@available(iOS 13.0, *)) {
        [self.tabBar setTintColor:normalColors];
        [self.tabBar setUnselectedItemTintColor:RGB_COLOR(@"#969696", 1)];
    } else {
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10], NSForegroundColorAttributeName: RGB_COLOR(@"#969696", 1)} forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10], NSForegroundColorAttributeName: normalColors} forState:UIControlStateSelected];
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    UINavigationController *nav = (UINavigationController *)viewController;
    UIViewController *topViewController = nav.topViewController;
    if ([topViewController isKindOfClass:[SWStoreHomeViewController class]] || [topViewController isKindOfClass:[SWStoreClassViewController class]]) {
        return YES;
    }
    [self doKefu];
    return NO;
}

- (void)doKefu {
    if ([self.mer_id isEqual:[SWConfig getOwnID]]) {
        [MBProgressHUD showError:@"不能与自己发送私信"];
        return;
    }
    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.userID = self.mer_id;
    if (self.homeViewController && self.homeViewController.mer_name) {
        data.title = self.homeViewController.mer_name;
    }
    TUIChatController *chat = [[TUIChatController alloc] init];
    [chat setConversationData:data];
    [[SWMXBADelegate sharedAppDelegate] pushViewController:chat animated:YES];
}

@end
