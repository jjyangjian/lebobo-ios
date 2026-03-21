//
//  StoreHomeViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/6.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "StoreHomeViewController.h"
#import "TYPagerView.h"
#import "TYTabPagerBar.h"
#import "WYStoreGoodsView.h"
#import "WYStoreCouponView.h"
#import "WYStoreSearchViewController.h"
@interface StoreHomeViewController ()<TYTabPagerBarDataSource,TYTabPagerBarDelegate,TYPagerViewDelegate,TYPagerViewDataSource>{
    UIImageView *storeThumbImgView;
    UILabel *storeNameLabel;
    UILabel *fansNumsL;
    NSMutableArray *viewArray;
    NSDictionary *storeMsgDic;
    UILabel *typeView;
    UIButton *mesgBtn;
}
@property (nonatomic,strong) UIButton *searchBtn;
@property (nonatomic,strong) UIButton *followBtn;
@property (nonatomic, weak) TYTabPagerBar *tabBar;
@property (nonatomic, weak) TYPagerView *pagerView;
@property (nonatomic,strong) NSArray *datas;

@end

@implementation StoreHomeViewController
-(void)doReturn{
    if (self.block) {
        self.block();
    }
}

- (void)doSearch{
    WYStoreSearchViewController *vc = [[WYStoreSearchViewController alloc]init];
    vc.mer_id = _mer_id;
    vc.cid = @"";
    vc.sid = @"";
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

}
- (void)doFollow{
    [WYToolClass postNetworkWithUrl:@"shopsetattent" andParameter:@{@"type":_followBtn.selected ? @"0" : @"1",@"shopid":_mer_id} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            _followBtn.selected = !_followBtn.selected;
            [MBProgressHUD showError:_followBtn.selected ? @"关注成功" : @"取消关注成功"];

        }
    } fail:^{
        
    }];
}
- (void)doStoreMessage{
    WYWebViewController *vc = [[WYWebViewController alloc]init];
    vc.urls = minstr([storeMsgDic valueForKey:@"content_url"]);
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.returnBtn.selected = YES;
    self.naviView.backgroundColor = RGB_COLOR(@"#0A0F1B", 1);
    self.lineView.hidden = YES;
    _searchBtn = [UIButton buttonWithType:0];
    [_searchBtn setImage:[UIImage imageNamed:@"home_search"] forState:0];
    [_searchBtn setTitle:@" 搜索店铺内商品" forState:0];
    [_searchBtn setTitleColor:RGB_COLOR(@"#b4b4b4", 1) forState:0];
    _searchBtn.titleLabel.font = SYS_Font(14);
    [_searchBtn setBackgroundColor:RGB_COLOR(@"#FAFAFA", 0.1)];
    _searchBtn.layer.cornerRadius = 15;
    _searchBtn.layer.masksToBounds = YES;
    [_searchBtn addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    _searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.naviView addSubview:_searchBtn];
    [_searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.returnBtn.mas_right).offset(5);
        make.right.equalTo(self.naviView).offset(-15);
        make.centerY.equalTo(self.returnBtn);
        make.height.mas_equalTo(30);
    }];
    _datas = @[@"推荐",@"新品",@"优惠券"];
    viewArray = @[@"1",@"1",@"1"].mutableCopy;
    [self creatUI];
    [self addTabPageBar];
    [self addPagerView];
    [self reloadData];
    [self requestData];
}
- (void)requestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"shophome&shopid=%@",_mer_id] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            storeMsgDic = info;
            dispatch_async(dispatch_get_main_queue(), ^{
                [storeThumbImgView sd_setImageWithURL:[NSURL URLWithString:minstr([storeMsgDic valueForKey:@"avatar"])]];
                self.mer_name = minstr([storeMsgDic valueForKey:@"nickname"]);
                storeNameLabel.text = _mer_name;
                fansNumsL.text = [NSString stringWithFormat:@"粉丝 %@",minstr([storeMsgDic valueForKey:@"fans"])];
                _followBtn.selected = [minstr([storeMsgDic valueForKey:@"isattrnt"]) intValue];
                if ([minstr([storeMsgDic valueForKey:@"shoptype"]) isEqual:@"2"]) {
                    typeView.hidden = NO;
                    [mesgBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(typeView.mas_right).offset(3);
                        make.centerY.equalTo(storeNameLabel);
                        make.height.equalTo(storeNameLabel);
                        make.width.equalTo(mesgBtn.mas_height);
                    }];
                }else{
                    typeView.hidden = YES;
                }
            });
        }
    } Fail:^{
        
    }];
    
}
- (void)creatUI{
    UIView *storeView = [[UIView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, 91)];
    storeView.backgroundColor = RGB_COLOR(@"#0A0F1B", 1);
    [self.view addSubview:storeView];

    storeThumbImgView = [[UIImageView alloc]init];
    storeThumbImgView.contentMode = UIViewContentModeScaleAspectFill;
    storeThumbImgView.layer.cornerRadius = 25;
    storeThumbImgView.layer.masksToBounds = YES;
    [storeView addSubview:storeThumbImgView];
    [storeThumbImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(storeView).offset(15);
        make.top.equalTo(storeView).offset(15);
        make.width.height.mas_equalTo(50);
    }];
    storeNameLabel = [[UILabel alloc]init];
    storeNameLabel.font = [UIFont boldSystemFontOfSize:15];
    storeNameLabel.textColor = [UIColor whiteColor];
    [storeView addSubview:storeNameLabel];
    [storeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(storeThumbImgView.mas_right).offset(13);
        make.centerY.equalTo(storeThumbImgView).multipliedBy(0.65);
        make.width.lessThanOrEqualTo(storeView).multipliedBy(0.4);
    }];
    UIButton *btn = [UIButton buttonWithType:0];
    [btn setImage:[UIImage imageNamed:@"store-message"] forState:0];
    [btn addTarget:self action:@selector(doStoreMessage) forControlEvents:UIControlEventTouchUpInside];
    [storeView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(storeNameLabel.mas_right).offset(5);
        make.centerY.equalTo(storeNameLabel);
        make.height.equalTo(storeNameLabel);
        make.width.equalTo(btn.mas_height);
    }];
    mesgBtn = btn;
    UILabel *ziying = [[UILabel alloc]init];
    ziying.hidden = YES;
    ziying.font = SYS_Font(10);
    ziying.textColor = [UIColor whiteColor];
    ziying.text = @"自营";
    ziying.layer.cornerRadius = 3;
    ziying.layer.masksToBounds = YES;
    ziying.textAlignment = NSTextAlignmentCenter;
    ziying.backgroundColor = normalColors;
    [storeView addSubview:ziying];
    [ziying mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(storeNameLabel.mas_right).offset(3);
        make.centerY.equalTo(storeNameLabel);
        make.width.mas_equalTo(26);
        make.height.mas_equalTo(15);
    }];
    typeView = ziying;

    _followBtn = [UIButton buttonWithType:0];
    [_followBtn setTitle:@"关注" forState:0];
    [_followBtn setTitle:@"已关注" forState:UIControlStateSelected];
    _followBtn.titleLabel.font = SYS_Font(10);
    [_followBtn setBackgroundImage:[WYToolClass getImgWithColor:normalColors] forState:0];
    [_followBtn setBackgroundImage:[WYToolClass getImgWithColor:color96] forState:UIControlStateSelected];

    [_followBtn setCornerRadius:10];
    [_followBtn addTarget:self action:@selector(doFollow) forControlEvents:UIControlEventTouchUpInside];
    [storeView addSubview:_followBtn];
    [_followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(storeView).offset(-15);
        make.centerY.equalTo(storeView);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(20);
    }];
    fansNumsL = [[UILabel alloc]init];
    fansNumsL.font = SYS_Font(11);
    fansNumsL.textColor = [UIColor whiteColor];
    [storeView addSubview:fansNumsL];
    [fansNumsL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(storeNameLabel);
        make.centerY.equalTo(storeThumbImgView).multipliedBy(1.35);
    }];
}
- (void)addTabPageBar {
    TYTabPagerBar *tabBar = [[TYTabPagerBar alloc]init];
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
    tabBar.frame = CGRectMake(0, 155+statusbarHeight, _window_width, 44);
    tabBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tabBar];
    _tabBar = tabBar;
}

- (void)addPagerView {
    TYPagerView *pageView = [[TYPagerView alloc]init];
    pageView.layout.autoMemoryCache = NO;
    pageView.dataSource = self;
    pageView.delegate = self;
    // you can rigsiter cell like tableView
    [pageView.layout registerClass:[UIView class] forItemWithReuseIdentifier:@"cellId"];
    pageView.frame = CGRectMake(0, _tabBar.bottom, _window_width, _window_height-(_tabBar.bottom + ShowDiff + 48));
    [self.view addSubview:pageView];
    _pagerView = pageView;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

#pragma mark - TYTabPagerBarDataSource

- (NSInteger)numberOfItemsInPagerTabBar {
    return _datas.count;
}

- (UICollectionViewCell<TYTabPagerBarCellProtocol> *)pagerTabBar:(TYTabPagerBar *)pagerTabBar cellForItemAtIndex:(NSInteger)index {
    UICollectionViewCell<TYTabPagerBarCellProtocol> *cell = [pagerTabBar dequeueReusableCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier] forIndex:index];
    cell.titleLabel.text = minstr(_datas[index]);
    return cell;
}

#pragma mark - TYTabPagerBarDelegate

- (CGFloat)pagerTabBar:(TYTabPagerBar *)pagerTabBar widthForItemAtIndex:(NSInteger)index {
    NSString *title = _datas[index];
    return [pagerTabBar cellWidthForTitle:title];
}

- (void)pagerTabBar:(TYTabPagerBar *)pagerTabBar didSelectItemAtIndex:(NSInteger)index {
    [_pagerView scrollToViewAtIndex:index animate:YES];
}

#pragma mark - TYPagerViewDataSource

- (NSInteger)numberOfViewsInPagerView {
    return _datas.count;
}

- (UIView *)pagerView:(TYPagerView *)pagerView viewForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    id vue = viewArray[index];
    if ([vue isKindOfClass:[NSString class]]) {
        if (index < 2) {
            WYStoreGoodsView *view = [[WYStoreGoodsView alloc]initWithFrame:CGRectMake(0, 0, pagerView.width, pagerView.height) andType:index andStoreID:_mer_id];
            [viewArray insertObject:view atIndex:index];
            return view;
        }else{
            WYStoreCouponView *view = [[WYStoreCouponView alloc]initWithFrame:CGRectMake(0, 0, pagerView.width, pagerView.height) andStoreID:_mer_id];
            [viewArray insertObject:view atIndex:index];
            return view;
        }
    }else{
        return vue;
    }
}

#pragma mark - TYPagerViewDelegate

- (void)pagerView:(TYPagerView *)pagerView willAppearView:(UIView *)view forIndex:(NSInteger)index {
    NSLog(@"+++++++++willAppearViewIndex:%ld",index);
}

- (void)pagerView:(TYPagerView *)pagerView willDisappearView:(UIView *)view forIndex:(NSInteger)index {
    NSLog(@"---------willDisappearView:%ld",index);
}

- (void)pagerView:(TYPagerView *)pagerView transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated {
    NSLog(@"fromIndex:%ld, toIndex:%ld",fromIndex,toIndex);
    [_tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex animate:animated];
}

- (void)pagerView:(TYPagerView *)pagerView transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    NSLog(@"fromIndex:%ld, toIndex:%ld progress%.3f",fromIndex,toIndex,progress);
    [_tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex progress:progress];
}

- (void)pagerViewWillBeginScrolling:(TYPagerView *)pageView animate:(BOOL)animate {
    //NSLog(@"pagerViewWillBeginScrolling");
}

- (void)pagerViewDidEndScrolling:(TYPagerView *)pageView animate:(BOOL)animate {
    //NSLog(@"pagerViewDidEndScrolling");
}

- (void)reloadData {
    [_tabBar reloadData];
    [_pagerView reloadData];
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
