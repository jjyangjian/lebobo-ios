//
//  SWAnliDetailsVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/30.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWAnliDetailsVC.h"
#import "SWRelationGoodsView.h"
#import "SWStoreHomeTbabarViewController.h"
#import "SWImageView.h"
@interface SWAnliDetailsVC ()<UIScrollViewDelegate,WKNavigationDelegate>
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UILabel *viewsLabel;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) SWImageView *showImageView;
@property (nonatomic,strong) UIScrollView *cycleScrollView;
@property (nonatomic,strong) UIScrollView *backScrollView;
@property (nonatomic,strong) UILabel *pageLabel;
@property (nonatomic,strong) UIView *bottomView;

@end

@implementation SWAnliDetailsVC
- (void)doReturn{
    if (self.showImageView) {
        [self.showImageView removeFromSuperview];
        self.showImageView = nil;
    }
    [super doReturn];
}

- (void)resetNaviView{
    [self.titleL mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.naviView);
        make.centerY.equalTo(self.returnBtn);
        make.width.mas_lessThanOrEqualTo(_window_width/2);
    }];
    UIImageView *iconImgV = [[UIImageView alloc]init];
    iconImgV.backgroundColor = normalColors;
    iconImgV.layer.cornerRadius = 12.5;
    iconImgV.layer.masksToBounds = YES;
    iconImgV.contentMode = UIViewContentModeScaleAspectFill;
    [self.naviView addSubview:iconImgV];
    [iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.titleL.mas_left).offset(-5);
        make.centerY.equalTo(self.titleL);
        make.width.height.mas_equalTo(25);
    }];
    [iconImgV sd_setImageWithURL:[NSURL URLWithString:self.model.avatar]];
    UIButton *storeBtn = [UIButton buttonWithType:0];
    [storeBtn setTitle:@" 进店" forState:0];
    [storeBtn setImage:[UIImage imageNamed:@"anli-store-icon"] forState:0];
    [storeBtn addTarget:self action:@selector(doStoreHome) forControlEvents:UIControlEventTouchUpInside];
    [storeBtn setTitleColor:RGB_COLOR(@"#FF581E", 1) forState:0];
    storeBtn.titleLabel.font = SYS_Font(11);
    storeBtn.layer.cornerRadius = 11;
    storeBtn.layer.masksToBounds = YES;
    storeBtn.layer.borderColor = RGB_COLOR(@"#FF581E", 1).CGColor;
    storeBtn.layer.borderWidth = 1;
    [self.naviView addSubview:storeBtn];
    [storeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleL.mas_right).offset(10);
        make.centerY.equalTo(self.titleL);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(60);
    }];
}

- (void)doStoreHome{
    SWStoreHomeTbabarViewController *vc = [[SWStoreHomeTbabarViewController alloc]initWithID:self.model.mer_id];
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (UIScrollView *)cycleScrollView{
    if (!_cycleScrollView) {
        _cycleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_width)];
        _cycleScrollView.delegate = self;
        _cycleScrollView.pagingEnabled = YES;
        _cycleScrollView.backgroundColor = colorf0;
        _cycleScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _cycleScrollView;
}

- (UILabel *)pageLabel{
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(_window_width-55, _window_width-35, 40, 22)];
        _pageLabel.font = SYS_Font(12);
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _pageLabel.layer.cornerRadius = 11;
        _pageLabel.layer.masksToBounds = YES;
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.text = [NSString stringWithFormat:@"1/%d",(int)self.model.image.count];
    }
    return _pageLabel;
}

- (UIScrollView *)backScrollView{
    if (!_backScrollView) {
        _backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, _window_height-self.naviView.bottom-80)];
        _backScrollView.delegate = self;
        _backScrollView.backgroundColor = [UIColor whiteColor];
        _backScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _backScrollView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.backScrollView) {
        self.cycleScrollView.scrollEnabled = NO;
    }else if (scrollView == self.cycleScrollView){
        self.backScrollView.scrollEnabled = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.backScrollView.scrollEnabled = YES;
    self.cycleScrollView.scrollEnabled = YES;
    if (scrollView == self.cycleScrollView){
        self.pageLabel.text = [NSString stringWithFormat:@"%d/%d",(int)(scrollView.contentOffset.x/_window_width)+1,(int)self.model.image.count];
    }
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height-80, _window_width, 80)];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (void)creatBottomContentView{
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 0, _window_width, 1) andColor:colorf0 andView:self.bottomView];

    UIImageView *iconImgV = [[UIImageView alloc]init];
    iconImgV.backgroundColor = normalColors;
    iconImgV.layer.cornerRadius = 16;
    iconImgV.layer.masksToBounds = YES;
    iconImgV.contentMode = UIViewContentModeScaleAspectFill;
    [self.bottomView addSubview:iconImgV];
    [iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(15);
        make.centerY.equalTo(self.bottomView);
        make.width.height.mas_equalTo(32);
    }];
    [iconImgV sd_setImageWithURL:[NSURL URLWithString:self.model.avatar]];

    UILabel *nameL = [[UILabel alloc]init];
    nameL.text = self.model.nickname;
    nameL.font = SYS_Font(14);
    nameL.textColor = color32;
    [self.bottomView addSubview:nameL];
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconImgV.mas_right).offset(8);
        make.top.equalTo(iconImgV);
        make.right.equalTo(self.bottomView).offset(-60);
    }];
    UILabel *timeL = [[UILabel alloc]init];
    timeL.text = self.model.add_time;
    timeL.font = SYS_Font(10);
    timeL.textColor = color96;
    [self.bottomView addSubview:timeL];
    [timeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameL);
        make.bottom.equalTo(iconImgV);
    }];

    self.followButton = [UIButton buttonWithType:0];
    [self.followButton setTitle:@"关注" forState:0];
    [self.followButton setTitle:@"已关注" forState:UIControlStateSelected];
    [self.followButton addTarget:self action:@selector(doFollow) forControlEvents:UIControlEventTouchUpInside];
    self.followButton.titleLabel.font = SYS_Font(10);
    self.followButton.layer.cornerRadius = 10;
    self.followButton.layer.masksToBounds = YES;
    [self.followButton setBackgroundImage:[SWToolClass getImgWithColor:normalColors] forState:0];
    [self.followButton setBackgroundImage:[SWToolClass getImgWithColor:color96] forState:UIControlStateSelected];
    [self.bottomView addSubview:self.followButton];
    self.followButton.selected = [self.model.isattent intValue];
    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-15);
        make.centerY.equalTo(self.bottomView);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(40);
    }];
}

- (void)doFollow{
    self.followButton.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.followButton.userInteractionEnabled = YES;
    });
    [SWToolClass postNetworkWithUrl:@"shopsetattent" andParameter:@{@"type":self.followButton.selected ? @"0" : @"1",@"shopid":self.model.mer_id} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.followButton.selected = !self.followButton.selected;
            self.model.isattent = [NSString stringWithFormat:@"%d",self.followButton.selected];
            [MBProgressHUD showError:self.followButton.selected ? @"关注成功" : @"取消关注成功"];
        }
    } fail:^{

    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self resetNaviView];
    self.titleL.text = self.model.nickname;
    [self.view addSubview:self.backScrollView];
    [self creatContentUI];
    [self.view addSubview:self.bottomView];
    [self creatBottomContentView];
    [self requestDetails];
}

- (void)creatContentUI{
    [self.backScrollView addSubview:self.cycleScrollView];
    for (int i = 0; i < self.model.image.count; i ++) {
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width * i, 0, _window_width, _window_width)];
        [imgV sd_setImageWithURL:[NSURL URLWithString:self.model.image[i]]];
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.clipsToBounds = YES;
        imgV.tag = 3000+i;
        imgV.userInteractionEnabled = YES;
        [self.cycleScrollView addSubview:imgV];
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doBigImage:)];
        [imgV addGestureRecognizer:tap];
    }
    self.cycleScrollView.contentSize = CGSizeMake(_window_width*self.model.image.count, 0);
    [self.backScrollView addSubview:self.pageLabel];
    UIView *lastGoodsView;
    for (int i = 0; i < self.model.goods.count; i ++) {
        SWRelationGoodsView *goodsView = [[[NSBundle mainBundle] loadNibNamed:@"SWRelationGoodsView" owner:nil options:nil] lastObject];
        goodsView.frame = CGRectMake(15, self.cycleScrollView.bottom + 15 + i * (55), _window_width-30, 50);
        goodsView.subDic = self.model.goods[i];
        [self.backScrollView addSubview:goodsView];
        if (i == self.model.goods.count-1) {
            lastGoodsView = goodsView;
        }
    }
    UILabel *contentL = [[UILabel alloc]init];
    contentL.font = SYS_Font(13);
    contentL.textColor = color64;
    contentL.numberOfLines = 0;
    contentL.attributedText = self.model.contentAttStr;
    [self.backScrollView addSubview:contentL];
    [contentL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(lastGoodsView);
        make.top.equalTo(lastGoodsView.mas_bottom).offset(15);
    }];
    self.webView = [[WKWebView alloc]init];
    self.webView.navigationDelegate = self;
    self.webView.opaque = NO;
    self.webView.multipleTouchEnabled = YES;
    self.webView.scrollView.delegate = self;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.panGestureRecognizer.enabled = NO;
    [self.backScrollView addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentL.mas_bottom);
        make.left.width.equalTo(contentL);
        make.height.mas_equalTo(10);
    }];
    UIView *contentBottomView = [[UIView alloc]init];
    [self.backScrollView addSubview:contentBottomView];
    [contentBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(lastGoodsView);
        make.top.equalTo(self.webView.mas_bottom).offset(5);
        make.height.mas_offset(55);
    }];
    self.viewsLabel = [[UILabel alloc]init];
    self.viewsLabel.text = [NSString stringWithFormat:@"%@人阅读",self.model.views];
    self.viewsLabel.font = SYS_Font(12);
    self.viewsLabel.textColor = color64;
    [contentBottomView addSubview:self.viewsLabel];
    [self.viewsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.left.equalTo(contentBottomView);
    }];
    self.likeButton = [UIButton buttonWithType:0];
    self.likeButton.titleLabel.font = SYS_Font(12);
    [self.likeButton setTitle:[NSString stringWithFormat:@" %@",self.model.likes] forState:0];
    [self.likeButton setImage:[UIImage imageNamed:@"find-zan"] forState:0];
    [self.likeButton setImage:[UIImage imageNamed:@"find-zan-sel"] forState:UIControlStateSelected];
    [self.likeButton setTitleColor:color64 forState:0];
    [self.likeButton addTarget:self action:@selector(doLike) forControlEvents:UIControlEventTouchUpInside];
    [contentBottomView addSubview:self.likeButton];
    self.likeButton.selected = [self.model.islike intValue];
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.right.equalTo(contentBottomView);
    }];
    [self.backScrollView layoutIfNeeded];
    self.backScrollView.contentSize = CGSizeMake(0, contentBottomView.bottom + 20);
}

- (void)doLike{
    self.likeButton.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.likeButton.userInteractionEnabled = YES;
    });
    [SWToolClass postNetworkWithUrl:@"kollike" andParameter:@{@"kolid":self.model.kolid,@"type":self.likeButton.selected ? @"0" : @"1"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.likeButton.selected = !self.likeButton.selected;
            self.model.likes = minstr([info valueForKey:@"likes"]);
            [self.likeButton setTitle:[NSString stringWithFormat:@" %@",self.model.likes] forState:0];
        }
    } fail:^{

    }];
}

- (void)requestDetails{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"kolinfo&kolid=%@",self.model.kolid] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.model.views = minstr([info valueForKey:@"views"]);
            self.model.likes = minstr([info valueForKey:@"likes"]);
            self.model.islike = minstr([info valueForKey:@"islike"]);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.viewsLabel.text = [NSString stringWithFormat:@"%@人阅读",self.model.views];
                [self.likeButton setTitle:[NSString stringWithFormat:@" %@",self.model.likes] forState:0];
                self.likeButton.selected = [self.model.islike intValue];
                NSString *description = minstr([info valueForKey:@"content"]);
                NSString * htmlStyle = @" <style type=\"text/css\"> *{min-width: 80% !important;max-width: 100% !important;} table{ width: 100% !important;} img{ height: auto !important;}  </style> ";
                description = [htmlStyle stringByAppendingString:description];
                NSString *aaa = @"<meta content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0\" name=\"viewport\">";
                description = [aaa stringByAppendingString:description];
                [self.webView loadHTMLString:description baseURL:nil];
            });
        }
    } Fail:^{

    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        double height = [result doubleValue];
        [webView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
        [self.backScrollView layoutIfNeeded];
        self.backScrollView.contentSize = CGSizeMake(0, webView.bottom + 80);
    }];
}

- (void)doBigImage:(UITapGestureRecognizer *)tap{
    if (self.showImageView) {
        [self.showImageView removeFromSuperview];
        self.showImageView = nil;
    }
    UIImageView *imageview = (UIImageView *)tap.view;
    NSInteger index = imageview.tag - 3000;
    self.showImageView = [[SWImageView alloc] initWithImageArray:self.model.image andIndex:index andMine:NO andBlock:^(NSArray * _Nonnull array) {
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:self.showImageView];
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
