//
//  SWStoreHomeViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/6.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWStoreHomeViewController.h"
#import "TYPagerView.h"
#import "TYTabPagerBar.h"
#import "SWStoreGoodsView.h"
#import "SWStoreCouponView.h"
#import "SWStoreSearchViewController.h"

@interface SWStoreHomeViewController ()<TYTabPagerBarDataSource, TYTabPagerBarDelegate, TYPagerViewDelegate, TYPagerViewDataSource>
@property (nonatomic, strong) UIImageView *storeThumbImageView;
@property (nonatomic, strong) UILabel *storeNameLabel;
@property (nonatomic, strong) UILabel *fansCountLabel;
@property (nonatomic, strong) NSMutableArray *viewArray;
@property (nonatomic, strong) NSDictionary *storeMessageDictionary;
@property (nonatomic, strong) UILabel *storeTypeLabel;
@property (nonatomic, strong) UIButton *messageButton;
@property (nonatomic, strong) UIButton *searchBtn;
@property (nonatomic, strong) UIButton *followBtn;
@property (nonatomic, weak) TYTabPagerBar *tabBar;
@property (nonatomic, weak) TYPagerView *pagerView;
@property (nonatomic, strong) NSArray *datas;
@end

@implementation SWStoreHomeViewController

- (void)doReturn {
    if (self.block) {
        self.block();
    }
}

- (void)doSearch {
    SWStoreSearchViewController *vc = [[SWStoreSearchViewController alloc] init];
    vc.mer_id = self.mer_id;
    vc.cid = @"";
    vc.sid = @"";
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)doFollow {
    [SWToolClass postNetworkWithUrl:@"shopsetattent" andParameter:@{@"type": self.followBtn.selected ? @"0" : @"1", @"shopid": self.mer_id} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.followBtn.selected = !self.followBtn.selected;
            [MBProgressHUD showError:self.followBtn.selected ? @"关注成功" : @"取消关注成功"];
        }
    } fail:^{
    }];
}

- (void)doStoreMessage {
    SWWebViewController *vc = [[SWWebViewController alloc] init];
    vc.urls = minstr([self.storeMessageDictionary valueForKey:@"content_url"]);
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.returnBtn.selected = YES;
    self.naviView.backgroundColor = RGB_COLOR(@"#0A0F1B", 1);
    self.lineView.hidden = YES;

    self.searchBtn = [UIButton buttonWithType:0];
    [self.searchBtn setImage:[UIImage imageNamed:@"home_search"] forState:0];
    [self.searchBtn setTitle:@" 搜索店铺内商品" forState:0];
    [self.searchBtn setTitleColor:RGB_COLOR(@"#b4b4b4", 1) forState:0];
    self.searchBtn.titleLabel.font = SYS_Font(14);
    [self.searchBtn setBackgroundColor:RGB_COLOR(@"#FAFAFA", 0.1)];
    self.searchBtn.layer.cornerRadius = 15;
    self.searchBtn.layer.masksToBounds = YES;
    [self.searchBtn addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    self.searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.naviView addSubview:self.searchBtn];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.returnBtn.mas_right).offset(5);
        make.right.equalTo(self.naviView).offset(-15);
        make.centerY.equalTo(self.returnBtn);
        make.height.mas_equalTo(30);
    }];

    self.datas = @[@"推荐", @"新品", @"优惠券"];
    self.viewArray = [@[@"1", @"1", @"1"] mutableCopy];
    [self creatUI];
    [self addTabPageBar];
    [self addPagerView];
    [self reloadData];
    [self requestData];
}

- (void)requestData {
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"shophome&shopid=%@", self.mer_id] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.storeMessageDictionary = info;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.storeThumbImageView sd_setImageWithURL:[NSURL URLWithString:minstr([self.storeMessageDictionary valueForKey:@"avatar"])]];
                self.mer_name = minstr([self.storeMessageDictionary valueForKey:@"nickname"]);
                self.storeNameLabel.text = self.mer_name;
                self.fansCountLabel.text = [NSString stringWithFormat:@"粉丝 %@", minstr([self.storeMessageDictionary valueForKey:@"fans"])];
                self.followBtn.selected = [minstr([self.storeMessageDictionary valueForKey:@"isattrnt"]) intValue];
                if ([minstr([self.storeMessageDictionary valueForKey:@"shoptype"]) isEqual:@"2"]) {
                    self.storeTypeLabel.hidden = NO;
                    [self.messageButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(self.storeTypeLabel.mas_right).offset(3);
                        make.centerY.equalTo(self.storeNameLabel);
                        make.height.equalTo(self.storeNameLabel);
                        make.width.equalTo(self.messageButton.mas_height);
                    }];
                } else {
                    self.storeTypeLabel.hidden = YES;
                }
            });
        }
    } Fail:^{
    }];
}

- (void)creatUI {
    UIView *storeView = [[UIView alloc] initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, 91)];
    storeView.backgroundColor = RGB_COLOR(@"#0A0F1B", 1);
    [self.view addSubview:storeView];

    self.storeThumbImageView = [[UIImageView alloc] init];
    self.storeThumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.storeThumbImageView.layer.cornerRadius = 25;
    self.storeThumbImageView.layer.masksToBounds = YES;
    [storeView addSubview:self.storeThumbImageView];
    [self.storeThumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(storeView).offset(15);
        make.top.equalTo(storeView).offset(15);
        make.width.height.mas_equalTo(50);
    }];

    self.storeNameLabel = [[UILabel alloc] init];
    self.storeNameLabel.font = [UIFont boldSystemFontOfSize:15];
    self.storeNameLabel.textColor = [UIColor whiteColor];
    [storeView addSubview:self.storeNameLabel];
    [self.storeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeThumbImageView.mas_right).offset(13);
        make.centerY.equalTo(self.storeThumbImageView).multipliedBy(0.65);
        make.width.lessThanOrEqualTo(storeView).multipliedBy(0.4);
    }];

    UIButton *button = [UIButton buttonWithType:0];
    [button setImage:[UIImage imageNamed:@"store-message"] forState:0];
    [button addTarget:self action:@selector(doStoreMessage) forControlEvents:UIControlEventTouchUpInside];
    [storeView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeNameLabel.mas_right).offset(5);
        make.centerY.equalTo(self.storeNameLabel);
        make.height.equalTo(self.storeNameLabel);
        make.width.equalTo(button.mas_height);
    }];
    self.messageButton = button;

    UILabel *storeTypeLabel = [[UILabel alloc] init];
    storeTypeLabel.hidden = YES;
    storeTypeLabel.font = SYS_Font(10);
    storeTypeLabel.textColor = [UIColor whiteColor];
    storeTypeLabel.text = @"自营";
    storeTypeLabel.layer.cornerRadius = 3;
    storeTypeLabel.layer.masksToBounds = YES;
    storeTypeLabel.textAlignment = NSTextAlignmentCenter;
    storeTypeLabel.backgroundColor = normalColors;
    [storeView addSubview:storeTypeLabel];
    [storeTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeNameLabel.mas_right).offset(3);
        make.centerY.equalTo(self.storeNameLabel);
        make.width.mas_equalTo(26);
        make.height.mas_equalTo(15);
    }];
    self.storeTypeLabel = storeTypeLabel;

    self.followBtn = [UIButton buttonWithType:0];
    [self.followBtn setTitle:@"关注" forState:0];
    [self.followBtn setTitle:@"已关注" forState:UIControlStateSelected];
    self.followBtn.titleLabel.font = SYS_Font(10);
    [self.followBtn setBackgroundImage:[SWToolClass getImgWithColor:normalColors] forState:0];
    [self.followBtn setBackgroundImage:[SWToolClass getImgWithColor:color96] forState:UIControlStateSelected];
    [self.followBtn setCornerRadius:10];
    [self.followBtn addTarget:self action:@selector(doFollow) forControlEvents:UIControlEventTouchUpInside];
    [storeView addSubview:self.followBtn];
    [self.followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(storeView).offset(-15);
        make.centerY.equalTo(storeView);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(20);
    }];

    self.fansCountLabel = [[UILabel alloc] init];
    self.fansCountLabel.font = SYS_Font(11);
    self.fansCountLabel.textColor = [UIColor whiteColor];
    [storeView addSubview:self.fansCountLabel];
    [self.fansCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeNameLabel);
        make.centerY.equalTo(self.storeThumbImageView).multipliedBy(1.35);
    }];
}

- (void)addTabPageBar {
    TYTabPagerBar *tabBar = [[TYTabPagerBar alloc] init];
    tabBar.layout.barStyle = TYPagerBarStyleProgressView;
    tabBar.dataSource = self;
    tabBar.delegate = self;
    tabBar.layout.selectedTextColor = color32;
    tabBar.layout.normalTextColor = color64;
    tabBar.layout.selectedTextFont = [UIFont boldSystemFontOfSize:13];
    tabBar.layout.normalTextFont = SYS_Font(13);
    tabBar.layout.cellWidth = 0;
    tabBar.layout.cellSpacing = 15;
    tabBar.layout.cellEdging = 15;
    tabBar.layout.progressColor = normalColors;
    tabBar.layout.progressWidth = 14;
    tabBar.layout.progressHeight = 2;
    tabBar.layout.progressRadius = 1;
    tabBar.layout.progressVerEdging = 5;
    [tabBar registerClass:[TYTabPagerBarCell class] forCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier]];
    tabBar.frame = CGRectMake(0, 155 + statusbarHeight, _window_width, 44);
    tabBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tabBar];
    self.tabBar = tabBar;
}

- (void)addPagerView {
    TYPagerView *pageView = [[TYPagerView alloc] init];
    pageView.layout.autoMemoryCache = NO;
    pageView.dataSource = self;
    pageView.delegate = self;
    [pageView.layout registerClass:[UIView class] forItemWithReuseIdentifier:@"cellId"];
    pageView.frame = CGRectMake(0, self.tabBar.bottom, _window_width, _window_height - (self.tabBar.bottom + ShowDiff + 48));
    [self.view addSubview:pageView];
    self.pagerView = pageView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

#pragma mark - TYTabPagerBarDataSource

- (NSInteger)numberOfItemsInPagerTabBar {
    return self.datas.count;
}

- (UICollectionViewCell<TYTabPagerBarCellProtocol> *)pagerTabBar:(TYTabPagerBar *)pagerTabBar cellForItemAtIndex:(NSInteger)index {
    UICollectionViewCell<TYTabPagerBarCellProtocol> *cell = [pagerTabBar dequeueReusableCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier] forIndex:index];
    cell.titleLabel.text = minstr(self.datas[index]);
    return cell;
}

#pragma mark - TYTabPagerBarDelegate

- (CGFloat)pagerTabBar:(TYTabPagerBar *)pagerTabBar widthForItemAtIndex:(NSInteger)index {
    NSString *title = self.datas[index];
    return [pagerTabBar cellWidthForTitle:title];
}

- (void)pagerTabBar:(TYTabPagerBar *)pagerTabBar didSelectItemAtIndex:(NSInteger)index {
    [self.pagerView scrollToViewAtIndex:index animate:YES];
}

#pragma mark - TYPagerViewDataSource

- (NSInteger)numberOfViewsInPagerView {
    return self.datas.count;
}

- (UIView *)pagerView:(TYPagerView *)pagerView viewForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    id view = self.viewArray[index];
    if ([view isKindOfClass:[NSString class]]) {
        if (index < 2) {
            SWStoreGoodsView *goodsView = [[SWStoreGoodsView alloc] initWithFrame:CGRectMake(0, 0, pagerView.width, pagerView.height) andType:index andStoreID:self.mer_id];
            [self.viewArray replaceObjectAtIndex:index withObject:goodsView];
            return goodsView;
        } else {
            SWStoreCouponView *couponView = [[SWStoreCouponView alloc] initWithFrame:CGRectMake(0, 0, pagerView.width, pagerView.height) andStoreID:self.mer_id];
            [self.viewArray replaceObjectAtIndex:index withObject:couponView];
            return couponView;
        }
    }
    return view;
}

#pragma mark - TYPagerViewDelegate

- (void)pagerView:(TYPagerView *)pagerView willAppearView:(UIView *)view forIndex:(NSInteger)index {
    NSLog(@"+++++++++willAppearViewIndex:%ld", index);
}

- (void)pagerView:(TYPagerView *)pagerView willDisappearView:(UIView *)view forIndex:(NSInteger)index {
    NSLog(@"---------willDisappearView:%ld", index);
}

- (void)pagerView:(TYPagerView *)pagerView transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated {
    NSLog(@"fromIndex:%ld, toIndex:%ld", fromIndex, toIndex);
    [self.tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex animate:animated];
}

- (void)pagerView:(TYPagerView *)pagerView transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    NSLog(@"fromIndex:%ld, toIndex:%ld progress%.3f", fromIndex, toIndex, progress);
    [self.tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex progress:progress];
}

- (void)pagerViewWillBeginScrolling:(TYPagerView *)pageView animate:(BOOL)animate {
}

- (void)pagerViewDidEndScrolling:(TYPagerView *)pageView animate:(BOOL)animate {
}

- (void)reloadData {
    [self.tabBar reloadData];
    [self.pagerView reloadData];
}

@end
