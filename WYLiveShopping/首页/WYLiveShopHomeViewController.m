//
//  WYLiveShopHomeViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/31.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYLiveShopHomeViewController.h"
#import "WYBadgeButton.h"
#import <SDCycleScrollView/SDCycleScrollView.h>
#import "WYHomeShopColCell.h"
#import "GoodsDetailsViewController.h"
#import "WYButton.h"
#import "WYHomeLiveView.h"
#import <SDCycleScrollView/TAPageControl.h>
#import "WYSignInViewController.h"
#import "WYHomeVideoView.h"
#import "GoodsSearchViewController.h"
#import "WSLWaterFlowLayout.h"
#import "WYFootprintViewController.h"
#import "WYStoreHomeTbabarViewController.h"
#import "ScanCodeViewController.h"
#import "WYSelectedStoreViewController.h"
#import "WYAllLiveViewController.h"
#import "WYAllVideoViewController.h"
#import "WYLiveCourseViewController.h"
#import "WYGetCouponViewController.h"
#import "WYTabBarController.h"
#import "AppDelegate.h"
#import "HomeMenuView.h"
#import "MyCollectedGoodsViewController.h"
#import "spreadViewController.h"
#import "MineOrderPageViewController.h"
#import "OptimizationViewController.h"

@interface WYLiveShopHomeViewController ()<SDCycleScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,SDCycleScrollViewDelegate,WSLWaterFlowLayoutDelegate,UIScrollViewDelegate,TUIConversationListControllerListener>{
    NSMutableArray *sliderArray;//轮播图数组
    NSMutableArray *dataArray;//商品
    int page;
    NSMutableArray *functionBtnArray;//十个功能按钮数组
    UIView *functionBtnView;//功能按钮背景view
    NSArray *menusArray;
    UIButton *adView;//广告view
    UIView *recommendView;//直播视频课程推荐view
    UIScrollView *liveScrollView;
    UIView *videoClassView;
    UIScrollView *courseClassView;
    UIView *goodsClassView;
    WSLWaterFlowLayout * _flow;
    NSDictionary *homeMessageDic;
    NSTimer *liveTimer;
}
@property (nonatomic,strong) WYBadgeButton *messageBtn;
@property (nonatomic,strong) UIButton *scanBtn;
@property (nonatomic,strong) UIButton *searchBtn;
@property (nonatomic,strong) SDCycleScrollView *cycleScrollView;//轮播图
@property (nonatomic,strong) UICollectionView *homeCollectionView;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) TAPageControl *livePageC;

@end

@implementation WYLiveShopHomeViewController
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)getCurrentUnread{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[V2TIMManager sharedInstance] getTotalUnreadMessageCount:^(UInt64 totalCount) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_messageBtn showBadgeWithNumber:totalCount];
            });
        } fail:^(int code, NSString *desc) {
            
        }];
    });

}
- (void)onTotalUnreadCountChanged:(NSNotification *)notice
{
    id object = notice.object;
    if (![object isKindOfClass:NSNumber.class]) {
        return;
    }
    NSUInteger total = [object integerValue];
    [_messageBtn showBadgeWithNumber:total];
}

#pragma mark -- TUIConversationListControllerListener --- start
- (void)conversationListController:(TUIConversationListController *)conversationController didSelectConversation:(TUIConversationCell *)conversationCell
{
    TUIChatController *chat = [[TUIChatController alloc] init];
    [chat setConversationData:conversationCell.convData];
//    chat.title = conversationCell.convData.title;
    [[MXBADelegate sharedAppDelegate] pushViewController:chat animated:YES];
}
#pragma mark -- TUIConversationListControllerListener --- end
- (void)doMoreGuessGoods{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"guess&page=%d",page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_homeCollectionView.mj_footer endRefreshing];
        if (code == 0) {
            for (NSDictionary *dic in info) {
                liveGoodsModel *model = [[liveGoodsModel alloc]initWithDic:dic];
                [dataArray addObject:model];
            }
            [_homeCollectionView reloadData];

        }
    } Fail:^{
        [_homeCollectionView.mj_footer endRefreshing];
    }];

}
#pragma mark -- 网络请求
- (void)requestData{
    [MBProgressHUD showMessage:@""];
    [WYToolClass getQCloudWithUrl:@"homeindex" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_homeCollectionView.mj_header endRefreshing];
        [MBProgressHUD hideHUD];
        if (code == 200) {
            homeMessageDic = info;
            sliderArray = [homeMessageDic valueForKey:@"banner"];
            NSMutableArray *bannerImageArray = [NSMutableArray array];
            for (NSDictionary *dic in sliderArray) {
                [bannerImageArray addObject:minstr([dic valueForKey:@"pic"])];
            }
            _cycleScrollView.imageURLStringsGroup = bannerImageArray;
            
            [dataArray removeAllObjects];
            for (NSDictionary *dic in [homeMessageDic valueForKey:@"list"]) {
                liveGoodsModel *model = [[liveGoodsModel alloc]initWithDic:dic];
                [dataArray addObject:model];
            }
            [_homeCollectionView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (_headerView) {
                    [self reloadHeaderContent];
                }
            });

        }
    } Fail:^{
        [_homeCollectionView.mj_header endRefreshing];
    }];


}
#pragma mark -- UI - reloadHeaderContent-更新header内容
- (void)reloadHeaderContent{
    menusArray = [homeMessageDic valueForKey:@"menus"];
    for (int i = 0; i < functionBtnArray.count; i ++) {
        WYButton *btn = functionBtnArray[i];
        if (i < menusArray.count) {
            btn.hidden = NO;
            NSDictionary *dic = menusArray[i];
            [btn.showImgView sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"pic"])]];
            [btn setShowText:minstr([dic valueForKey:@"name"])];
        }else{
            btn.hidden = YES;
        }
    }
    [liveScrollView removeAllSubviews];
    liveScrollView.contentSize = CGSizeMake(0, 0);
    NSArray *liveA = [homeMessageDic valueForKey:@"live"];
    for (int i = 0; i < liveA.count; i ++) {
        NSLog(@"===========ceshizhibo===========");
        WYHomeLiveView *live = [[WYHomeLiveView alloc]initWithFrame:CGRectMake(i * liveScrollView.width, 0, liveScrollView.width, liveScrollView.height)];
        live.msgDic = liveA[i];
        [liveScrollView addSubview:live];
    }
    liveScrollView.contentSize = CGSizeMake(liveScrollView.width * liveA.count, 0);
    _livePageC.numberOfPages = liveA.count;
    
    if (liveTimer) {
        [liveTimer invalidate];
        liveTimer = nil;
    }
    if (liveA.count > 0) {
        liveTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(linkClick) userInfo:nil repeats:YES];
    }
    NSDictionary *adv_space = [homeMessageDic valueForKey:@"adv_space"];
    if ([minstr([adv_space valueForKey:@"id"]) isEqual:@"0"]) {
        adView.height = 0;
        adView.hidden = YES;
    }else{
        [adView sd_setImageWithURL:[NSURL URLWithString:minstr([[homeMessageDic valueForKey:@"adv_space"] valueForKey:@"pic"])] forState:0];
        adView.height = _window_width*0.32;
        adView.hidden = NO;
    }
    
    [videoClassView removeAllSubviews];
    NSArray *videoA = [homeMessageDic valueForKey:@"video"];
    for (int i = 0; i < videoA.count; i ++) {
        WYHomeVideoView *video = [[WYHomeVideoView alloc]initWithFrame:CGRectMake(i * ((videoClassView.width-16)/3 + 8), 0, (videoClassView.width-16)/3, videoClassView.height)];
        video.isVideo = YES;
        video.msgDic = videoA[i];
        [videoClassView addSubview:video];
    }
    
    [courseClassView removeAllSubviews];
    NSArray *courseA = [homeMessageDic valueForKey:@"course"];
    for (int i = 0; i < courseA.count; i ++) {
        WYHomeVideoView *course = [[WYHomeVideoView alloc]initWithFrame:CGRectMake(i * (courseClassView.height * 1.47 + 10), 0, courseClassView.height * 1.47, courseClassView.height)];
        course.isVideo = NO;
        course.msgDic = courseA[i];
        [courseClassView addSubview:course];
    }
    courseClassView.contentSize = CGSizeMake((courseClassView.height * 1.47 + 10) * courseA.count, 0);
    
    [goodsClassView removeAllSubviews];
    NSArray *module = [homeMessageDic valueForKey:@"module"];
    int counttt;
    if ([minstr([homeMessageDic valueForKey:@"style"]) isEqual:@"2"]) {
        if ((module.count-1)%2 == 0) {
            counttt = (int)(module.count-1)/2+1;
        }else{
            counttt = (int)(module.count-1)/2+2;
        }
    }else{
        if (module.count%2 == 0) {
            counttt = (int)module.count/2;
        }else{
            counttt = (int)module.count/2+1;
        }
    }
    goodsClassView.frame = CGRectMake(0, adView.bottom, _window_width, 15+counttt*145);
//
//    goodsClassView.height = 15+counttt*145;
    UIView *goodsClassContentView = [[UIView alloc]initWithFrame:CGRectMake(10, 5, goodsClassView.width-20, goodsClassView.height-15)];
    goodsClassContentView.backgroundColor = [UIColor whiteColor];
    goodsClassContentView.layer.cornerRadius = 5;
    goodsClassContentView.clipsToBounds = YES;
    [goodsClassView addSubview:goodsClassContentView];
    CGFloat lastBottom = 0.0;
    CGFloat lastRight = 0.0;
    for (int i = 0; i < module.count; i ++) {
        HomeMenuView *menu = [[[NSBundle mainBundle] loadNibNamed:@"HomeMenuView" owner:nil options:nil] lastObject];
        if (i == 0 && [minstr([homeMessageDic valueForKey:@"style"]) isEqual:@"2"]) {
            menu.frame = CGRectMake(lastRight, lastBottom, goodsClassContentView.width, 145);
        }else{
            menu.frame = CGRectMake(lastRight, lastBottom, goodsClassContentView.width/2, 145);
        }
        [goodsClassContentView addSubview:menu];
        NSDictionary *dic = module[i];
        menu.msgDic = dic;
        lastRight = menu.right;
        if (lastRight > goodsClassContentView.width*0.6) {
            lastRight = 0;
            lastBottom = menu.bottom;
        }
    }
//    for (int i = 1; i<count ; i ++) {
//        [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, i * iteamHeight, goodsClassContentView.width, 1) andColor:colorf0 andView:goodsClassContentView];
//    }
//    [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(goodsClassContentView.width/2-0.5, 0, 1, goodsClassContentView.height) andColor:colorf0 andView:goodsClassContentView];

    _headerView.height = goodsClassView.bottom+60;
    [_homeCollectionView reloadData];
//    UICollectionViewFlowLayout *layout = (id)_homeCollectionView.collectionViewLayout;
//    layout.headerReferenceSize = CGSizeMake(_window_width, _headerView.height);
//    _homeCollectionView.collectionViewLayout = layout;

}

#pragma mark -- viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [[TUIKitListenerManager sharedInstance] addConversationListControllerListener:self];
    dataArray = [NSMutableArray array];
    page = 2;
    functionBtnArray = [NSMutableArray array];
    [self addheaderView];
    [self.view addSubview:self.homeCollectionView];
    [self requestData];
    [self getCurrentUnread];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onTotalUnreadCountChanged:) name:TUIKitNotification_onTotalUnreadMessageCountChanged object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(videoDelate:) name:@"videoDelete" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(videoDelate:) name:@"videoDelete" object:nil];
}
- (void)videoDelate:(NSNotification *)not{
    [_homeCollectionView.mj_header beginRefreshing];
}
#pragma mark -- UI - 头部试图
- (void)addheaderView{
    UIView *navi =[[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navi.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navi];
    
    UIButton *iconBtn = [UIButton buttonWithType:0];
    [iconBtn setImage:[WYToolClass getAppIcon] forState:0];
    [iconBtn setCornerRadius:15];
    iconBtn.frame = CGRectMake(15, statusbarHeight+27, 30, 30);
    [iconBtn addTarget:self action:@selector(iconBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navi addSubview:iconBtn];
    
    self.messageBtn = [[WYBadgeButton alloc] initWithFrame:CGRectMake(_window_width-45, 26.5 + statusbarHeight, 35, 35)];
    [_messageBtn setImage:[UIImage imageNamed:@"home_message"] forState:0];
    [_messageBtn setTitle:@"消息" forState:0];
    [_messageBtn setTitleColor:color32 forState:0];
    _messageBtn.titleLabel.font = SYS_Font(9);
    [_messageBtn addTarget:self action:@selector(doMessage) forControlEvents:UIControlEventTouchUpInside];
    [navi addSubview:self.messageBtn];
    _messageBtn = (WYBadgeButton *)[WYToolClass setUpImgDownText:_messageBtn];
    
    self.scanBtn = [UIButton buttonWithType:0];
    _scanBtn.frame = CGRectMake(_window_width-85, 26.5 + statusbarHeight, 70, 70);
    [_scanBtn setImage:[UIImage imageNamed:@"home_scan"] forState:0];
    [_scanBtn setTitle:@"扫一扫" forState:0];
    [_scanBtn setTitleColor:color32 forState:0];
    _scanBtn.titleLabel.font = SYS_Font(9);
    [_scanBtn addTarget:self action:@selector(doScan) forControlEvents:UIControlEventTouchUpInside];
    [navi addSubview:self.scanBtn];
    _scanBtn = [WYToolClass setUpImgDownText:_scanBtn];
    _scanBtn.size = CGSizeMake(35, 35);
    _searchBtn = [UIButton buttonWithType:0];
    [_searchBtn setImage:[UIImage imageNamed:@"home_search"] forState:0];
    [_searchBtn setTitle:@" 请输入商品关键词" forState:0];
    [_searchBtn setTitleColor:RGB_COLOR(@"#b4b4b4", 1) forState:0];
    _searchBtn.titleLabel.font = SYS_Font(14);
    [_searchBtn setBackgroundColor:RGB_COLOR(@"#F5F5F5", 1)];
    _searchBtn.layer.cornerRadius = 15;
    _searchBtn.layer.masksToBounds = YES;
    [_searchBtn addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    _searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [navi addSubview:_searchBtn];
    [_searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconBtn.mas_right).offset(15);
        make.right.equalTo(_scanBtn.mas_left).offset(-15);
        make.centerY.equalTo(_messageBtn);
        make.height.mas_equalTo(30);
    }];
}
#pragma mark -- UI - homeCollectionView

- (UICollectionView *)homeCollectionView{
    if (!_homeCollectionView) {
//        WYWaterFallLayout * waterFallLayout = [[WYWaterFallLayout alloc]init];
//        waterFallLayout.delegate = self;
        _flow = [[WSLWaterFlowLayout alloc] init];
        _flow.delegate = self;
        _flow.flowLayoutStyle = 0;

//        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
//        flow.scrollDirection = UICollectionViewScrollDirectionVertical;
//        flow.minimumLineSpacing = 10;
//        flow.minimumInteritemSpacing = 10;
//        flow.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
//        flow.headerReferenceSize = CGSizeMake(_window_width, _window_height);
        _homeCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,64+statusbarHeight, _window_width, _window_height-(64+statusbarHeight+48+ShowDiff)) collectionViewLayout:_flow];
        [_homeCollectionView registerNib:[UINib nibWithNibName:@"WYHomeShopColCell" bundle:nil] forCellWithReuseIdentifier:@"WYHomeShopColCELL"];
        [_homeCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"homeClollectionHeaderView"];

        _homeCollectionView.delegate =self;
        _homeCollectionView.dataSource = self;
        _homeCollectionView.backgroundColor = colorf0;
        _homeCollectionView.mj_footer  = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            page ++;
            [self doMoreGuessGoods];
        }];
        
        _homeCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            page = 2;
            NSLog(@"===========88888888==========");
            [self requestData];
        }];
        if (@available(iOS 13.0, *)) {
            _homeCollectionView.automaticallyAdjustsScrollIndicatorInsets = NO;
        } else {
            // Fallback on earlier versions
        }
        if (@available(iOS 11.0, *)) {
            UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }

    }
    return _homeCollectionView;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return dataArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    GoodsDetailsViewController *vc = [[GoodsDetailsViewController alloc]init];
    liveGoodsModel *model = dataArray[indexPath.row];
    vc.goodsID = model.goodsID;
    vc.liveUid = @"";
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WYHomeShopColCell *cell = (WYHomeShopColCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WYHomeShopColCELL" forIndexPath:indexPath];
    cell.model = dataArray[indexPath.row];
    return cell;
}

#pragma mark ================ collectionview头视图 ===============

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {

        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"homeClollectionHeaderView" forIndexPath:indexPath];
        [header addSubview:self.headerView];
        return header;
    }else{
        return nil;
    }
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    liveGoodsModel *model = dataArray[indexPath.row];
//    return CGSizeMake((_window_width-30)/2, (_window_width-30)/2 + (model.isDouble ? 78 : 58));
//}
- (CGSize)waterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    liveGoodsModel *model = dataArray[indexPath.row];
    return CGSizeMake((_window_width-30)/2, (_window_width-30)/2 + (model.isDouble ? 78 : 58));

}
/** 头视图Size */
-(CGSize )waterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout sizeForHeaderViewInSection:(NSInteger)section{
    if (_headerView) {
        return CGSizeMake(_window_width, _headerView.height);
    }
    return CGSizeMake(_window_width, _window_height);
}
/** 列数*/
-(CGFloat)columnCountInWaterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout{
    return 2;
}
/** 列间距*/
-(CGFloat)columnMarginInWaterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout{
    return 10;
}
/** 边缘之间的间距*/
-(UIEdgeInsets)edgeInsetInWaterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

//#pragma mark  - <WYWaterFallLayoutDeleaget>
//- (CGFloat)waterFallLayout:(WYWaterFallLayout *)waterFallLayout heightForItemAtIndexPath:(NSUInteger)indexPath itemWidth:(CGFloat)itemWidth{
//
//    liveGoodsModel *model = dataArray[indexPath];
//    return (_window_width-30)/2 + (model.isDouble ? 78 : 58);
//}

//- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    return CGSizeMake(_window_width, _window_height);
//}

#pragma mark -- UI - headerView

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        _headerView.backgroundColor = [UIColor whiteColor];
        [self creatHeaderContent];
    }
    return _headerView;
}
- (void)creatHeaderContent{
    [_headerView addSubview:self.cycleScrollView];
    functionBtnView = [[UIView alloc]initWithFrame:CGRectMake(0, _cycleScrollView.bottom, _window_width, _window_width*0.512)];
    [_headerView addSubview:functionBtnView];
    CGFloat btnWidth = _window_width/5;
    for (int i = 0; i < 10; i ++) {
        WYButton *btn = [WYButton buttonWithType:0];
        btn.frame = CGRectMake((i%5) * btnWidth, i/5 * btnWidth, btnWidth, btnWidth);
        [btn setShowImage:[UIImage imageNamed:@"home-signin"]];
        [btn setShowText:@"积分签到"];
        btn.showTitleLabel.font = SYS_Font(11);
        btn.showTitleLabel.textColor = color64;
        btn.tag = 1000 + i;
        [btn addTarget:self action:@selector(functionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [functionBtnView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(functionBtnView).offset((i%5) * btnWidth);
            make.width.height.mas_equalTo(btnWidth);
            make.centerY.equalTo(functionBtnView).multipliedBy(0.5+(i/5));
        }];
        [functionBtnArray addObject:btn];
    }
    recommendView = [[UIView alloc]initWithFrame:CGRectMake(0, functionBtnView.bottom, _window_width, _window_width*0.63)];
    recommendView.backgroundColor = colorf0;
    [_headerView addSubview:recommendView];
    UIView *liveView,*videoView,*courseView;
    NSArray *array = @[@"推荐直播 ",@"精彩视频 ",@"精选内容 "];
    for (int i = 0; i < array.count; i ++) {
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 5;
        view.layer.masksToBounds = YES;
        view.clipsToBounds = YES;
        [recommendView addSubview:view];
        if (i == 0) {
            view.frame = CGRectMake(10, 8, recommendView.width/2-15, recommendView.height-16);
            liveView = view;
        }else if(i == 1){
            view.frame = CGRectMake(recommendView.width/2+5, 8, recommendView.width/2-15, (recommendView.height-26)/2);
            videoView = view;
        }else{
            view.frame = CGRectMake(recommendView.width/2+5, 18+(recommendView.height-26)/2, recommendView.width/2-15, (recommendView.height-26)/2);
            courseView = view;

        }
        UILabel *liveLabel = [[UILabel alloc]init];
        liveLabel.font = [UIFont boldSystemFontOfSize:15];
        liveLabel.textColor = color32;
        [view addSubview:liveLabel];
        [liveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(8);
            make.centerY.equalTo(view.mas_top).offset(18);
        }];
        NSMutableAttributedString *muAttStr = [[NSMutableAttributedString alloc]initWithString:array[i]];
        [muAttStr addAttribute:NSForegroundColorAttributeName value:normalColors range:NSMakeRange(2, 2)];
        [muAttStr addAttribute:NSObliquenessAttributeName value:@0.2 range:NSMakeRange(0, 4)];
        liveLabel.attributedText = muAttStr;
        UIButton *moreBtn = [UIButton buttonWithType:0];
        [moreBtn setImage:[UIImage imageNamed:@"wy-more"] forState:0];
        [moreBtn addTarget:self action:@selector(doMore:) forControlEvents:UIControlEventTouchUpInside];
//        moreBtn.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
//        moreBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        moreBtn.tag = 2000 + i;
        [view addSubview:moreBtn];
        [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(view).offset(-8);
            make.centerY.equalTo(liveLabel);
            make.width.height.mas_equalTo(20);
        }];

    }
//    UIView *liveView = [[UIView alloc]initWithFrame:CGRectMake(10, 8, recommendView.width/2-15, recommendView.height-16)];
//    liveView.backgroundColor = [UIColor whiteColor];
//    liveView.layer.cornerRadius = 5;
//    liveView.layer.masksToBounds = YES;
//    liveView.clipsToBounds = YES;
//    [recommendView addSubview:liveView];

    liveScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(8, 35, liveView.width-16, liveView.height - 50)];
    liveScrollView.pagingEnabled = YES;
    liveScrollView.bounces = NO;
    liveScrollView.delegate = self;
    liveScrollView.showsHorizontalScrollIndicator = NO;
    [liveView addSubview:liveScrollView];
    _livePageC = [[TAPageControl alloc]initWithFrame:CGRectMake(0, liveScrollView.bottom, liveView.width, 15)];
    _livePageC.currentDotImage = [WYToolClass getImgWithColor:normalColors];
    _livePageC.dotImage = [WYToolClass getImgWithColor:RGB_COLOR(@"#000000", 0.2)];
    _livePageC.currentPage = 0;
    _livePageC.dotSize = CGSizeMake(6, 2);
    _livePageC.numberOfPages = 3;
    [liveView addSubview:_livePageC];
    videoClassView = [[UIView alloc]initWithFrame:CGRectMake(8, 35, videoView.width-16, videoView.height - 43)];
    [videoView addSubview:videoClassView];
    
    courseClassView = [[UIScrollView alloc]initWithFrame:CGRectMake(8, 35, courseView.width-16, videoView.height - 43)];
    [courseView addSubview:courseClassView];

    adView = [UIButton buttonWithType:0];
    adView.frame = CGRectMake(0, recommendView.bottom, _window_width, _window_width*0.32);
    [adView setBackgroundColor:[UIColor whiteColor]];
    adView.imageEdgeInsets = UIEdgeInsetsMake(3, 16, 1, 16);
    adView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [adView addTarget:self action:@selector(adCLick) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:adView];
    
    goodsClassView = [[UIView alloc]initWithFrame:CGRectMake(0, adView.bottom, _window_width, _window_width)];
    goodsClassView.backgroundColor = colorf0;
    [_headerView addSubview:goodsClassView];
    
    UIView *tipsView = [[UIView alloc]init];
    [_headerView addSubview:tipsView];
    [tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(goodsClassView);
        make.top.equalTo(goodsClassView.mas_bottom);
        make.height.mas_equalTo(60);
    }];
    UILabel *tipsLabel = [[UILabel alloc]init];
    tipsLabel.font = [UIFont boldSystemFontOfSize:14];
    tipsLabel.text = @"猜你喜欢";
    tipsLabel.textColor = color32;
    [tipsView addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(tipsView);
    }];
    for (int i = 0; i < 2; i ++) {
        UIImageView *imgV = [[UIImageView alloc]init];
        imgV.image = [UIImage imageNamed:@"home-xihuan"];
        [tipsView addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(tipsView);
            if (i == 0) {
                make.right.equalTo(tipsLabel.mas_left).offset(-10);
            }else{
                make.left.equalTo(tipsLabel.mas_right).offset(10);
            }
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(11);
        }];
    }
    _headerView.height = goodsClassView.bottom+60;
//    [_homeCollectionView reloadData];
//    UICollectionViewFlowLayout *layout = (id)_homeCollectionView.collectionViewLayout;
//    layout.headerReferenceSize = CGSizeMake(_window_width, _headerView.height);
//    _homeCollectionView.collectionViewLayout = layout;
}
-(SDCycleScrollView *)cycleScrollView{
    if (!_cycleScrollView) {
        _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(10, 4, _window_width-20, (_window_width - 20)*0.37) delegate:self placeholderImage:nil];
        _cycleScrollView.currentPageDotImage = [WYToolClass getImgWithColor:normalColors];
        _cycleScrollView.pageDotImage = [WYToolClass getImgWithColor:[UIColor whiteColor]];
        _cycleScrollView.pageControlDotSize = CGSizeMake(10, 3);
        _cycleScrollView.layer.cornerRadius = 7.5;
        _cycleScrollView.layer.masksToBounds = YES;
    }
    return _cycleScrollView;
}
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    NSString *urls = minstr([sliderArray[index] valueForKey:@"wap_url"]);
    if (urls.length > 6) {
        WYWebViewController *web = [[WYWebViewController alloc]init];
        web.urls = urls;
        [[MXBADelegate sharedAppDelegate] pushViewController:web animated:YES];
    }
}

#pragma mark -- UIScrollView代理 管理naviView的透明度
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == liveScrollView){
        _livePageC.currentPage = scrollView.contentOffset.x/liveScrollView.width;
    }
}
#pragma mark -- 更多直播
- (void)doMoreLive{
    
}
#pragma mark -- 签到
- (void)doSignIn{
    [MBProgressHUD showMessage:@""];
    [WYToolClass getQCloudWithUrl:@"getSign" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            if (code == 200) {
                WYSignInViewController *vc = [[WYSignInViewController alloc] init];
                vc.messageDic = info;
                [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

            }

        });
    } Fail:^{
        
    }];

}
#pragma mark -- 我的足迹
- (void)doMineFoot{
    WYFootprintViewController *vc = [[WYFootprintViewController alloc] init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

}

#pragma mark -- 广告
- (void)adCLick{
    NSLog(@"---------dianji----------");
    WYWebViewController *vc = [[WYWebViewController alloc] init];
    vc.urls = minstr([[homeMessageDic valueForKey:@"adv_space"] valueForKey:@"url"]);
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

}
#pragma mark -- 消息
- (void)doMessage{
    
//    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
////    data.groupID = @"groupID";  // 如果是群会话，传入对应的群 ID
//    data.userID = @"9";    // 如果是单聊会话，传入对方用户 ID
//    TUIChatController *chat = [[TUIChatController alloc]init];
//    chat.conversationData = data;
//    [[MXBADelegate sharedAppDelegate] pushViewController:chat animated:YES];
    TUIConversationListController *vc = [[TUIConversationListController alloc] init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

}
#pragma mark -- 头像
- (void)iconBtnClick{
}
#pragma mark -- 扫一扫
- (void)doScan{
    ScanCodeViewController *vc = [[ScanCodeViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
#pragma mark -- 搜索
- (void)doSearch{
    GoodsSearchViewController *vc = [[GoodsSearchViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
#pragma mark -- 直播、视频、内容更多按钮点击
- (void)doMore:(UIButton *)sender{
    NSLog(@"==========uuuuuuu=========");
    if (sender.tag == 2000) {
        WYAllLiveViewController *vc = [[WYAllLiveViewController alloc]init];
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }else if (sender.tag == 2001) {
        WYAllVideoViewController *vc =[[WYAllVideoViewController alloc]init];
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }else if (sender.tag == 2002) {
        WYLiveCourseViewController *vc =[[WYLiveCourseViewController alloc]init];
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}
#pragma mark -- 首页功能按钮点击
- (void)functionButtonClick:(UIButton *)sender{
    NSInteger index = sender.tag - 1000;
    int itemID = [minstr([menusArray[index] valueForKey:@"id"]) intValue];
    switch (itemID) {
        case 99:
            //签到
            [self doSignIn];
            break;
        case 100:
            //优惠券
            [self doGetCoupon];
            break;
        case 101:
            //我的足迹
            [self doMineFoot];
            break;
        case 102:
            //我的推广
            [self doAllTuiGuang];
            break;
        case 158:
            //我的订单
            [self doAllOrder];
            break;
        case 105:
            //我的收藏
            [self doMineCollectedGoods];
            break;
        case 159:
            //今日优选
            [self doOptimizationDay];
            break;
        case 160:
            //精选旺铺
            [self doSelectedStore];
            break;
        case 190:
            //帮助中心
            [self doHelpCenter:minstr([menusArray[index] valueForKey:@"wap_url"])];
            break;
        case 192:
            //分类
            [self doShowClass];
            break;

        default:
            break;
    }
}
#pragma mark -- 精选旺铺
- (void)doSelectedStore{
    WYSelectedStoreViewController*vc = [[WYSelectedStoreViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
#pragma mark -- 领券中心
- (void)doGetCoupon{
    WYGetCouponViewController*vc = [[WYGetCouponViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
#pragma mark -- 我的收藏
- (void)doMineCollectedGoods{
    MyCollectedGoodsViewController*vc = [[MyCollectedGoodsViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

#pragma mark -- 分类
- (void)doShowClass{
    UIApplication *app =[UIApplication sharedApplication];
    AppDelegate *app2 = (AppDelegate *)app.delegate;
    WYTabBarController *tabbarVc = (WYTabBarController*)app2.window.rootViewController;
    tabbarVc.selectedIndex = 1;
}
#pragma mark -- 我的推广
- (void)doAllTuiGuang{
    spreadViewController *vc = [[spreadViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
#pragma mark -- 全部订单
- (void)doAllOrder{
    MineOrderPageViewController *vc = [[MineOrderPageViewController alloc]init];
//    vc.orderStatusNum = orderStatusNum;
    vc.showIndex = 0;
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
#pragma mark -- 今日优选
- (void)doOptimizationDay{
    OptimizationViewController *vc = [[OptimizationViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
#pragma mark -- 帮助中心
- (void)doHelpCenter:(NSString *)url{
    WYWebViewController *vc = [[WYWebViewController alloc]init];
    vc.urls = [NSString stringWithFormat:@"%@/appapi/help/list",h5url];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)linkClick{
    NSArray *liveA = [homeMessageDic valueForKey:@"live"];
    if (_livePageC.currentPage == liveA.count - 1) {
        [liveScrollView setContentOffset:CGPointMake(0, 0)];
    }else{
        [liveScrollView setContentOffset:CGPointMake(liveScrollView.width * (_livePageC.currentPage + 1), 0)];

    }
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
