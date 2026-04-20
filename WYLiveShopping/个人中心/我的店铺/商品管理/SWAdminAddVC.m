//
//  SWAdminAddVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/22.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWAdminAddVC.h"
#import "TYPagerController.h"
#import "TYTabPagerBar.h"
#import "SWAdminGoodsVC.h"

@interface SWAdminAddVC ()<TYTabPagerBarDataSource,TYTabPagerBarDelegate,TYPagerControllerDataSource,TYPagerControllerDelegate,UITextFieldDelegate>
@property (nonatomic, weak) TYTabPagerBar *tabBar;
@property (nonatomic, weak) TYPagerController *pagerController;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) NSInteger curSelIndex;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) NSMutableArray *controlArray;

@end

@implementation SWAdminAddVC

- (void)addheaderView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight, _window_width, 46)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];

    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 8, _window_width - 30, 30)];
    self.searchTextField.font = SYS_Font(14);
    self.searchTextField.placeholder = @"搜索商品";
    self.searchTextField.delegate = self;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    self.searchTextField.layer.cornerRadius = 15;
    self.searchTextField.layer.masksToBounds = YES;
    self.searchTextField.backgroundColor = RGB_COLOR(@"#F5F5F5", 1);
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    [view addSubview:self.searchTextField];

    UIView *leftV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(8, 5, 20, 20)];
    imgV.image = [UIImage imageNamed:@"搜索"];
    [leftV addSubview:imgV];
    self.searchTextField.leftView = leftV;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField.text.length > 0) {
        SWAdminGoodsVC *vc = (SWAdminGoodsVC *)self.pagerController.visibleControllers[self.curSelIndex];
        vc.keywordStr = minstr(textField.text);
        [vc doSearchGoods];
    }
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.curSelIndex = 0;
    self.titleL.text = @"添加商品";
    [self addheaderView];
    [self addTabPageBar];
    [self addPagerController];
    [self loadData];
    [self requestGoodsClass];
}

- (void)addTabPageBar {
    TYTabPagerBar *tabBar = [[TYTabPagerBar alloc] init];
    tabBar.backgroundColor = [UIColor whiteColor];
    tabBar.layout.barStyle = TYPagerBarStyleProgressElasticView;
    tabBar.dataSource = self;
    tabBar.delegate = self;
    tabBar.layout.selectedTextColor = color32;
    tabBar.layout.normalTextColor = color96;
    tabBar.layout.selectedTextFont = [UIFont boldSystemFontOfSize:15];
    tabBar.layout.normalTextFont = SYS_Font(14);
    tabBar.layout.cellWidth = 85;
    tabBar.layout.cellEdging = 0;
    tabBar.layout.cellSpacing = 0;
    tabBar.layout.progressColor = normalColors;
    tabBar.layout.progressWidth = 14;
    tabBar.layout.progressHeight = 2;
    tabBar.layout.progressRadius = 1;
    [tabBar registerClass:[TYTabPagerBarCell class] forCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier]];
    [self.view addSubview:tabBar];
    self.tabBar = tabBar;
}

- (void)addPagerController {
    TYPagerController *pagerController = [[TYPagerController alloc] init];
    pagerController.layout.prefetchItemCount = 1;
    pagerController.layout.addVisibleItemOnlyWhenScrollAnimatedEnd = YES;
    pagerController.dataSource = self;
    pagerController.delegate = self;
    pagerController.scrollView.scrollEnabled = NO;
    [self addChildViewController:pagerController];
    [self.view addSubview:pagerController.view];
    self.pagerController = pagerController;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tabBar.frame = CGRectMake(0, 110 + statusbarHeight, _window_width, 50);
    self.pagerController.view.frame = CGRectMake(0, self.tabBar.bottom, _window_width, _window_height - self.tabBar.bottom - ShowDiff);
}

- (void)loadData {
    self.datas = @[@{@"cate_name": @"精选商品", @"id": @""}].mutableCopy;
    self.controlArray = @[@""].mutableCopy;
    [self reloadData];
}

#pragma mark - TYTabPagerBarDataSource

- (NSInteger)numberOfItemsInPagerTabBar {
    return self.datas.count;
}

- (UICollectionViewCell<TYTabPagerBarCellProtocol> *)pagerTabBar:(TYTabPagerBar *)pagerTabBar cellForItemAtIndex:(NSInteger)index {
    UICollectionViewCell<TYTabPagerBarCellProtocol> *cell = [pagerTabBar dequeueReusableCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier] forIndex:index];
    cell.titleLabel.text = minstr([self.datas[index] valueForKey:@"cate_name"]);
    return cell;
}

#pragma mark - TYTabPagerBarDelegate

- (CGFloat)pagerTabBar:(TYTabPagerBar *)pagerTabBar widthForItemAtIndex:(NSInteger)index {
    NSString *title = minstr([self.datas[index] valueForKey:@"cate_name"]);
    return [pagerTabBar cellWidthForTitle:title];
}

- (void)pagerTabBar:(TYTabPagerBar *)pagerTabBar didSelectItemAtIndex:(NSInteger)index {
    [self.pagerController scrollToControllerAtIndex:index animate:YES];
    self.curSelIndex = index;
    id obj = self.controlArray[self.curSelIndex];
    if ([obj isKindOfClass:[SWAdminGoodsVC class]]) {
        SWAdminGoodsVC *vc = (SWAdminGoodsVC *)obj;
        if (vc.keywordStr.length > 0) {
            self.searchTextField.text = @"";
            vc.keywordStr = @"";
            [vc doSearchGoods];
        }
    }
}

#pragma mark - TYPagerControllerDataSource

- (NSInteger)numberOfControllersInPagerController {
    return self.datas.count;
}

- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    id obj = self.controlArray[index];
    if ([obj isKindOfClass:[NSString class]]) {
        SWAdminGoodsVC *vc = [[SWAdminGoodsVC alloc] init];
        vc.cid = minstr([self.datas[index] valueForKey:@"id"]);
        self.controlArray[index] = vc;
        return vc;
    }
    return obj;
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

- (void)requestGoodsClass {
    [SWToolClass getQCloudWithUrl:@"category" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.datas addObjectsFromArray:info];
        for (__unused NSDictionary *dic in info) {
            [self.controlArray addObject:@""];
        }
        [self reloadData];
    } Fail:^{
    }];
}

@end
