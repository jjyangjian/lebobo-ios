//
//  SWGoodsDetailsViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/19.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWGoodsDetailsViewController.h"
#import "SWHomeViewController.h"
#import "SWHZPhotoBrowser.h"
#import "SWDetailesGoodCell.h"
#import "SWProductView.h"
#import "SWCarView.h"
#import "SWReplyCell.h"
#import "SWReplyListViewController.h"
#import "WMPlayer.h"
#import "SWUseCouponView.h"
#import "SWSubmitOrderVC.h"
#import "SWGoodsShareView.h"
#import "SWStoreHomeTbabarViewController.h"
#import "SWYBLookVideoVC.h"
#import "SWMineVideoListVC.h"
#import "SWLivePlayerViewController.h"
#import "SWLiveForGoodsMoreViewController.h"

@interface SWGoodsDetailsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,WKNavigationDelegate,UIScrollViewDelegate,WMPlayerDelegate>{
    NSMutableArray *imageArray;
    NSString *description;
    
    
}
@property (nonatomic,strong) SWHoverPageScrollView *backScrollView;
@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) UIView *naviView;
@property (nonatomic,strong) NSMutableArray *naviBtnArray;

@property (nonatomic,strong) UIView *lineView;

@property (nonatomic,strong) UIView *goodsView;

@property (nonatomic,strong) UIView *SWEvaluateView;

@property (nonatomic,strong) UIScrollView *cycleScrollView;//轮播图
@property (nonatomic,strong) WMPlayer *wmPlayer;
@property (nonatomic,strong) UIPageControl *sliderPageC;

@property (nonatomic,strong) UIView *storeView;

@property (nonatomic,strong) UIView *videoView;
@property (nonatomic,strong) NSArray *videoArray;
@property (nonatomic,strong) UIScrollView *videoScrollView;

@property (nonatomic,strong) UIView *goodListView;
@property (nonatomic,strong) UICollectionView *goodCollectionView;
@property (nonatomic,strong) UIPageControl *goodPageC;

@property (nonatomic,strong) SWCarView *carView;

@property (nonatomic,strong) UIView *addGoodsToStoreView;

@property (nonatomic,strong) UIView *liveTipsView;
@property (nonatomic,strong) NSArray *liveArray;
@property (nonatomic,strong) SWUseCouponView *couponDrawView;
@property (nonatomic,strong) SWGoodsShareView *shareView;
@property (nonatomic,copy) NSString *storeID;
@property (nonatomic,copy) NSString *storeName;
@property (nonatomic,strong) NSDictionary *storeInfo;
@property (nonatomic,strong) NSArray *productAttr;
@property (nonatomic,strong) id productValue;
@property (nonatomic,copy) NSString *selectedUniqueID;
@property (nonatomic,strong) SWProductView *productSelectView;
@property (nonatomic,strong) NSMutableArray *sliderArray;
@property (nonatomic,strong) NSMutableArray *recommendedGoodsArray;
@property (nonatomic,strong) UIImageView *videoPlaceholderImageView;
@property (nonatomic,strong) UILabel *priceLabel;
@property (nonatomic,strong) UIImageView *vipImageView;
@property (nonatomic,strong) UILabel *goodsNameLabel;
@property (nonatomic,strong) UILabel *oldPriceLabel;
@property (nonatomic,strong) UILabel *stockLabel;
@property (nonatomic,strong) UILabel *salesLabel;
@property (nonatomic,strong) UIView *integralView;
@property (nonatomic,strong) UILabel *integralLabel;
@property (nonatomic,strong) UIView *couponView;
@property (nonatomic,strong) UIView *specificationsView;
@property (nonatomic,strong) UILabel *specificationsLabel;
@property (nonatomic,strong) UILabel *evaluateCountLabel;
@property (nonatomic,strong) UILabel *positiveRateLabel;
@property (nonatomic,strong) UIImageView *storeThumbnailImageView;
@property (nonatomic,strong) UILabel *storeNameLabel;
@property (nonatomic,strong) UILabel *storeDescriptionLabel;
@property (nonatomic,strong) UILabel *storeServiceLabel;
@property (nonatomic,strong) UILabel *storeLogisticsLabel;
@property (nonatomic,strong) UILabel *storeTypeLabel;

@end

@implementation SWGoodsDetailsViewController
-(UIScrollView *)backScrollView{
    if (!_backScrollView) {
        _backScrollView = [[SWHoverPageScrollView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height-50-ShowDiff)];
        _backScrollView.backgroundColor = [UIColor whiteColor];
        _backScrollView.showsVerticalScrollIndicator = NO;
        _backScrollView.bounces = NO;
        _backScrollView.delegate = self;
        if (@available(iOS 11.0, *)){
            _backScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _backScrollView.contentSize = CGSizeMake(0, _window_height * 2);

    }
    return _backScrollView;;
}

#pragma mark -- UIScrollView代理 管理naviView的透明度
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _backScrollView) {
        _naviView.alpha = _backScrollView.contentOffset.y/128.00;
        _goodCollectionView.scrollEnabled = NO;
        _cycleScrollView.scrollEnabled = NO;
        UIButton *btn;
        if (scrollView.contentOffset.y + (64 + statusbarHeight) < _SWEvaluateView.y) {
            btn = _naviBtnArray[0];
        }else if (scrollView.contentOffset.y + (64 + statusbarHeight) < _goodListView.y){
            btn = _naviBtnArray[1];
        }else if (scrollView.contentOffset.y + (64 + statusbarHeight) < _webView.y){
            btn = _naviBtnArray[2];
        }else{
            btn = _naviBtnArray[3];
        }
        _lineView.centerX = btn.centerX;

    }else if (scrollView == _goodCollectionView){
        _backScrollView.scrollEnabled = NO;
        _goodPageC.currentPage = scrollView.contentOffset.x/_window_width;
    }else if (scrollView == _cycleScrollView){
        if (self.wmPlayer) {
            [self.wmPlayer pause];
        }
        _backScrollView.scrollEnabled = NO;
        _sliderPageC.currentPage = scrollView.contentOffset.x/_window_width;
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _backScrollView.scrollEnabled = YES;
    _goodCollectionView.scrollEnabled = YES;
    _cycleScrollView.scrollEnabled = YES;
}
#pragma mark -- 商品信息视图
- (UIView *)goodsView{
    if (!_goodsView) {
        _goodsView = [[UIView alloc]init];
        _goodsView.backgroundColor = [UIColor whiteColor];
    }
    return _goodsView;
}
- (void)creatGoodsMessage{
    [_goodsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(_backScrollView);
        make.top.equalTo(_cycleScrollView.mas_bottom);
    }];
    self.priceLabel = [[UILabel alloc]init];
    self.priceLabel.font = SYS_Font(13);
    self.priceLabel.textColor = color32;
    [_goodsView addSubview:self.priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(_goodsView).offset(15);
    }];
    if (!_isAdd) {
        self.vipImageView = [[UIImageView alloc]init];
        self.vipImageView.image = [UIImage imageNamed:@"VIPidentifi"];
        self.vipImageView.hidden = YES;
        [_goodsView addSubview:self.vipImageView];
        [self.vipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.priceLabel.mas_centerY).offset(-1);
            make.left.equalTo(self.priceLabel.mas_right).offset(3);
            make.height.mas_equalTo(10);
            make.width.mas_equalTo(23);
        }];
        UIButton *shareBtn = [UIButton buttonWithType:0];
        [shareBtn setImage:[UIImage imageNamed:@"web_share"] forState:0];
        [shareBtn addTarget:self action:@selector(doShare) forControlEvents:UIControlEventTouchUpInside];
        [_goodsView addSubview:shareBtn];
        [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_goodsView).offset(-15);
            make.centerY.equalTo(self.priceLabel);
            make.width.height.mas_equalTo(30);
        }];
    }
    self.goodsNameLabel = [[UILabel alloc]init];
    self.goodsNameLabel.font = [UIFont boldSystemFontOfSize:15];
    self.goodsNameLabel.textColor = color32;
    self.goodsNameLabel.numberOfLines = 0;
    [_goodsView addSubview:self.goodsNameLabel];
    [self.goodsNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.priceLabel);
        make.top.equalTo(self.priceLabel.mas_bottom).offset(15);
        make.width.equalTo(_goodsView).offset(-30);
    }];
    
    for (int i = 0; i < 3; i ++) {
        UILabel *label = [[UILabel alloc]init];
        label.font = SYS_Font(13);
        label.textColor = color64;
        [_goodsView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.goodsNameLabel.mas_bottom).offset(10);
        }];
        if (i == 0) {
            [label mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.priceLabel);
            }];
            self.oldPriceLabel = label;
        }else if (i == 1){
            [label mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_goodsView);
            }];
            self.stockLabel = label;
        }else{
            [label mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.goodsNameLabel);
            }];
            self.salesLabel = label;
        }
    }
    UIView *llView = [[UIView alloc]init];
    llView.backgroundColor = colorf0;
    [_goodsView addSubview:llView];
    [llView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(_goodsView);
        make.top.equalTo(self.oldPriceLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(0.5);
    }];
    self.integralView = [[UIView alloc]init];
    self.integralView.backgroundColor = [UIColor whiteColor];
    self.integralView.hidden = YES;
    [_goodsView addSubview:self.integralView];
    [self.integralView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(_goodsView);
        make.top.equalTo(llView.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    UILabel *zengL = [[UILabel alloc]init];
    zengL.font = SYS_Font(15);
    zengL.textColor = color64;
    zengL.text = @"赠积分：";
    [self.integralView addSubview:zengL];
    [zengL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.integralView).offset(15);
        make.centerY.equalTo(self.integralView);
    }];
    UIImageView *imageV = [[UIImageView alloc]init];
    imageV.image = [UIImage imageNamed:@"赠送积分"];
    [self.integralView addSubview:imageV];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(zengL.mas_right).offset(10);
        make.centerY.equalTo(zengL);
        make.height.mas_equalTo(20);
    }];
    self.integralLabel = [[UILabel alloc]init];
    self.integralLabel.font = SYS_Font(13);
    self.integralLabel.textColor = normalColors;
    [self.integralView addSubview:self.integralLabel];
    [self.integralLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageV).offset(12);
        make.right.equalTo(imageV).offset(-12);
        make.center.equalTo(imageV);
    }];

    UIView *llView2 = [[UIView alloc]init];
    llView2.backgroundColor = colorf0;
    [self.integralView addSubview:llView2];
    [llView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.width.equalTo(self.integralView);
        make.height.mas_equalTo(0.5);
    }];

    self.couponView  = [[UIView alloc]init];
    self.couponView.backgroundColor = [UIColor whiteColor];
    [_goodsView addSubview:self.couponView];
    [self.couponView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.width.equalTo(_goodsView);
       make.top.equalTo(self.integralView.mas_bottom);
       make.height.mas_equalTo(60);
    }];
    UILabel *youhuiL = [[UILabel alloc]init];
    youhuiL.font = SYS_Font(15);
    youhuiL.textColor = color64;
    youhuiL.text = @"优惠券：";
    [self.couponView addSubview:youhuiL];
    [youhuiL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.couponView).offset(15);
        make.centerY.equalTo(self.couponView).offset(-5);
    }];
    UIImageView *rightImgV1 = [[UIImageView alloc]init];
    rightImgV1.image = [UIImage imageNamed:@"detalies右"];
    [self.couponView addSubview:rightImgV1];
    [rightImgV1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.couponView).offset(-10);
        make.centerY.equalTo(youhuiL);
        make.width.height.mas_equalTo(15);
    }];
    UIView *llView3 = [[UIView alloc]init];
    llView3.backgroundColor = colorf0;
    [self.couponView addSubview:llView3];
    [llView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.width.equalTo(self.couponView);
        make.height.mas_equalTo(10);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showCouponView)];
    [self.couponView addGestureRecognizer:tap];
    
    
    
    self.specificationsView  = [[UIView alloc]init];
    self.specificationsView.backgroundColor = [UIColor whiteColor];
    self.specificationsView.hidden = YES;
    [_goodsView addSubview:self.specificationsView];
    [self.specificationsView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.width.equalTo(_goodsView);
         make.top.equalTo(self.couponView.mas_bottom);
         make.height.mas_equalTo(60);
    }];
    UILabel *guigeL = [[UILabel alloc]init];
    guigeL.font = SYS_Font(15);
    guigeL.textColor = color64;
    guigeL.text = @"规格 ";
    [self.specificationsView addSubview:guigeL];
    [guigeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.specificationsView).offset(15);
        make.centerY.equalTo(self.specificationsView).offset(-5);
    }];
    UIImageView *rightImgV2 = [[UIImageView alloc]init];
    rightImgV2.image = [UIImage imageNamed:@"detalies右"];
    [self.specificationsView addSubview:rightImgV2];
    [rightImgV2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.specificationsView).offset(-10);
        make.centerY.equalTo(guigeL);
        make.width.height.mas_equalTo(15);
    }];
    self.specificationsLabel = [[UILabel alloc]init];
    self.specificationsLabel.font = SYS_Font(15);
    self.specificationsLabel.textColor = color32;
    self.specificationsLabel.text = @"请选择规格";
    [self.specificationsView addSubview:self.specificationsLabel];
    [self.specificationsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(guigeL.mas_right).offset(10);
        make.centerY.equalTo(guigeL);
    }];

    
    UIView *llView4 = [[UIView alloc]init];
    llView4.backgroundColor = colorf0;
    [self.specificationsView addSubview:llView4];
    [llView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.width.equalTo(self.specificationsView);
        make.height.mas_equalTo(10);
    }];
    UIButton *specificationsBtn = [UIButton buttonWithType:0];
    [specificationsBtn addTarget:self action:@selector(doShowProductView) forControlEvents:UIControlEventTouchUpInside];
    [self.specificationsView addSubview:specificationsBtn];
    [specificationsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.width.height.equalTo(self.specificationsView);
    }];
    [_goodsView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.specificationsView.mas_bottom);
    }];
}
#pragma mark -- 优惠券领取
- (void)showCouponView{
    if (!self.couponDrawView) {
        self.couponDrawView = [[SWUseCouponView alloc]initWithCouponID:_goodsID andIsDraw:YES andUsePrice:@"" andCart:@{}];
        [self.view addSubview:self.couponDrawView];
    }else{
        [self.couponDrawView show];
    }
}
- (void)doShare{
    if (!self.shareView) {
        self.shareView = [[SWGoodsShareView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andRoomMessage:self.storeInfo];
        self.shareView.liveUid = _liveUid;
        [self.view addSubview:self.shareView];
    }
    [self.shareView show];
}
#pragma mark -- 评价视图
- (UIView *)SWEvaluateView{
    if (!_SWEvaluateView) {
        _SWEvaluateView = [[UIView alloc]init];
        _SWEvaluateView.backgroundColor = [UIColor whiteColor];
        UILabel *pingjiaL = [[UILabel alloc]init];
        pingjiaL.font = SYS_Font(15);
        pingjiaL.textColor = color32;
        pingjiaL.text = @"用户评价(0)";
        [_SWEvaluateView addSubview:pingjiaL];
        [pingjiaL mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(_SWEvaluateView).offset(15);
            make.centerY.equalTo(_SWEvaluateView.mas_top).offset(25);
        }];
        self.evaluateCountLabel = pingjiaL;
        UIImageView *rightImgV2 = [[UIImageView alloc]init];
        rightImgV2.image = [UIImage imageNamed:@"detalies右"];
        [_SWEvaluateView addSubview:rightImgV2];
        [rightImgV2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_SWEvaluateView).offset(-10);
            make.centerY.equalTo(pingjiaL);
            make.width.height.mas_equalTo(15);
        }];
        
        UILabel *highTipsLabel = [[UILabel alloc]init];
        highTipsLabel.font = SYS_Font(15);
        highTipsLabel.textColor = color64;
        highTipsLabel.text = @"好评率";
        [_SWEvaluateView addSubview:highTipsLabel];
        [highTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(rightImgV2.mas_left).offset(-3);
            make.centerY.equalTo(pingjiaL);
        }];

        self.positiveRateLabel = [[UILabel alloc]init];
        self.positiveRateLabel.font = SYS_Font(15);
        self.positiveRateLabel.textColor = normalColors;
        self.positiveRateLabel.text = @"";
        [_SWEvaluateView addSubview:self.positiveRateLabel];
        [self.positiveRateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(highTipsLabel.mas_left).offset(-1);
            make.centerY.equalTo(pingjiaL);
        }];
        UIButton *btn = [UIButton buttonWithType:0];
        [btn addTarget:self action:@selector(doAllReplys) forControlEvents:UIControlEventTouchUpInside];
        [_SWEvaluateView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(pingjiaL);
            make.right.equalTo(rightImgV2);
            make.left.equalTo(self.positiveRateLabel);
            make.height.mas_equalTo(50);
        }];
    }
    return _SWEvaluateView;
}
//有评价刷新评价视图
- (void)reloadEvaluateView:(NSDictionary *)dic{
    SWReplyModel *model = [[SWReplyModel alloc] initWithDic:dic];
    SWReplyCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"SWReplyCell" owner:nil options:nil] lastObject];
    cell.model = model;
    cell.frame = CGRectMake(0, 50, _window_width, model.rowH);
    [_SWEvaluateView addSubview:cell];
    [_SWEvaluateView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50+model.rowH);
    }];
}
- (void)doAllReplys{
    SWReplyListViewController *vc = [[SWReplyListViewController alloc]init];
    vc.goodsID = _goodsID;
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
- (UIView *)storeView{
    if (!_storeView) {
        _storeView = [[UIView alloc]init];
        _storeView.backgroundColor = [UIColor whiteColor];
        UIView *llView = [[UIView alloc]init];
        llView.backgroundColor = colorf0;
        [_storeView addSubview:llView];
        [llView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.top.equalTo(_storeView);
            make.height.mas_equalTo(10);
        }];

        self.storeThumbnailImageView = [[UIImageView alloc]init];
        self.storeThumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.storeThumbnailImageView.layer.cornerRadius = 25;
        self.storeThumbnailImageView.layer.masksToBounds = YES;
        [_storeView addSubview:self.storeThumbnailImageView];
        [self.storeThumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_storeView).offset(15);
            make.top.equalTo(_storeView).offset(20);
            make.width.height.mas_equalTo(50);
        }];
        self.storeNameLabel = [[UILabel alloc]init];
        self.storeNameLabel.font = [UIFont boldSystemFontOfSize:15];
        self.storeNameLabel.textColor = color32;
        [_storeView addSubview:self.storeNameLabel];
        [self.storeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.storeThumbnailImageView.mas_right).offset(8);
            make.centerY.equalTo(self.storeThumbnailImageView).multipliedBy(0.8);
        }];
        UILabel *ziying = [[UILabel alloc]init];
        ziying.hidden = YES;
        ziying.font = SYS_Font(10);
        ziying.textColor = [UIColor whiteColor];
        ziying.text = @"自营";
        ziying.layer.cornerRadius = 3;
        ziying.layer.masksToBounds = YES;
        ziying.textAlignment = NSTextAlignmentCenter;
        ziying.backgroundColor = normalColors;
        [_storeView addSubview:ziying];
        [ziying mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.storeNameLabel.mas_right).offset(3);
            make.centerY.equalTo(self.storeNameLabel);
            make.width.mas_equalTo(26);
            make.height.mas_equalTo(15);
        }];
        self.storeTypeLabel = ziying;
        UIImageView *rightImgV2 = [[UIImageView alloc]init];
        rightImgV2.image = [UIImage imageNamed:@"detalies右_color"];
        [_storeView addSubview:rightImgV2];
        [rightImgV2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_storeView).offset(-10);
            make.centerY.equalTo(self.storeThumbnailImageView);
            make.width.height.mas_equalTo(15);
        }];
        
        UILabel *storeTipsLabel = [[UILabel alloc]init];
        storeTipsLabel.font = SYS_Font(14);
        storeTipsLabel.textColor = normalColors;
        storeTipsLabel.text = @"进店逛逛";
        [_storeView addSubview:storeTipsLabel];
        [storeTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(rightImgV2.mas_left).offset(-3);
            make.centerY.equalTo(self.storeThumbnailImageView);
        }];

        UIButton *btn = [UIButton buttonWithType:0];
        [btn addTarget:self action:@selector(doStoreHome) forControlEvents:UIControlEventTouchUpInside];
        [_storeView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.storeThumbnailImageView);
            make.right.equalTo(rightImgV2);
            make.left.equalTo(storeTipsLabel);
            make.height.mas_equalTo(60);
        }];
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = RGB_COLOR(@"#fafafa", 1);
        view.layer.cornerRadius = 3;
        [_storeView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_storeView).offset(10);
            make.top.equalTo(self.storeThumbnailImageView.mas_bottom).offset(15);
            make.right.equalTo(_storeView).offset(-10);
            make.height.mas_equalTo(36);
        }];
        
        for (int i = 0; i < 3; i ++) {
            UILabel *label = [[UILabel alloc]init];
            label.font = SYS_Font(12);
            label.textColor = color96;
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(view).multipliedBy(1.0000/3 + i * 2.0000/3);
                make.width.equalTo(view).multipliedBy(1.0000/3);
                make.centerY.equalTo(view);
            }];
            if (i == 0) {
                self.storeDescriptionLabel = label;
            }else if(i == 1){
                self.storeServiceLabel = label;
            }else{
                self.storeLogisticsLabel = label;
            }
        }
    }
    return _storeView;
}
- (void)doStoreHome{
    SWStoreHomeTbabarViewController *vc = [[SWStoreHomeTbabarViewController alloc]initWithID:self.storeID];
//    vc.mer_id = self.storeID;
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
#pragma mark -- 推荐视频
- (UIView *)videoView{
    if (!_videoView) {
        _videoView = [[UIView alloc]init];
        _videoView.backgroundColor = [UIColor whiteColor];
        
        UIView *llView = [[UIView alloc]init];
        llView.backgroundColor = colorf0;
        [_videoView addSubview:llView];
        [llView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.top.equalTo(_videoView);
            make.height.mas_equalTo(10);
        }];
        UILabel *videoL = [[UILabel alloc]init];
        videoL.font = [UIFont boldSystemFontOfSize:13];
        videoL.textColor = color32;
        videoL.text = @"商品推荐视频";
        [_videoView addSubview:videoL];
        [videoL mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(_videoView).offset(15);
            make.centerY.equalTo(_videoView.mas_top).offset(30);
        }];
        UIImageView *rightImgV2 = [[UIImageView alloc]init];
        rightImgV2.image = [UIImage imageNamed:@"detalies右"];
        [_videoView addSubview:rightImgV2];
        [rightImgV2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_videoView).offset(-10);
            make.centerY.equalTo(videoL);
            make.width.height.mas_equalTo(15);
        }];
        
        UILabel *moreLabel = [[UILabel alloc]init];
        moreLabel.font = SYS_Font(15);
        moreLabel.textColor = RGB_COLOR(@"#B5B5B5", 1);
        moreLabel.text = @"查看更多";
        [_videoView addSubview:moreLabel];
        [moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(rightImgV2.mas_left).offset(-3);
            make.centerY.equalTo(videoL);
        }];

        UIButton *btn = [UIButton buttonWithType:0];
        [btn addTarget:self action:@selector(doAllAboutVideo) forControlEvents:UIControlEventTouchUpInside];
        [_videoView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(rightImgV2);
            make.right.equalTo(rightImgV2);
            make.left.equalTo(moreLabel);
            make.height.mas_equalTo(50);
        }];
        CGFloat wwwwww = (_window_width-30)/3;

        _videoScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 55, _window_width, wwwwww+40)];
        _videoScrollView.showsHorizontalScrollIndicator = NO;
        [_videoView addSubview:_videoScrollView];
    }
    return _videoView;
}
- (void)showAboutVideo{
    CGFloat wwwwww = (_window_width-30)/3;
    for (int i = 0; i < (_videoArray.count > 3 ? 3 :_videoArray.count); i ++) {
        NSDictionary *dic = _videoArray[i];
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(10+i*(wwwwww + 10), 0, wwwwww, wwwwww+40);
        [btn setCornerRadius:5];
        [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"thumb"])] forState:0];
        btn.tag = 23000 + i;
        [btn addTarget:self action:@selector(videoClick:) forControlEvents:UIControlEventTouchUpInside];
        [_videoScrollView addSubview:btn];
        UILabel *label = [[UILabel alloc]init];
        label.font = SYS_Font(10);
        label.numberOfLines = 2;
        label.text = minstr([dic valueForKey:@"name"]);
        label.textColor = [UIColor whiteColor];
        [btn addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(btn).offset(5);
            make.right.equalTo(btn).offset(-5);
            make.bottom.equalTo(btn).offset(-8);
        }];
    }
}
- (void)videoClick:(UIButton *)sender{
    SWYBLookVideoVC *video = [[SWYBLookVideoVC alloc]init];
    
    video.fromWhere = @"";
    video.pushPlayIndex = sender.tag - 23000;
    video.videoList = _videoArray.mutableCopy;
    video.sourceBaseUrl = [NSString stringWithFormat:@"productvideo&productid=%@",_goodsID];
    video.pages = 1;
    
//    video.block = ^(NSMutableArray *array, NSInteger page,NSInteger index) {
//        page = page;
//        dataArray = array;
//        [self.collectionView reloadData];
//        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
//    };
    [[SWMXBADelegate sharedAppDelegate] pushViewController:video animated:YES];

}
- (void)doAllAboutVideo{
    SWMineVideoListVC *vc = [[SWMineVideoListVC alloc]init];
    vc.productID = _goodsID;
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
#pragma mark -- 优品推荐
- (UIView *)goodListView{
    if (!_goodListView) {
        self.recommendedGoodsArray = [NSMutableArray array];
        _goodListView = [[UIView alloc]init];
        _goodListView.backgroundColor = [UIColor whiteColor];
        
        UIView *llView1 = [[UIView alloc]init];
        llView1.backgroundColor = colorf0;
        [_goodListView addSubview:llView1];
        [llView1 mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.width.equalTo(_goodListView);
           make.top.equalTo(_goodListView);
           make.height.mas_equalTo(10);
        }];

        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor whiteColor];
        [_goodListView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(_goodListView);
            make.top.equalTo(llView1.mas_bottom);
            make.height.mas_equalTo(50);
        }];
        UILabel *label = [[UILabel alloc]init];
        label.text = @"优品推荐";
        label.font = SYS_Font(15);
        label.textColor = normalColors;
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(view);
        }];
        for (int i = 0; i < 2; i ++) {
            UIImageView *imgV = [[UIImageView alloc]init];
            imgV.image = [UIImage imageNamed:@"优品推荐"];
            [view addSubview:imgV];
            [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(view);
                make.width.height.mas_equalTo(15);
                if (i == 0) {
                    make.right.equalTo(label.mas_left).offset(-20);
                }else{
                    make.left.equalTo(label.mas_right).offset(20);
                }
            }];

        }
        [_goodListView addSubview:self.goodCollectionView];
        [_goodCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(_goodListView);
            make.top.equalTo(view.mas_bottom);
            make.bottom.equalTo(_goodListView).offset(-30);
        }];
        UIView *llView = [[UIView alloc]init];
        llView.backgroundColor = colorf0;
        [_goodListView addSubview:llView];
        [llView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.width.equalTo(_goodListView);
           make.bottom.equalTo(_goodListView);
           make.height.mas_equalTo(10);
        }];

    }
    return _goodListView;
}
- (UIPageControl *)goodPageC{
    if (!_goodPageC) {
        _goodPageC = [[UIPageControl alloc]init];
        _goodPageC.currentPageIndicatorTintColor = normalColors;
        _goodPageC.pageIndicatorTintColor = color64;
    }
    return _goodPageC;
}
- (UICollectionView *)goodCollectionView{
    if (!_goodCollectionView) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
            flow.scrollDirection = UICollectionViewScrollDirectionVertical;
        flow.itemSize = CGSizeMake(_window_width/3-0.01, _window_width/3 + 40);
        flow.minimumLineSpacing = 0;
        flow.minimumInteritemSpacing = 0;
        flow.sectionInset = UIEdgeInsetsMake(5, 0,5, 0);
        flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        flow.headerReferenceSize = CGSizeMake(_window_width, _window_width*0.34);
        _goodCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flow];
        [_goodCollectionView registerNib:[UINib nibWithNibName:@"SWDetailesGoodCell" bundle:nil] forCellWithReuseIdentifier:@"detailesGoodCELL"];
        _goodCollectionView.pagingEnabled = YES;
        _goodCollectionView.delegate =self;
        _goodCollectionView.dataSource = self;
        _goodCollectionView.bounces = NO;
        _goodCollectionView.backgroundColor = RGB_COLOR(@"#ffffff", 1);
        _goodCollectionView.alwaysBounceVertical = NO;

    }
    return _goodCollectionView;

}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.recommendedGoodsArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SWLiveGoodsModel *model = self.recommendedGoodsArray[indexPath.row];
    SWGoodsDetailsViewController *vc = [[SWGoodsDetailsViewController alloc]init];
    vc.goodsID = model.goodsID;
    vc.liveUid = @"";
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SWDetailesGoodCell *cell = (SWDetailesGoodCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"detailesGoodCELL" forIndexPath:indexPath];
    cell.model = self.recommendedGoodsArray[indexPath.row];
    return cell;
}

#pragma mark -- 顶部slider
-(UIScrollView *)cycleScrollView{
    if (!_cycleScrollView) {
        _cycleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_width)];
        _cycleScrollView.delegate = self;
        _cycleScrollView.pagingEnabled = YES;
        _cycleScrollView.backgroundColor = colorf0;
        _cycleScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _cycleScrollView;
}
- (void)creatSliderView:(BOOL)isVideo{
    for (int i = 0; i < self.sliderArray.count; i ++) {
        if (isVideo && i == 0) {
            SWWMPlayerModel *model = [[SWWMPlayerModel alloc]init];
            model.videoURL = [NSURL URLWithString:self.sliderArray[i]];
            model.title = @"";
            if(self.wmPlayer==nil){
                self.wmPlayer = [[WMPlayer alloc] initPlayerModel:model];
            }
            self.wmPlayer.backBtnStyle = BackBtnStylePop;
            self.wmPlayer.loopPlay = NO;//设置是否循环播放
            self.wmPlayer.tintColor = [UIColor whiteColor];//改变播放器着色
            self.wmPlayer.enableBackgroundMode = NO;//开启后台播放模式
            self.wmPlayer.delegate = self;
            self.wmPlayer.topView.hidden = YES;
            self.wmPlayer.bottomView.hidden = YES;

            [self.wmPlayer setPlayerLayerGravity:WMPlayerLayerGravityResizeAspect];
            [_cycleScrollView addSubview:self.wmPlayer];
            [self.wmPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(_cycleScrollView);
                make.top.equalTo(_cycleScrollView);
                make.height.width.mas_equalTo(_window_width);
            }];
            self.videoPlaceholderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_width)];
            [self.videoPlaceholderImageView sd_setImageWithURL:[NSURL URLWithString:minstr([self.storeInfo valueForKey:@"image"])]];
            self.videoPlaceholderImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.videoPlaceholderImageView.clipsToBounds = YES;
            self.videoPlaceholderImageView.userInteractionEnabled = YES;
            [_wmPlayer addSubview:self.videoPlaceholderImageView];

            UIButton *videoPlayBtn = [UIButton buttonWithType:0];
            [videoPlayBtn setImage:[UIImage imageNamed:@"slider_播放"] forState:0];
            [videoPlayBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
            [self.videoPlaceholderImageView addSubview:videoPlayBtn];
            [videoPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(_wmPlayer);
                make.width.height.mas_equalTo(60);
            }];
            //获取设备旋转方向的通知,即使关闭了自动旋转,一样可以监测到设备的旋转方向
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
            //旋转屏幕通知
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(onDeviceOrientationChange:)
                                                         name:UIDeviceOrientationDidChangeNotification
                                                       object:nil
             ];

        }else{
            UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width * i, 0, _window_width, _window_width)];
            [imgV sd_setImageWithURL:[NSURL URLWithString:self.sliderArray[i]]];
            imgV.contentMode = UIViewContentModeScaleAspectFill;
            imgV.clipsToBounds = YES;
            [_cycleScrollView addSubview:imgV];
        }
    }
    _cycleScrollView.contentSize = CGSizeMake(_window_width*self.sliderArray.count, 0);
    [_backScrollView addSubview:self.sliderPageC];
//    _sliderPageC.frame = CGRectMake((_window_width-20*self.sliderArray.count)/2, _window_width-20, 20*self.sliderArray.count, 20);
    _sliderPageC.numberOfPages = self.sliderArray.count;
    _sliderPageC.currentPage = 0;
    [_sliderPageC mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_backScrollView);
        make.bottom.equalTo(_cycleScrollView);
        make.height.mas_equalTo(20);
    }];

}
- (UIPageControl *)sliderPageC{
    if (!_sliderPageC) {
        _sliderPageC = [[UIPageControl alloc]init];
        _sliderPageC.currentPageIndicatorTintColor = normalColors;
        _sliderPageC.pageIndicatorTintColor = color64;
    }
    return _sliderPageC;
}

- (void)playVideo{
    [self.videoPlaceholderImageView removeFromSuperview];
    self.videoPlaceholderImageView = nil;
    self.wmPlayer.bottomView.hidden = NO;
    [_wmPlayer play];
}
//全屏的时候hidden底部homeIndicator
-(BOOL)prefersHomeIndicatorAutoHidden{
    return self.wmPlayer.isFullscreen;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}
-(BOOL)prefersStatusBarHidden{
    return self.wmPlayer.prefersStatusBarHidden;
}
//视图控制器实现的方法
- (BOOL)shouldAutorotate{
//    if (self.forbidRotate) {
//        return NO;
//    }
//    if (self.wmPlayer.playerModel.verticalVideo) {
//        return NO;
//    }
     return !self.wmPlayer.isLockScreen;
}
//viewController所支持的全部旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    //对于present出来的控制器，要主动的（强制的）旋转VC，让wmPlayer全屏
//    UIInterfaceOrientationLandscapeLeft或UIInterfaceOrientationLandscapeRight
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    return UIInterfaceOrientationLandscapeRight;
}
///播放器事件
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    if (wmplayer.isFullscreen) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        //刷新
//        [UIViewController attemptRotationToDeviceOrientation];
    }else{
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
///播放暂停
-(void)wmplayer:(WMPlayer *)wmplayer clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn{
    NSLog(@"clickedPlayOrPauseButton");
}
///全屏按钮
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    if (self.wmPlayer.isFullscreen) {//全屏
        //强制翻转屏幕，Home键在下边。
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }else{//非全屏
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}
///单击播放器
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap{
    [self setNeedsStatusBarAppearanceUpdate];
}
///双击播放器
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap{
    NSLog(@"didDoubleTaped");
    if (wmplayer.isLockScreen) {
        return;
    }
    [wmplayer playOrPause:[wmplayer valueForKey:@"playOrPauseBtn"]];
}
///播放状态
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidFailedPlay");
}
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{

}
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    NSLog(@"wmplayerDidFinishedPlay");
}
-(void)wmplayerGotVideoSize:(WMPlayer *)wmplayer videoSize:(CGSize )presentationSize{
    
}
//操作栏隐藏或者显示都会调用此方法
-(void)wmplayer:(WMPlayer *)wmplayer isHiddenTopAndBottomView:(BOOL)isHidden{
    [self setNeedsStatusBarAppearanceUpdate];
}
//播放进度的代理方法
-(void)wmplayerPlayTime:(WMPlayer *)wmplayer currentTime:(CGFloat)time{

}

/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange:(NSNotification *)notification{
    if (self.wmPlayer.isLockScreen){
        return;
    }
//    if (self.forbidRotate) {
//        return ;
//    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
            [self toOrientation:UIInterfaceOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
            [self toOrientation:UIInterfaceOrientationLandscapeLeft];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
            [self toOrientation:UIInterfaceOrientationLandscapeRight];
        }
            break;
        default:
            break;
    }
}

//点击进入,退出全屏,或者监测到屏幕旋转去调用的方法
-(void)toOrientation:(UIInterfaceOrientation)orientation{
    if (orientation ==UIInterfaceOrientationPortrait) {
        [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.wmPlayer.superview);
            make.top.equalTo(self.view);
            make.height.mas_equalTo(_window_width);
        }];
        self.wmPlayer.isFullscreen = NO;
        self.wmPlayer.topView.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_cycleScrollView addSubview:self.wmPlayer];
        });
    }else{
        [self.view addSubview:self.wmPlayer];
        [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        self.wmPlayer.isFullscreen = YES;
        self.wmPlayer.topView.hidden = NO;

    }
//    self.enablePanGesture = !self.wmPlayer.isFullscreen;
//    self.nextBtn.hidden = self.wmPlayer.isFullscreen;
    if (@available(iOS 11.0, *)) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
}

- (void)releaseWMPlayer{
    [self.wmPlayer pause];
    [self.wmPlayer removeFromSuperview];
    self.wmPlayer = nil;
}

#pragma mark -- 商品简介webview
- (WKWebView *)webView{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, _goodListView.bottom, _window_width, _backScrollView.height)];
        _webView.navigationDelegate = self;
        _webView.opaque = NO;
        _webView.multipleTouchEnabled = YES;
        _webView.scrollView.delegate = self;
        _webView.scrollView.bounces = NO;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.scrollEnabled = NO;
        _webView.scrollView.panGestureRecognizer.enabled = NO;
    }
    return _webView;
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        _webView.frame = CGRectMake(0, _goodListView.bottom, _window_width, [result doubleValue]);//将WKWebView的高度设置为内容高度
        //刷新制定位置Cell
        _backScrollView.contentSize = CGSizeMake(0, _webView.bottom);
    }];
    
    //    插入js代码，对图片进行点击操作
    [webView evaluateJavaScript:@"function assignImageClickAction(){var imgs=document.getElementsByTagName('img');var length=imgs.length;for(var i=0; i < length;i++){img=imgs[i];if(\"ad\" ==img.getAttribute(\"flag\")){var parent = this.parentNode;if(parent.nodeName.toLowerCase() != \"a\")return;}img.onclick=function(){window.location.href='image-preview:'+this.src}}}" completionHandler:^(id object, NSError *error) {
        
    }];
    [webView evaluateJavaScript:@"assignImageClickAction();" completionHandler:^(id object, NSError *error) {
        
    }];
    imageArray = [self getImgs:description];


}
#pragma mark -- 获取文章中的图片个数
- (NSMutableArray *)getImgs:(NSString *)string
{
   
    NSMutableArray *arrImgURL = [[NSMutableArray alloc] init];
    NSArray *array = [string componentsSeparatedByString:@"<img"];
    NSInteger count = [array count] - 1;


    for (int i = 0; i < count; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].src", i];
        [_webView evaluateJavaScript:jsString completionHandler:^(NSString *str, NSError *error) {
            
            if (error ==nil) {
                [arrImgURL addObject:str];
            }
       
        }];
    }
    imageArray = [NSMutableArray arrayWithArray:arrImgURL];
    
    
    return arrImgURL;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSURLRequest *request = navigationAction.request;
    if ([request.URL.scheme isEqualToString: @"image-preview"])
    {
        NSString *url = [request.URL.absoluteString substringFromIndex:14];
        if (imageArray.count != 0) {
            SWHZPhotoBrowser *browserVc = [[SWHZPhotoBrowser alloc] init];
            browserVc.imageArray = imageArray;
            browserVc.imageCount = imageArray.count; // 图片总数
            browserVc.currentImageIndex = (int)[imageArray indexOfObject:url];//当前点击的图片
            [browserVc show];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
    NSLog(@"在发送请求之前：%@",navigationAction.request.URL.absoluteString);
}

#pragma mark -- 导航
- (UIView *)naviView{
    if (!_naviView) {
        _naviBtnArray = [NSMutableArray array];
        _naviView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
        _naviView.backgroundColor = [UIColor whiteColor];
        _naviView.alpha = 0;
        NSArray *array = @[@"商品",@"评价",@"推荐",@"详情"];
        for (int i = 0; i < array.count; i ++) {
            UIButton *btn = [UIButton buttonWithType:0];
            [btn setTitle:array[i] forState:0];
            [btn setTitleColor:color32 forState:0];
            btn.titleLabel.font = SYS_Font(15);
            btn.tag = 1000 + i;
            [btn addTarget:self action:@selector(headerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake(_window_width/2-120 + i * 60 , 24+statusbarHeight, 60, 40);
            [_naviView addSubview:btn];
            [_naviBtnArray addObject:btn];
        }
        [_naviView addSubview:self.lineView];
    }
    return _naviView;
}
-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(_window_width/2-120+15, _naviView.height - 8, 30, 2)];
        _lineView.backgroundColor = normalColors;
    }
    return _lineView;
}
- (void)headerButtonClick:(UIButton *)sender{
    _lineView.centerX = sender.centerX;
    if (sender.tag == 1000) {
        [_backScrollView setContentOffset:CGPointZero];
    }else if (sender.tag == 1001){
        [_backScrollView setContentOffset:CGPointMake(0, _SWEvaluateView.y - (64 + statusbarHeight))];
    }else if (sender.tag == 1002){
        [_backScrollView setContentOffset:CGPointMake(0, _goodListView.y - (64 + statusbarHeight))];
    }else{
        [_backScrollView setContentOffset:CGPointMake(0, _webView.y - (64 + statusbarHeight))];
    }
}

#pragma mark -- 返回按钮
- (void)addReturnBtn{
    UIButton *returnBtn = [UIButton buttonWithType:0];
    returnBtn.frame = CGRectMake(0, 24+statusbarHeight, 40, 40);
    [returnBtn setImage:[UIImage imageNamed:@"navi_backImg_black"] forState:0];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:returnBtn];
    [returnBtn setTintColor:[UIColor blackColor]];

}
- (void)doReturn{
    [self releaseWMPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"DetailViewController dealloc");
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.selectedUniqueID = @"";
    
    [self.view addSubview:self.backScrollView];
    [_backScrollView addSubview:self.cycleScrollView];
    [_backScrollView addSubview:self.goodsView];
    [self creatGoodsMessage];
    [_backScrollView addSubview:self.SWEvaluateView];
    [_SWEvaluateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(_backScrollView);
        make.top.equalTo(_goodsView.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    [_backScrollView addSubview:self.storeView];
    [_storeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(_backScrollView);
        make.top.equalTo(_SWEvaluateView.mas_bottom);
//        make.height.mas_equalTo(140);
    }];
    [_backScrollView addSubview:self.videoView];
    CGFloat wwwwww = (_window_width-30)/3;
    [_videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(_backScrollView);
        make.top.equalTo(_storeView.mas_bottom);
        make.height.mas_equalTo(110 + wwwwww);
    }];

    [_backScrollView addSubview:self.goodListView];
    [_goodListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(_backScrollView);
        make.top.equalTo(_videoView.mas_bottom);
    }];
    [_backScrollView layoutIfNeeded];
    [self.view addSubview:self.naviView];
    if (_isAdd) {
        [self.view addSubview:self.addGoodsToStoreView];
    }else{
        [self.view addSubview:self.carView];
    }
    [self addReturnBtn];
    [self requestData];
}
- (void)requestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"product/detail/%@",_goodsID] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.storeInfo = [info valueForKey:@"storeInfo"];
            self.productAttr = [info valueForKey:@"productAttr"];
            self.productValue = [info valueForKey:@"productValue"];
            [self setGoodsMessage];
            
            self.storeID = minstr([info valueForKey:@"mer_id"]);
            if ([self.storeID integerValue] > 0) {
                _storeView.hidden = NO;
                [_storeView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(140);
                }];
                self.storeName = minstr([info valueForKey:@"shop_name"]);

                self.storeNameLabel.text = minstr([info valueForKey:@"shop_name"]);
                [self.storeThumbnailImageView sd_setImageWithURL:[NSURL URLWithString:minstr([info valueForKey:@"shop_avatar"])]];
                self.storeDescriptionLabel.attributedText = [self setStoreAttMessage:[NSString stringWithFormat:@"宝贝描述 %@",minstr([info valueForKey:@"shop_score1"])] andColor:color64];
                self.storeServiceLabel.attributedText = [self setStoreAttMessage:[NSString stringWithFormat:@"商家服务 %@",minstr([info valueForKey:@"shop_score2"])] andColor:normalColors];
                self.storeLogisticsLabel.attributedText = [self setStoreAttMessage:[NSString stringWithFormat:@"物流服务 %@",minstr([info valueForKey:@"shop_score3"])] andColor:color64];
                if ([minstr([info valueForKey:@"shoptype"]) isEqual:@"2"]) {
                    self.storeTypeLabel.hidden = NO;
                }else{
                    self.storeTypeLabel.hidden = YES;
                }

            }else{
                _storeView.hidden = YES;
                [_storeView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(0);
                }];
            }
            _videoArray = [info valueForKey:@"video"];
            if (_videoArray.count > 0) {
                [self showAboutVideo];
            }else{
                _videoView.hidden = YES;
                [_videoView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(0);
                }];
            }
            NSArray *good_list = [info valueForKey:@"good_list"];
            for (NSDictionary *dic in good_list) {
                SWLiveGoodsModel *model = [[SWLiveGoodsModel alloc]initWithDictionary:dic];
                [self.recommendedGoodsArray addObject:model];
            }
            if (self.recommendedGoodsArray.count > 3) {
                [_goodListView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(95+(_window_width/3+50) * 2);
                }];
            }else if (self.recommendedGoodsArray.count > 0 && self.recommendedGoodsArray.count <= 3){
                [_goodListView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(_window_width/3+50 + 95);
                }];
            }else {
                [_goodListView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(70);
                }];
            }
            [_goodCollectionView reloadData];
            if (self.recommendedGoodsArray.count > 0) {
                [_goodListView addSubview:self.goodPageC];
                _goodPageC.numberOfPages = self.recommendedGoodsArray.count % 6 == 0 ? self.recommendedGoodsArray.count/6 : self.recommendedGoodsArray.count/6+1;
                _goodPageC.currentPage = 0;
                [_goodPageC mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(_goodListView);
                    make.top.equalTo(_goodCollectionView.mas_bottom);
                    make.height.mas_equalTo(20);
                }];
            }
            
            self.evaluateCountLabel.text = [NSString stringWithFormat:@"用户评价(%@)",minstr([info valueForKey:@"replyCount"])];
            self.positiveRateLabel.text = [NSString stringWithFormat:@"%@%%",minstr([info valueForKey:@"replyChance"])];
            id reply = [info valueForKey:@"reply"];
            if ([reply isKindOfClass:[NSDictionary class]] && [reply count] > 0) {
                [self reloadEvaluateView:reply];
            }
            _carView.collectButton.selected = [minstr([self.storeInfo valueForKey:@"userCollect"]) intValue];
            
            description = minstr([self.storeInfo valueForKey:@"description"]);
            NSString * htmlStyle = @" <style type=\"text/css\"> *{min-width: 80% !important;max-width: 100% !important;} table{ width: 100% !important;} img{ height: auto !important;}  </style> ";
            description = [htmlStyle stringByAppendingString:description];
            NSString *aaa = @"<meta content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0\" name=\"viewport\">";
            description = [aaa stringByAppendingString:description];
            if (!_webView) {
                [_backScrollView layoutIfNeeded];
                [_backScrollView addSubview:self.webView];
            }
            [_webView loadHTMLString:description baseURL:nil];
            self.sliderArray = @[].mutableCopy;
            if (minstr([self.storeInfo valueForKey:@"video_link"]).length > 6) {
                [self.sliderArray addObject:minstr([self.storeInfo valueForKey:@"video_link"])];
                [self.sliderArray addObjectsFromArray:[self.storeInfo valueForKey:@"slider_image"]];
                [self creatSliderView:YES];
            }else{
                [self.sliderArray addObjectsFromArray:[self.storeInfo valueForKey:@"slider_image"]];
                [self creatSliderView:NO];
            }
            _liveArray = [info valueForKey:@"live"];
            if (_liveArray.count > 0) {
                [self.view addSubview:self.liveTipsView];
            }

//li{width: 100% !important; height: auto !important; font-size: 30px !important; line-height: 35px !important; white-space: pre-wrap !important; margin-top: 30px !important; display: block;}
        }
    } Fail:^{
        
    }];
}
- (void)setGoodsMessage{
    if ([minstr([self.storeInfo valueForKey:@"vip_price"]) floatValue] == 0) {
        self.priceLabel.attributedText = [self setAttText:minstr([self.storeInfo valueForKey:@"price"]) andVIP:@""];
        self.vipImageView.hidden = YES;
    }else{
        self.priceLabel.attributedText = [self setAttText:minstr([self.storeInfo valueForKey:@"price"]) andVIP:minstr([self.storeInfo valueForKey:@"vip_price"])];
        self.vipImageView.hidden = NO;
    }
    self.goodsNameLabel.text = minstr([self.storeInfo valueForKey:@"store_name"]);
    self.oldPriceLabel.text = [NSString stringWithFormat:@"原价:%@",minstr([self.storeInfo valueForKey:@"ot_price"])];
    self.stockLabel.text = [NSString stringWithFormat:@"库存:%@%@",minstr([self.storeInfo valueForKey:@"stock"]),minstr([self.storeInfo valueForKey:@"unit_name"])];
    self.salesLabel.text = [NSString stringWithFormat:@"销量:%@%@",minstr([self.storeInfo valueForKey:@"sales"]),minstr([self.storeInfo valueForKey:@"unit_name"])];
    NSString *give_integral = minstr([self.storeInfo valueForKey:@"give_integral"]);
    if (![give_integral isEqualToString:@"0.00"]) {
        self.integralLabel.text = [NSString stringWithFormat:@"赠送 %@ 积分",give_integral];
        self.integralView.hidden = NO;
    }else{
        self.integralView.hidden = YES;
        [self.integralView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    if ([self.productAttr count] == 0) {
        self.specificationsView.hidden = YES;
        [self.specificationsView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }else{
        self.specificationsView.hidden = NO;
        if ([self.productValue count] > 0) {
            if ([self.productValue isKindOfClass:[NSDictionary class]]) {
                [self.productValue enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    NSDictionary *dic = obj;
                    if ([minstr([dic valueForKey:@"stock"]) intValue] > 0) {
                        self.selectedUniqueID = minstr([dic valueForKey:@"unique"]);
                        self.specificationsLabel.text = key;
                        *stop = YES;
                    }

                }];
            }
            else{
                for (int i = 0; i < [self.productValue count]; i ++) {
                    NSDictionary *dic = self.productValue[i];
                    if ([minstr([dic valueForKey:@"stock"]) intValue] > 0) {
                        self.selectedUniqueID = minstr([dic valueForKey:@"unique"]);
                        self.specificationsLabel.text = [NSString stringWithFormat:@"%d",i];
                        break;
                    }
                }
            }
            
        }
    }
}
- (NSAttributedString *)setAttText:(NSString *)price andVIP:(NSString *)vipP{
    NSMutableAttributedString *muStr;

    if (vipP.length > 0) {
        muStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"¥ %@ ¥%@",price,vipP]];
    }else{
        muStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"¥ %@ ",price]];
    }
    [muStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, 1)];
    [muStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25] range:NSMakeRange(1, price.length+2)];
    [muStr addAttribute:NSForegroundColorAttributeName value:normalColors range:NSMakeRange(0, price.length+2)];

    return muStr;
}
- (NSAttributedString *)setStoreAttMessage:(NSString *)text andColor:(UIColor *)color{
    if ([text containsString:@"高"]) {
        color = normalColors;
    }else{
        color = color64;
    }
    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc]initWithString:text];
    [muStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12],NSForegroundColorAttributeName:color} range:NSMakeRange(4, text.length-4)];
    return muStr;
}
#pragma mark -- 展示选择规格的view

- (void)doShowProductView{
    if (!self.productSelectView) {
        self.productSelectView = [[SWProductView alloc]initWithFrame:CGRectMake(0, 0, _window_height, _backScrollView.height) andProductAttr:self.productAttr andProductValue:self.productValue andSelectStr:self.specificationsLabel.text andName:minstr([self.storeInfo valueForKey:@"store_name"]) andGoodsMessage:self.storeInfo];
        [self.view addSubview:self.productSelectView];
        self.productSelectView.block = ^(NSString * _Nonnull unique, NSString * _Nonnull keyStr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                  self.selectedUniqueID = unique;
                  self.specificationsLabel.text = keyStr;
            });
        };
    }
    [self.productSelectView show];
}

- (SWCarView *)carView{
    if (!_carView) {
        _carView = [[SWCarView alloc]init];
        if (_liveUid && _liveUid.length > 0) {
            _carView.addButton.hidden = YES;
            _carView.buyButton.layer.cornerRadius = 18;
            _carView.buyButton.layer.masksToBounds = YES;
            _carView.buyButton.frame = CGRectMake(0, 0, _carView.buyButton.superview.width, 36);
        }
        WeakSelf;
        _carView.block = ^(int type) {
            //0加入购物车 1立即购买 2收藏
            if (type == 0) {
//                if (productAttr.count > 0) {
                    if (!self.productSelectView || self.productSelectView.hidden) {
                        [weakSelf doShowProductView];
                    }else{
                        [self.productSelectView doHide];
                        [weakSelf doAddGoodsToCar:0];
                    }
//                }else{
//                    [weakSelf doAddGoodsToCar:0];
//                }
            }else if (type == 1){
//                if (productAttr.count > 0) {
                    if (!self.productSelectView || self.productSelectView.hidden) {
                        [weakSelf doShowProductView];
                    }else{
                        [self.productSelectView doHide];
                        [weakSelf doAddGoodsToCar:1];
                    }
//                }else{
//                    [weakSelf doAddGoodsToCar:1];
//                    [weakSelf doBuyAndPayView];
//                }

            }else if (type == 2){
                [weakSelf doCollectGoods];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.storeID isEqual:[SWConfig getOwnID]]) {
                        [MBProgressHUD showError:@"不能与自己发送私信"];
                        return;
                    }

                    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
                    data.userID = self.storeID;    // 如果是单聊会话，传入对方用户 ID
                    data.title = self.storeName;    // 如果是单聊会话，传入对方用户 ID
                    TUIChatController *chat = [[TUIChatController alloc] init];
                    [chat setConversationData:data];
                //    chat.title = conversationCell.convData.title;
                    [[SWMXBADelegate sharedAppDelegate] pushViewController:chat animated:YES];

                });
            }
        };
    }
    return _carView;
}
- (void)doBuyAndPayView:(NSString *)cartID{
    [SWToolClass postNetworkWithUrl:@"order/confirm" andParameter:@{@"cartId":cartID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [MBProgressHUD hideHUD];
            SWSubmitOrderVC *vc = [[SWSubmitOrderVC alloc]init];
            vc.orderMessage = [info mutableCopy];
            vc.liveUid = _liveUid;
            [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
        }
    } fail:^{
        
    }];

}
- (void)doAddGoodsToCar:(int)newValue{
    //new 0:加入购物车 1:立即购买的时候加入购物车
    NSDictionary *dic = @{
        @"productId":_goodsID,
        @"cartNum":self.productSelectView ? minstr(self.productSelectView.numsTextF.text) : @"1",
        @"uniqueId":self.selectedUniqueID,
        @"new":@(newValue)
    };
    [SWToolClass postNetworkWithUrl:@"cart/add" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            if (newValue == 0) {
                [MBProgressHUD showSuccess:@"添加购物车成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:WYCarNumChange object:nil];
            }
            if (newValue == 1) {
                [self doBuyAndPayView:minstr([info valueForKey:@"cartId"])];
            }

        }
    } fail:^{
        
    }];
}
- (void)doCollectGoods{
    _carView.collectButton.userInteractionEnabled = NO;
    NSString *url;
    if (_carView.collectButton.selected) {
        url = @"collect/del";
    }else{
        url = @"collect/add";
    }
    [SWToolClass postNetworkWithUrl:url andParameter:@{@"id":_goodsID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        _carView.collectButton.userInteractionEnabled = YES;

        if (code == 200) {
//            [MBProgressHUD showError:msg];
            _carView.collectButton.selected = !_carView.collectButton.selected;
        }
    } fail:^{
        _carView.collectButton.userInteractionEnabled = YES;
    }];
}





- (UIView *)addGoodsToStoreView{
    if (!_addGoodsToStoreView) {
        _addGoodsToStoreView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height-50-ShowDiff, _window_width, 50+ShowDiff)];
        _addGoodsToStoreView.backgroundColor = [UIColor whiteColor];
        UIButton *addBtn = [UIButton buttonWithType:0];
        [addBtn setTitle:@"添加到店铺" forState:0];
        [addBtn setBackgroundColor:normalColors];
        addBtn.titleLabel.font = SYS_Font(15);
        addBtn.layer.cornerRadius = 20;
        addBtn.layer.masksToBounds = YES;
        [addBtn addTarget:self action:@selector(doAddGoodsToMineStore) forControlEvents:UIControlEventTouchUpInside];
        addBtn.frame = CGRectMake(15, 4, _window_width-30, 40);
        [_addGoodsToStoreView addSubview:addBtn];

    }
    return _addGoodsToStoreView;

}
- (void)doAddGoodsToMineStore{
    [SWToolClass postNetworkWithUrl:@"shopadd" andParameter:@{@"productid":_goodsID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];

}
- (void)dealloc{
    [self releaseWMPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"DetailViewController dealloc");
}
- (UIView *)liveTipsView{
    if (!_liveTipsView) {
        CGFloat tipWidth = _window_width *0.56;
        CGFloat tipHeight = tipWidth *0.19;
        _liveTipsView = [[UIView alloc]initWithFrame:CGRectMake(15, _window_height-(tipHeight+16+ShowDiff+74), tipWidth, tipHeight+16+ShowDiff)];
        _liveTipsView.backgroundColor = [UIColor clearColor];
        UIButton *liveBtn = [UIButton buttonWithType:0];
        [liveBtn setBackgroundImage:[UIImage imageNamed:@"goods_live_tips"] forState:0];
        liveBtn.frame = CGRectMake(0, 16, tipWidth, tipHeight);
        [liveBtn addTarget:self action:@selector(doLive) forControlEvents:UIControlEventTouchUpInside];
        [_liveTipsView addSubview:liveBtn];
        UIButton *closeBtn = [UIButton buttonWithType:0];
        closeBtn.frame = CGRectMake(_liveTipsView.width-16, 0, 16, 16);
        [closeBtn setImage:[UIImage imageNamed:@"live_关闭"] forState:0];
        [closeBtn addTarget:self action:@selector(doDelateLive) forControlEvents:UIControlEventTouchUpInside];
        [_liveTipsView addSubview:closeBtn];
    }
    return _liveTipsView;
}
- (void)doLive{
    if (_liveArray.count == 1) {
        [self checkLive:_liveArray[0]];
    }else{
        SWLiveForGoodsMoreViewController *vc = [[SWLiveForGoodsMoreViewController alloc]init];
        vc.productid = _goodsID;
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}
- (void)checkLive:(NSDictionary *)roomdic{
    [SWToolClass postNetworkWithUrl:@"live/check" andParameter:@{@"stream":minstr([roomdic valueForKey:@"stream"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            SWLivePlayerViewController *player = [[SWLivePlayerViewController alloc]init];
            player.roomMap = [roomdic mutableCopy];
            [[SWMXBADelegate sharedAppDelegate] pushViewController:player animated:YES];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
}

- (void)doDelateLive{
    [_liveTipsView removeFromSuperview];
    _liveTipsView = nil;
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
