//
//  WYAnliDetailsViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/30.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYAnliDetailsViewController.h"
#import "relationGoodsView.h"
#import "WYStoreHomeTbabarViewController.h"
#import "WYImageView.h"
@interface WYAnliDetailsViewController ()<UIScrollViewDelegate,WKNavigationDelegate>{
    UIButton *likeButton;
    UILabel *viewsLabel;
    WKWebView *webView;
    UIButton *followBtn;
    WYImageView *wyShowImgView;
}
@property (nonatomic,strong) UIScrollView *cycleScrollView;
@property (nonatomic,strong) UIScrollView *backScrollView;
@property (nonatomic,strong) UILabel *pageLabel;
@property (nonatomic,strong) UIView *bottomView;

@end

@implementation WYAnliDetailsViewController
-(void)doReturn{
    if (wyShowImgView) {
        [wyShowImgView removeFromSuperview];
        wyShowImgView = nil;
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
    [iconImgV sd_setImageWithURL:[NSURL URLWithString:_model.avatar]];
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
    WYStoreHomeTbabarViewController *vc = [[WYStoreHomeTbabarViewController alloc]initWithID:_model.mer_id];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

}
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
- (UILabel *)pageLabel{
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(_window_width-55, _window_width-35, 40, 22)];
        _pageLabel.font = SYS_Font(12);
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _pageLabel.layer.cornerRadius = 11;
        _pageLabel.layer.masksToBounds = YES;
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.text = [NSString stringWithFormat:@"1/%d",_model.image.count];
    }
    return _pageLabel;
}
-(UIScrollView *)backScrollView{
    if (!_backScrollView) {
        _backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, _window_height-self.naviView.bottom-80)];
        _backScrollView.delegate = self;
//        _backScrollView.pagingEnabled = YES;
        _backScrollView.backgroundColor = [UIColor whiteColor];
        _backScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _backScrollView;
}
#pragma mark -- UIScrollView代理 管理naviView的透明度
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _backScrollView) {
        _cycleScrollView.scrollEnabled = NO;

    }else if (scrollView == _cycleScrollView){
        _backScrollView.scrollEnabled = NO;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _backScrollView.scrollEnabled = YES;
    _cycleScrollView.scrollEnabled = YES;
    if (scrollView == _cycleScrollView){
        _pageLabel.text = [NSString stringWithFormat:@"%d/%d",(int)(scrollView.contentOffset.x/_window_width)+1,(int)_model.image.count];;
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
    [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 0, _window_width, 1) andColor:colorf0 andView:_bottomView];
    
    UIImageView *iconImgV = [[UIImageView alloc]init];
    iconImgV.backgroundColor = normalColors;
    iconImgV.layer.cornerRadius = 16;
    iconImgV.layer.masksToBounds = YES;
    iconImgV.contentMode = UIViewContentModeScaleAspectFill;
    [_bottomView addSubview:iconImgV];
    [iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomView).offset(15);
        make.centerY.equalTo(_bottomView);
        make.width.height.mas_equalTo(32);
    }];
    [iconImgV sd_setImageWithURL:[NSURL URLWithString:_model.avatar]];
    
    UILabel *nameL = [[UILabel alloc]init];
    nameL.text = _model.nickname;
    nameL.font = SYS_Font(14);
    nameL.textColor = color32;
    [_bottomView addSubview:nameL];
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconImgV.mas_right).offset(8);
        make.top.equalTo(iconImgV);
        make.right.equalTo(_bottomView).offset(-60);
    }];
    UILabel *timeL = [[UILabel alloc]init];
    timeL.text = _model.add_time;
    timeL.font = SYS_Font(10);
    timeL.textColor = color96;
    [_bottomView addSubview:timeL];
    [timeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameL);
        make.bottom.equalTo(iconImgV);
    }];

    followBtn = [UIButton buttonWithType:0];
    [followBtn setTitle:@"关注" forState:0];
    [followBtn setTitle:@"已关注" forState:UIControlStateSelected];
    [followBtn addTarget:self action:@selector(doFollow) forControlEvents:UIControlEventTouchUpInside];
    followBtn.titleLabel.font = SYS_Font(10);
    followBtn.layer.cornerRadius = 10;
    followBtn.layer.masksToBounds = YES;
    [followBtn setBackgroundImage:[WYToolClass getImgWithColor:normalColors] forState:0];
    [followBtn setBackgroundImage:[WYToolClass getImgWithColor:color96] forState:UIControlStateSelected];
    [_bottomView addSubview:followBtn];
    followBtn.selected = [_model.isattent intValue];
    [followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_bottomView).offset(-15);
        make.centerY.equalTo(_bottomView);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(40);
    }];

}
-(void)doFollow{
    followBtn.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        followBtn.userInteractionEnabled = YES;
    });
    [WYToolClass postNetworkWithUrl:@"shopsetattent" andParameter:@{@"type":followBtn.selected ? @"0" : @"1",@"shopid":_model.mer_id} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            
            followBtn.selected = !followBtn.selected;
            _model.isattent = [NSString stringWithFormat:@"%d",followBtn.selected];
            [MBProgressHUD showError:followBtn.selected ? @"关注成功" : @"取消关注成功"];
        }
    } fail:^{
        
    }];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self resetNaviView];
    self.titleL.text = _model.nickname;
    [self.view addSubview:self.backScrollView];
    [self creatContentUI];
    [self.view addSubview:self.bottomView];
    [self creatBottomContentView];
    [self requestDetails];
}
- (void)creatContentUI{
    [_backScrollView addSubview:self.cycleScrollView];
    for (int i = 0; i < _model.image.count; i ++) {
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width * i, 0, _window_width, _window_width)];
        [imgV sd_setImageWithURL:[NSURL URLWithString:_model.image[i]]];
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.clipsToBounds = YES;
        imgV.tag = 3000+i;
        imgV.userInteractionEnabled = YES;
        [_cycleScrollView addSubview:imgV];
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doBigImage:)];
        [imgV addGestureRecognizer:tap];

    }
    _cycleScrollView.contentSize = CGSizeMake(_window_width*_model.image.count, 0);
    [_backScrollView addSubview:self.pageLabel];
    UIView *lastGoodsView;
    for (int i = 0; i < _model.goods.count; i ++) {
        relationGoodsView *goodsView = [[[NSBundle mainBundle] loadNibNamed:@"relationGoodsView" owner:nil options:nil] lastObject];
        goodsView.frame = CGRectMake(15, _cycleScrollView.bottom + 15 + i * (55), _window_width-30, 50);
        goodsView.subDic = _model.goods[i];
        [_backScrollView addSubview:goodsView];
        if (i == _model.goods.count-1) {
            lastGoodsView = goodsView;
        }
    }
    UILabel *contentL = [[UILabel alloc]init];
    contentL.font = SYS_Font(13);
    contentL.textColor = color64;
    contentL.numberOfLines = 0;
    contentL.attributedText = _model.contentAttStr;
    [_backScrollView addSubview:contentL];
    [contentL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(lastGoodsView);
        make.top.equalTo(lastGoodsView.mas_bottom).offset(15);
    }];
    webView = [[WKWebView alloc]init];
    webView.navigationDelegate = self;
    webView.opaque = NO;
    webView.multipleTouchEnabled = YES;
    webView.scrollView.delegate = self;
    webView.scrollView.bounces = NO;
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.scrollView.scrollEnabled = NO;
    webView.scrollView.panGestureRecognizer.enabled = NO;
    [_backScrollView addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentL.mas_bottom);
        make.left.width.equalTo(contentL);
        make.height.mas_equalTo(10);
    }];
    UIView *contentBottomView = [[UIView alloc]init];
    [_backScrollView addSubview:contentBottomView];
    [contentBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(lastGoodsView);
        make.top.equalTo(webView.mas_bottom).offset(5);
        make.height.mas_offset(55);
    }];
    viewsLabel = [[UILabel alloc]init];
    viewsLabel.text = [NSString stringWithFormat:@"%@人阅读",_model.views];
    viewsLabel.font = SYS_Font(12);
    viewsLabel.textColor = color64;
    [contentBottomView addSubview:viewsLabel];
    [viewsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.left.equalTo(contentBottomView);
    }];
    likeButton = [UIButton buttonWithType:0];
    likeButton.titleLabel.font = SYS_Font(12);
    [likeButton setTitle:[NSString stringWithFormat:@" %@",_model.likes] forState:0];
    [likeButton setImage:[UIImage imageNamed:@"find-zan"] forState:0];
    [likeButton setImage:[UIImage imageNamed:@"find-zan-sel"] forState:UIControlStateSelected];
    [likeButton setTitleColor:color64 forState:0];
    [likeButton addTarget:self action:@selector(doLike) forControlEvents:UIControlEventTouchUpInside];
    [contentBottomView addSubview:likeButton];
    likeButton.selected = [_model.islike intValue];
    [likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.right.equalTo(contentBottomView);
    }];
    [_backScrollView layoutIfNeeded];
    _backScrollView.contentSize = CGSizeMake(0, contentBottomView.bottom + 20);
    
}
- (void)doLike{
    likeButton.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        likeButton.userInteractionEnabled = YES;
    });
    [WYToolClass postNetworkWithUrl:@"kollike" andParameter:@{@"kolid":_model.kolid,@"type":likeButton.selected ? @"0" : @"1"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            
            likeButton.selected = !likeButton.selected;
            _model.likes = minstr([info valueForKey:@"likes"]);
            [likeButton setTitle:[NSString stringWithFormat:@" %@",_model.likes] forState:0];

        }
    } fail:^{
        
    }];

}
- (void)requestDetails{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"kolinfo&kolid=%@",_model.kolid] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            _model.views = minstr([info valueForKey:@"views"]);
            _model.likes = minstr([info valueForKey:@"likes"]);
            _model.islike = minstr([info valueForKey:@"islike"]);
            dispatch_async(dispatch_get_main_queue(), ^{
                viewsLabel.text = [NSString stringWithFormat:@"%@人阅读",_model.views];
                [likeButton setTitle:[NSString stringWithFormat:@" %@",_model.likes] forState:0];
                likeButton.selected = [_model.islike intValue];
                NSString *description = minstr([info valueForKey:@"content"]);
                NSString * htmlStyle = @" <style type=\"text/css\"> *{min-width: 80% !important;max-width: 100% !important;} table{ width: 100% !important;} img{ height: auto !important;}  </style> ";
                description = [htmlStyle stringByAppendingString:description];
                NSString *aaa = @"<meta content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0\" name=\"viewport\">";
                description = [aaa stringByAppendingString:description];
                [webView loadHTMLString:description baseURL:nil];

            });

        }
    } Fail:^{
        
    }];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//        _webView.frame = CGRectMake(0, _goodListView.bottom, _window_width, [result doubleValue]);//将WKWebView的高度设置为内容高度
        double height = [result doubleValue];
        [webView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
        //刷新制定位置Cell
        [_backScrollView layoutIfNeeded];
        _backScrollView.contentSize = CGSizeMake(0, webView.bottom + 80);
    }];
    

}
- (void)doBigImage:(UITapGestureRecognizer *)tap{
    if (wyShowImgView) {
        [wyShowImgView removeFromSuperview];
        wyShowImgView = nil;
    }
    UIImageView *imageview = (UIImageView *)tap.view;
    NSInteger index = imageview.tag - 3000;
    wyShowImgView = [[WYImageView alloc] initWithImageArray:_model.image andIndex:index andMine:NO andBlock:^(NSArray * _Nonnull array) {
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:wyShowImgView];

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
