//
//  SWAllLiveVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/3.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWAllLiveVC.h"
#import "TYPagerController.h"
#import "TYTabPagerBar.h"
#import "SWAnliVC.h"

@interface SWAllLiveVC ()<TYTabPagerBarDataSource,TYTabPagerBarDelegate,TYPagerControllerDataSource,TYPagerControllerDelegate>
@property (nonatomic, weak) TYTabPagerBar *tabBar;
@property (nonatomic, weak) TYPagerController *pagerController;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) NSMutableArray *controlArray;

@end

@implementation SWAllLiveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"直播";
    self.view.backgroundColor = colorf0;
    self.controlArray = @[@"",@""].mutableCopy;
    self.datas = @[@{@"id":@"follow",@"name":@"关注"},@{@"id":@"0",@"name":@"精选"}].mutableCopy;
    [self addView];
    [self requestClass];
}
- (void)addView{
    TYTabPagerBar *tabBar = [[TYTabPagerBar alloc]init];
    tabBar.layout.barStyle = TYPagerBarStyleProgressView;
    tabBar.dataSource = self;
    tabBar.delegate = self;
    tabBar.layout.selectedTextColor = color32;
    tabBar.layout.normalTextColor = color64;
    tabBar.layout.selectedTextFont = [UIFont boldSystemFontOfSize:15];
    tabBar.layout.normalTextFont = SYS_Font(14);
    tabBar.layout.cellSpacing = 2;
    tabBar.layout.cellEdging = 17;
    tabBar.layout.progressColor = normalColors;
    tabBar.layout.progressWidth = 14;
    tabBar.layout.progressHeight =2;
    tabBar.layout.progressRadius = 1;
    tabBar.layout.progressVerEdging = 5;
    [tabBar registerClass:[TYTabPagerBarCell class] forCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier]];
    tabBar.frame = CGRectMake(0, 64+statusbarHeight, _window_width, 44);
    tabBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tabBar];
    
    _tabBar = tabBar;
    TYPagerController *pagerController = [[TYPagerController alloc]init];
    pagerController.layout.prefetchItemCount = 1;
    //pagerController.layout.autoMemoryCache = NO;
    // 只有当scroll滚动动画停止时才加载pagerview，用于优化滚动时性能
    pagerController.layout.addVisibleItemOnlyWhenScrollAnimatedEnd = YES;
    pagerController.dataSource = self;
    pagerController.delegate = self;
    pagerController.view.frame = CGRectMake(0, _tabBar.bottom+5, _window_width, _window_height-(_tabBar.bottom+5));
    pagerController.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:pagerController];
    [self.view addSubview:pagerController.view];
    _pagerController = pagerController;
}
- (void)requestClass{
    [SWToolClass getQCloudWithUrl:@"live/class&type=1" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [self.datas addObjectsFromArray:info];;
            for (NSDictionary *dic in self.datas) {
                [self.controlArray addObject:@""];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData];
                [_pagerController scrollToControllerAtIndex:1 animate:YES];
            });
        }
    } Fail:^{
        
    }];

}

#pragma mark - TYTabPagerBarDataSource

- (NSInteger)numberOfItemsInPagerTabBar {
    return self.datas.count;
}

- (UICollectionViewCell<TYTabPagerBarCellProtocol> *)pagerTabBar:(TYTabPagerBar *)pagerTabBar cellForItemAtIndex:(NSInteger)index {
    UICollectionViewCell<TYTabPagerBarCellProtocol> *cell = [pagerTabBar dequeueReusableCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier] forIndex:index];
    cell.titleLabel.text = minstr([self.datas[index] valueForKey:@"name"]);
    return cell;
}

#pragma mark - TYTabPagerBarDelegate

- (CGFloat)pagerTabBar:(TYTabPagerBar *)pagerTabBar widthForItemAtIndex:(NSInteger)index {
    NSString *title = minstr([self.datas[index] valueForKey:@"name"]);
    return [pagerTabBar cellWidthForTitle:title];
}

- (void)pagerTabBar:(TYTabPagerBar *)pagerTabBar didSelectItemAtIndex:(NSInteger)index {
    [_pagerController scrollToControllerAtIndex:index animate:YES];
}

#pragma mark - TYPagerControllerDataSource

- (NSInteger)numberOfControllersInPagerController {
    return self.datas.count;
}

- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    id vue = self.controlArray[index];
    if ([vue isKindOfClass:[NSString class]]) {
        SWAnliVC *VC = [[SWAnliVC alloc]init];
        VC.typeValue = 1234567;
        VC.classID = minstr([self.datas[index] valueForKey:@"id"]);
        [self.controlArray insertObject:VC atIndex:index];
        return VC;
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
