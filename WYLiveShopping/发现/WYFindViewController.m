//
//  WYFindViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/27.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYFindViewController.h"
#import "TYPagerController.h"
#import "TYTabPagerBar.h"
#import "WYAnliViewController.h"
#import "WYFindVideoViewController.h"

@interface WYFindViewController ()<TYTabPagerBarDataSource,TYTabPagerBarDelegate,TYPagerControllerDataSource,TYPagerControllerDelegate>{
    NSMutableArray *controlArray;
}
@property (nonatomic, weak) TYTabPagerBar *tabBar;
@property (nonatomic, weak) TYPagerController *pagerController;
@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation WYFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    self.navigationController.navigationBar.hidden = YES;
    if (SysVersion >= 11.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    self.view.backgroundColor = colorf0;
    controlArray = @[@"",@"",@"",@"",@""].mutableCopy;
    [self addView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_pagerController scrollToControllerAtIndex:1 animate:YES];
    });
}
- (void)addView{
    UIImageView *headerImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, statusbarHeight + _window_width*0.48)];
    headerImgView.image = [UIImage imageNamed:@"wy_page_header"];
    headerImgView.contentMode = UIViewContentModeScaleAspectFill;
    headerImgView.clipsToBounds = YES;
//    headerImgView.backgroundColor = normalColors;
    [self.view addSubview:headerImgView];
    TYTabPagerBar *tabBar = [[TYTabPagerBar alloc]init];
//    tabBar.layout.barStyle = TYPagerBarStyleProgressImageView;
    tabBar.dataSource = self;
    tabBar.delegate = self;
    tabBar.layout.selectedTextColor = [UIColor whiteColor];
    tabBar.layout.normalTextColor = [UIColor whiteColor];
    tabBar.layout.selectedTextFont = SYS_Font(14);
    tabBar.layout.normalTextFont = SYS_Font(14);
    tabBar.layout.cellWidth = _window_width/5;
    tabBar.layout.cellSpacing = 0;
    tabBar.layout.cellEdging = 0;
    tabBar.layout.progressColor = [UIColor clearColor];
    tabBar.layout.progressWidth = 16;
    tabBar.layout.progressHeight = 7;
    tabBar.layout.progressRadius = 1;
    tabBar.layout.progressVerEdging = 8;
    [tabBar registerClass:[TYTabPagerBarCell class] forCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier]];
    tabBar.frame = CGRectMake(0, 24+statusbarHeight, _window_width, 55);
    [self.view addSubview:tabBar];
    _tabBar = tabBar;
    TYPagerController *pagerController = [[TYPagerController alloc]init];
    pagerController.layout.prefetchItemCount = 1;
    //pagerController.layout.autoMemoryCache = NO;
    // 只有当scroll滚动动画停止时才加载pagerview，用于优化滚动时性能
    pagerController.layout.addVisibleItemOnlyWhenScrollAnimatedEnd = YES;
    pagerController.dataSource = self;
    pagerController.delegate = self;
    pagerController.view.frame = CGRectMake(0, _tabBar.bottom, _window_width, _window_height-(_tabBar.bottom) -48-ShowDiff);
    pagerController.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:pagerController];
    [self.view addSubview:pagerController.view];
    _pagerController = pagerController;
    [self loadData];
}
- (void)loadData {
    _datas = @[@"关注",@"上新",@"种草",@"直播",@"视频"].mutableCopy;
    
    [self reloadData];
    

}

#pragma mark - TYTabPagerBarDataSource

- (NSInteger)numberOfItemsInPagerTabBar {
    return _datas.count;
}

- (UICollectionViewCell<TYTabPagerBarCellProtocol> *)pagerTabBar:(TYTabPagerBar *)pagerTabBar cellForItemAtIndex:(NSInteger)index {
    UICollectionViewCell<TYTabPagerBarCellProtocol> *cell = [pagerTabBar dequeueReusableCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier] forIndex:index];
    cell.titleLabel.text = _datas[index];
    return cell;
}

#pragma mark - TYTabPagerBarDelegate

- (CGFloat)pagerTabBar:(TYTabPagerBar *)pagerTabBar widthForItemAtIndex:(NSInteger)index {
    NSString *title = _datas[index];
    return [pagerTabBar cellWidthForTitle:title];
}

- (void)pagerTabBar:(TYTabPagerBar *)pagerTabBar didSelectItemAtIndex:(NSInteger)index {
    [_pagerController scrollToControllerAtIndex:index animate:YES];
}

#pragma mark - TYPagerControllerDataSource

- (NSInteger)numberOfControllersInPagerController {
    return _datas.count;
}

- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    id vue = controlArray[index];
    if ([vue isKindOfClass:[NSString class]]) {
        if (index < 4) {
            WYAnliViewController *VC = [[WYAnliViewController alloc]init];
            VC.typeValue = index;
            if (index == 3) {
                VC.classID = @"gisecyysh";
//                VC.typeValue = 123456;
            }
            [controlArray insertObject:VC atIndex:index];
            return VC;
        }else{
            WYFindVideoViewController *video = [[WYFindVideoViewController alloc]init];
            [controlArray insertObject:video atIndex:index];
            return video;
        }
    }else{
        return vue;
    }

}

#pragma mark - TYPagerControllerDelegate

- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated {
    [_tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex animate:animated];
}

-(void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    [_tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex progress:progress];
}

- (void)reloadData {
    [_tabBar reloadData];
    [_pagerController reloadData];
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
