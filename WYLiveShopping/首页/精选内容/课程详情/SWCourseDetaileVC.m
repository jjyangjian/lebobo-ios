//
//  SWCourseDetaileVC.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/12.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWCourseDetaileVC.h"
#import "TYPagerView.h"
#import "TYTabPagerBar.h"
#import "SWLiveMessageView.h"
#import "SWEvaluateView.h"
#import "SWCatalogView.h"
#import "SWCourseContentVC.h"
#import "SWPayTypeSelectView.h"
#import "SWWriteEvaluateVC.h"
#import <WXApi.h>

@interface SWCourseDetaileVC ()<TYPagerViewDataSource, TYPagerViewDelegate, TYTabPagerBarDataSource, TYTabPagerBarDelegate>
@property (nonatomic, weak) TYTabPagerBar *tabBar;
@property (nonatomic, weak) TYPagerView *pageView;
@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) SWLiveMessageView *messageView;
@property (nonatomic, strong) SWEvaluateView *evaluateView;
@property (nonatomic, strong) SWCatalogView *catalogView;
@property (nonatomic, strong) SWPayTypeSelectView *payTypeView;
@property (nonatomic, strong) NSMutableDictionary *courseMessageDictionary;

@end

@implementation SWCourseDetaileVC

- (void)creatHeader {
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight, _window_width, _window_width * 0.56)];
    [imgV sd_setImageWithURL:[NSURL URLWithString:_model.thumb]];
    imgV.contentMode = UIViewContentModeScaleAspectFill;
    imgV.clipsToBounds = YES;
    imgV.userInteractionEnabled = YES;
    [self.view addSubview:imgV];
}

- (void)addBottomView {
    if (self.bottomView) {
        [self.bottomView removeFromSuperview];
        self.bottomView = nil;
    }

    int btn_status = [minstr([self.courseMessageDictionary valueForKey:@"btn_status"]) intValue];
    //btn_status 按钮状态 0不显示 1查看详情 2输入密码 3购买 4进入直播 5会员专享

    if (btn_status == 0) {
        return;
    }
/*
    if ([[SWConfig getVipType] isEqual:@"2"] || ([minstr([self.courseMessageDictionary valueForKey:@"isshowvip"]) isEqual:@"2"] && [[SWConfig getVipType] isEqual:@"1"])) {
        [self.courseMessageDictionary setObject:@"2" forKey:@"isbuy"];
        if ([minstr([self.courseMessageDictionary valueForKey:@"sort"]) isEqual:@"1"]) {
            return;
        }
//        return;
    }
    if ([minstr([self.courseMessageDictionary valueForKey:@"isvip"]) isEqual:@"1"] && [[SWConfig getVipType] isEqual:@"0"]) {// && [minstr([self.courseMessageDictionary valueForKey:@"paytype"]) isEqual:@"0"]
        [self.view addSubview:self.bottomView];
    }else{

        if ([minstr([self.courseMessageDictionary valueForKey:@"sort"]) isEqual:@"1"]) {
            if ([minstr([self.courseMessageDictionary valueForKey:@"isbuy"]) isEqual:@"1"] || [minstr([self.courseMessageDictionary valueForKey:@"paytype"]) isEqual:@"0"]) {
    //            self.rightBtn.hidden = NO;
                return;
            }
        }
        if ([minstr([self.courseMessageDictionary valueForKey:@"isbuy"]) isEqual:@"0"] && [minstr([self.courseMessageDictionary valueForKey:@"trialtype"]) isEqual:@"2"]){
            tryButton = [UIButton buttonWithType:0];
            tryButton.titleLabel.font = SYS_Font(10);
            [tryButton addTarget:self action:@selector(doDetails) forControlEvents:UIControlEventTouchUpInside];
            tryButton.frame = CGRectMake(_window_width-60, _window_height - 115 - ShowDiff, 50, 50);
            [tryButton setTitle:@"试学" forState:0];
            [tryButton setImage:[UIImage imageNamed:@"试学"] forState:0];
            [tryButton setTitleColor:normalColors forState:0];
            tryButton.layer.cornerRadius = 25;
            tryButton.layer.masksToBounds = YES;
            tryButton.layer.borderColor = colorf0.CGColor;
            tryButton.layer.borderWidth = 0.5;
            [tryButton setBackgroundColor:[UIColor whiteColor]];
            [self.view addSubview:tryButton];
            [SWToolClass setUpImgDownText:tryButton];
        }

        if ([minstr([self.courseMessageDictionary valueForKey:@"isbuy"]) isEqual:@"0"] && [minstr([self.courseMessageDictionary valueForKey:@"paytype"]) isEqual:@"1"]){//&& [minstr([self.courseMessageDictionary valueForKey:@"sort"]) isEqual:@"1"]
            [self.view addSubview:self.carView];
        }else{
            NSString *typeStr;
            if ([minstr([self.courseMessageDictionary valueForKey:@"isbuy"]) isEqual:@"1"] || [minstr([self.courseMessageDictionary valueForKey:@"isbuy"]) isEqual:@"2"]) {
                    typeStr = @"4";
            }else{
                /// 获取形式，0免费1收费2密码
                if ([minstr([self.courseMessageDictionary valueForKey:@"paytype"]) isEqual:@"0"]) {
                    typeStr = @"4";
                }else if ([minstr([self.courseMessageDictionary valueForKey:@"paytype"]) isEqual:@"1"]) {
                    typeStr = @"1";
                    if ([minstr([self.courseMessageDictionary valueForKey:@"trialtype"]) isEqual:@"2"]){
                        typeStr = @"2";
                    }
                }else{
                    typeStr = @"3";
                    if ([minstr([self.courseMessageDictionary valueForKey:@"trialtype"]) isEqual:@"2"]){
                        typeStr = @"5";
                    }

                }
            }
            if ([typeStr isEqual:@"4"]) {
    //            self.rightBtn.hidden = NO;
            }

            buyView = [[buyOrTryBottomView alloc]initWithFrame:CGRectMake(0, _window_height-50-ShowDiff, _window_width, 50+ShowDiff) andType:typeStr andMoney:[minstr([self.courseMessageDictionary valueForKey:@"payval"]) floatValue]];
            WeakSelf;
            buyView.block = ^(NSString * _Nonnull type) {
                if ([type isEqual:@"details"] || [type isEqual:@"try"]) {
                    [weakSelf doDetails];
                }else if ([type isEqual:@"buy"]){
                    [weakSelf showPayView];
                }else if ([type isEqual:@"password"]){
                    [weakSelf doInputPassword];
                }
            };
            [self.view addSubview:buyView];
        }
    }
 */
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.titleL.text = @"内容详情";

    [self creatHeader];
    [self addTabPageBar];
    [self addPagerController];
    [self requestCourseDetaile];
}

- (void)doReturn {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super doReturn];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)requestCourseDetaile {
    [MBProgressHUD showMessage:@""];
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"coursedetail&courseid=%@", _model.courseID] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            self.courseMessageDictionary = [info mutableCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([minstr([self.courseMessageDictionary valueForKey:@"isbuy"]) isEqual:@"0"]) {
                    [self.view addSubview:self.bottomView];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxPayResult:) name:WYWXApiPaySuccess object:nil];
                }
                [self loadData];
                if (self.messageView) {
                    self.messageView.dic = self.courseMessageDictionary;
                }
            });
        }
    } Fail:^{
        [MBProgressHUD hideHUD];
    }];
}

- (void)addTabPageBar {
    TYTabPagerBar *tabBar = [[TYTabPagerBar alloc] init];
    tabBar.layout.barStyle = TYPagerBarStyleProgressElasticView;
    tabBar.dataSource = self;
    tabBar.delegate = self;
    tabBar.layout.selectedTextColor = normalColors;
    tabBar.layout.normalTextColor = color96;
    tabBar.layout.selectedTextFont = SYS_Font(15);
    tabBar.layout.normalTextFont = SYS_Font(15);
//    if ([_model.sort isEqual:@"0"]) {
//        tabBar.layout.cellWidth = _window_width/2;
//    }else{
    tabBar.layout.cellWidth = _window_width / 3;
//    }
    tabBar.layout.cellSpacing = 0;
    tabBar.layout.cellEdging = 0;
    [tabBar registerClass:[TYTabPagerBarCell class] forCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier]];
    [self.view addSubview:tabBar];
    self.tabBar = tabBar;
    self.tabBar.frame = CGRectMake(0, _window_width * 0.56 + statusbarHeight + 64, _window_width, 50);
}

- (void)addPagerController {
    TYPagerView *pageView = [[TYPagerView alloc] init];
    pageView.layout.autoMemoryCache = NO;
    pageView.dataSource = self;
    pageView.delegate = self;
    [pageView.layout registerClass:[UIView class] forItemWithReuseIdentifier:@"cellId"];
    [self.view addSubview:pageView];
    self.pageView = pageView;
    self.pageView.frame = CGRectMake(0, self.tabBar.bottom, _window_width, _window_height - self.tabBar.bottom);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[SWToolClass sharedInstance] removeSusPlayer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)loadData {
    self.datas = @[@"介绍", @"目录", @"评价"].mutableCopy;
    [self reloadData];
}

- (void)reloadData {
    [self.tabBar reloadData];
    [self.pageView reloadData];
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
    [self.pageView scrollToViewAtIndex:index animate:YES];
}

#pragma mark - TYPagerViewDataSource

- (NSInteger)numberOfViewsInPagerView {
    return self.datas.count;
}

- (UIView *)pagerView:(TYPagerView *)pagerView viewForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    if ([self.datas[index] isEqual:@"介绍"]) {
        if (!self.messageView) {
            self.messageView = [[SWLiveMessageView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height - self.tabBar.bottom) andType:@""];
        }
        self.messageView.dic = self.courseMessageDictionary;
        return self.messageView;
    } else if ([self.datas[index] isEqual:@"评价"]) {
        if (!self.evaluateView) {
            self.evaluateView = [[SWEvaluateView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height - self.tabBar.bottom) andCourse:self.courseMessageDictionary andIsCourse:[minstr([self.courseMessageDictionary valueForKey:@"sort"]) isEqual:@"1"] ? YES : NO];
        }
        return self.evaluateView;
    } else {
        if (!self.catalogView) {
            self.catalogView = [[SWCatalogView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height - self.tabBar.bottom) andCourseID:minstr([self.courseMessageDictionary valueForKey:@"id"])];
            self.catalogView.homeDic = self.courseMessageDictionary;
        }
        return self.catalogView;
    }
}

#pragma mark - TYPagerViewDelegate

- (void)pagerView:(TYPagerView *)pagerView willAppearView:(UIView *)view forIndex:(NSInteger)index {
    //NSLog(@"+++++++++willAppearViewIndex:%ld",index);
}

- (void)pagerView:(TYPagerView *)pagerView willDisappearView:(UIView *)view forIndex:(NSInteger)index {
    //NSLog(@"---------willDisappearView:%ld",index);
}

- (void)pagerView:(TYPagerView *)pagerView transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated {
    NSLog(@"fromIndex:%ld, toIndex:%ld", fromIndex, toIndex);
    [self.tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex animate:animated];
}

- (void)pagerView:(TYPagerView *)pagerView transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    [self.tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex progress:progress];
}

- (void)pagerViewWillBeginScrolling:(TYPagerView *)pageView animate:(BOOL)animate {
    //NSLog(@"pagerViewWillBeginScrolling");
}

- (void)pagerViewDidEndScrolling:(TYPagerView *)pageView animate:(BOOL)animate {
    //NSLog(@"pagerViewDidEndScrolling");
}

- (void)changeBuyState {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WYWXApiPaySuccess object:nil];
    [self.bottomView removeFromSuperview];
    self.bottomView = nil;
    [self.courseMessageDictionary setObject:@"1" forKey:@"isbuy"];
    if (self.messageView) {
        [self.messageView changePayState];
    }
    if (self.evaluateView) {
        self.evaluateView.courseDiccccc = self.courseMessageDictionary;
    }
    if (self.catalogView) {
        self.catalogView.homeDic = self.courseMessageDictionary;
    }
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _window_height - 50 - ShowDiff, _window_width, 50 + ShowDiff)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        UIButton *kaitongBtn = [UIButton buttonWithType:0];
        kaitongBtn.frame = CGRectMake(15, 5, _window_width - 30, 40);
        [kaitongBtn setTitle:@"立即购买" forState:0];
        kaitongBtn.titleLabel.font = SYS_Font(15);
        kaitongBtn.layer.cornerRadius = 5;
        kaitongBtn.layer.masksToBounds = YES;
        [kaitongBtn setBackgroundColor:normalColors];
        [kaitongBtn addTarget:self action:@selector(doBuyNow) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:kaitongBtn];
    }
    return _bottomView;
}

- (void)doBuyNow {
    if (!self.payTypeView) {
        self.payTypeView = [[SWPayTypeSelectView alloc] init];
        WeakSelf;
        self.payTypeView.block = ^(NSString * _Nonnull type) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf doPayWith:type];
            });
        };
        [[UIApplication sharedApplication].keyWindow addSubview:self.payTypeView];
    } else {
        [self.payTypeView show];
    }
}

- (void)doPayWith:(NSString *)type {
    [MBProgressHUD showMessage:@"正在支付"];
    [SWToolClass postNetworkWithUrl:@"coursebuy" andParameter:@{@"courseid": minstr([self.courseMessageDictionary valueForKey:@"id"]), @"payType": type, @"from": @"ios"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            if ([type isEqual:@"yue"]) {
                [self changeBuyState];
                [MBProgressHUD showError:msg];
            } else {
                NSDictionary *result = [info valueForKey:@"result"];
                NSDictionary *jsConfig = [result valueForKey:@"jsConfig"];
                [WXApi registerApp:minstr([jsConfig valueForKey:@"appid"]) universalLink:WechatUniversalLink];
                NSString *times = [jsConfig objectForKey:@"timestamp"];
                PayReq *req = [[PayReq alloc] init];
                req.partnerId = [jsConfig objectForKey:@"partnerid"];
                NSString *pid = [NSString stringWithFormat:@"%@", [jsConfig objectForKey:@"prepayid"]];
                if ([pid isEqual:[NSNull null]] || pid == NULL || [pid isEqual:@"null"]) {
                    pid = @"123";
                }
                req.prepayId = pid;
                req.nonceStr = [jsConfig objectForKey:@"noncestr"];
                req.timeStamp = times.intValue;
                req.package = [jsConfig objectForKey:@"package"];
                req.sign = [jsConfig objectForKey:@"sign"];
                [WXApi sendReq:req completion:^(BOOL success) {
                }];
            }
        } else {
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
}

- (void)wxPayResult:(NSNotification *)not {
    [MBProgressHUD hideHUD];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    PayResp *response = not.object;
    switch (response.errCode) {
        case WXSuccess:
            NSLog(@"支付成功");
            [self changeBuyState];
            [MBProgressHUD showError:@"支付成功"];
            break;
        case WXErrCodeUserCancel:
            [MBProgressHUD showError:@"已取消支付"];
            break;
        default:
            [MBProgressHUD showError:@"支付失败"];
            break;
    }
}

- (void)changeTYPageBarVIewFrame:(CGFloat)yyyyy {
    self.tabBar.frame = CGRectMake(0, yyyyy, _window_width, 50);
    self.pageView.frame = CGRectMake(0, self.tabBar.bottom, _window_width, _window_height - self.tabBar.bottom);
    [self reloadData];
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
