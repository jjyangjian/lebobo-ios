//
//  SWFindVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/27.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWFindVC.h"
#import "TYPagerController.h"
#import "TYTabPagerBar.h"
#import "SWAnliVC.h"
#import "SWFindVideoVC.h"

@interface SWFindVC ()<TYTabPagerBarDataSource,TYTabPagerBarDelegate,TYPagerControllerDataSource,TYPagerControllerDelegate>
@property (nonatomic, weak) TYTabPagerBar *tabBar;
@property (nonatomic, weak) TYPagerController *pagerController;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) NSMutableArray *controlArray;

@end

@implementation SWFindVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    self.navigationController.navigationBar.hidden = YES;
    if (SysVersion >= 11.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    self.view.backgroundColor = colorf0;
    self.controlArray = @[@"", @"", @"", @"", @""].mutableCopy;
    [self addView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.pagerController scrollToControllerAtIndex:1 animate:YES];
    });
}

- (void)addView {
    UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _window_width, statusbarHeight + _window_width * 0.48)];
    headerImgView.image = [UIImage imageNamed:@"wy_page_header"];
    headerImgView.contentMode = UIViewContentModeScaleAspectFill;
    headerImgView.clipsToBounds = YES;
    [self.view addSubview:headerImgView];

    TYTabPagerBar *tabBar = [[TYTabPagerBar alloc] init];
    tabBar.dataSource = self;
    tabBar.delegate = self;
    tabBar.layout.selectedTextColor = [UIColor whiteColor];
    tabBar.layout.normalTextColor = [UIColor whiteColor];
    tabBar.layout.selectedTextFont = SYS_Font(14);
    tabBar.layout.normalTextFont = SYS_Font(14);
    tabBar.layout.cellWidth = _window_width / 5;
    tabBar.layout.cellSpacing = 0;
    tabBar.layout.cellEdging = 0;
    tabBar.layout.progressColor = [UIColor clearColor];
    tabBar.layout.progressWidth = 16;
    tabBar.layout.progressHeight = 7;
    tabBar.layout.progressRadius = 1;
    tabBar.layout.progressVerEdging = 8;
    [tabBar registerClass:[TYTabPagerBarCell class] forCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier]];
    tabBar.frame = CGRectMake(0, 24 + statusbarHeight, _window_width, 55);
    [self.view addSubview:tabBar];
    self.tabBar = tabBar;

    TYPagerController *pagerController = [[TYPagerController alloc] init];
    pagerController.layout.prefetchItemCount = 1;
    pagerController.layout.addVisibleItemOnlyWhenScrollAnimatedEnd = YES;
    pagerController.dataSource = self;
    pagerController.delegate = self;
    pagerController.view.frame = CGRectMake(0, self.tabBar.bottom, _window_width, _window_height - self.tabBar.bottom - 48 - ShowDiff);
    pagerController.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:pagerController];
    [self.view addSubview:pagerController.view];
    self.pagerController = pagerController;

    [self loadData];
}

- (void)loadData {
    self.datas = @[@"关注", @"上新", @"种草", @"直播", @"视频"].mutableCopy;
    [self reloadData];
}

#pragma mark - TYTabPagerBarDataSource

- (NSInteger)numberOfItemsInPagerTabBar {
    return self.datas.count;
}

- (UICollectionViewCell<TYTabPagerBarCellProtocol> *)pagerTabBar:(TYTabPagerBar *)pagerTabBar cellForItemAtIndex:(NSInteger)index {
    UICollectionViewCell<TYTabPagerBarCellProtocol> *cell = [pagerTabBar dequeueReusableCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier] forIndex:index];
    cell.titleLabel.text = self.datas[index];
    return cell;
}

#pragma mark - TYTabPagerBarDelegate

- (CGFloat)pagerTabBar:(TYTabPagerBar *)pagerTabBar widthForItemAtIndex:(NSInteger)index {
    NSString *title = self.datas[index];
    return [pagerTabBar cellWidthForTitle:title];
}

- (void)pagerTabBar:(TYTabPagerBar *)pagerTabBar didSelectItemAtIndex:(NSInteger)index {
    [self.pagerController scrollToControllerAtIndex:index animate:YES];
}

#pragma mark - TYPagerControllerDataSource

- (NSInteger)numberOfControllersInPagerController {
    return self.datas.count;
}

- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    id viewController = self.controlArray[index];
    if ([viewController isKindOfClass:[NSString class]]) {
        if (index < 4) {
            SWAnliVC *anliVC = [[SWAnliVC alloc] init];
            anliVC.typeValue = index;
            if (index == 3) {
                anliVC.classID = @"gisecyysh";
            }
            self.controlArray[index] = anliVC;
            return anliVC;
        }

        SWFindVideoVC *videoVC = [[SWFindVideoVC alloc] init];
        self.controlArray[index] = videoVC;
        return videoVC;
    }
    return viewController;
}

#pragma mark - TYPagerControllerDelegate

- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated {
    [self.tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex animate:animated];
}

- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    [self.tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex progress:progress];
}

- (void)reloadData {
    [self.tabBar reloadData];
    [self.pagerController reloadData];
}

@end
