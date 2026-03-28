//
//  SWLookVGoodsDView.m
//  iphoneLive
//
//  Created by IOS1 on 2019/7/8.
//  Copyright © 2019 cat. All rights reserved.
//

#import "SWLookVGoodsDView.h"
#import "SWGoodsDetailsViewController.h"
@implementation SWLookVGoodsDView{
    NSDictionary *goodsDic;
    UIView *whiteView;
}

-(instancetype)initWithGoodsMsg:(NSDictionary *)dic{
    self = [super init];
    self.frame = CGRectMake(0, 0, _window_width, _window_height);
    goodsDic = dic;
    if (self) {
        [self creatUI];
    }
    return self;
}
- (void)creatUI{
    UIButton *btn = [UIButton buttonWithType:0];
    btn.frame = CGRectMake(0, 0, _window_width, _window_height-220-ShowDiff);
    [btn addTarget:self action:@selector(btnHide) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, 220+ShowDiff)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:whiteView];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:whiteView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = whiteView.bounds;
    maskLayer.path = maskPath.CGPath;
    whiteView.layer.mask = maskLayer;
    
    UIButton *coloseBtn = [UIButton buttonWithType:0];
    coloseBtn.frame = CGRectMake(_window_width-35, 0, 30, 30);
    [coloseBtn setImage:[UIImage imageNamed:@"screen_close"] forState:0];
    coloseBtn.imageEdgeInsets = UIEdgeInsetsMake(14, 10, 6, 10);
    [coloseBtn addTarget:self action:@selector(btnHide) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:coloseBtn];
    
    UIImageView *thumbImgV = [[UIImageView alloc]initWithFrame:CGRectMake(25, 30, 90, 120)];
    thumbImgV.contentMode = UIViewContentModeScaleAspectFill;
    thumbImgV.clipsToBounds = YES;
    [thumbImgV sd_setImageWithURL:[NSURL URLWithString:minstr([goodsDic valueForKey:@"image"])]];
    [whiteView addSubview:thumbImgV];
    
    UILabel *nameL = [[UILabel alloc]initWithFrame:CGRectMake(thumbImgV.right+10, 30, _window_width-(thumbImgV.right+10+10), 26)];
    nameL.font = [UIFont systemFontOfSize:15];
    nameL.text = minstr([goodsDic valueForKey:@"store_name"]);
    [whiteView addSubview:nameL];
    UILabel *contentL = [[UILabel alloc]initWithFrame:CGRectMake(nameL.left, nameL.bottom+8, nameL.width, 45)];
    contentL.textColor = RGB_COLOR(@"#646464", 1);
    contentL.font = [UIFont systemFontOfSize:12];
    contentL.numberOfLines = 3;
    contentL.text = minstr([goodsDic valueForKey:@"store_info"]);
    [whiteView addSubview:contentL];
    
    UILabel *priceL = [[UILabel alloc]init];
    priceL.font = [UIFont boldSystemFontOfSize:17];
    priceL.text = [NSString stringWithFormat:@"¥%@",minstr([goodsDic valueForKey:@"price"])];
    priceL.textColor = RGB_COLOR(@"#FB483A", 1);
    [whiteView addSubview:priceL];
    
    [priceL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(thumbImgV);
        make.left.equalTo(nameL);
    }];
    
//    UILabel *priceL2 = [[UILabel alloc]init];
//    priceL2.font = [UIFont systemFontOfSize:15];
//    priceL2.text = [NSString stringWithFormat:@"¥%@",minstr([goodsDic valueForKey:@"old_price"])];
//    priceL2.textColor = RGB_COLOR(@"#C9C9C9", 1);
//    [whiteView addSubview:priceL2];
//
//    [priceL2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(priceL);
//        make.left.equalTo(priceL.mas_right).offset(10);
//    }];
//    UIView *lineV = [[UIView alloc]init];
//    lineV.backgroundColor = RGB_COLOR(@"#C9C9C9", 1);
//    [whiteView addSubview:lineV];
//    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.centerY.equalTo(priceL2);
//        make.height.mas_equalTo(1);
//    }];

    
    UIButton *buyBtn = [UIButton buttonWithType:0];
    buyBtn.frame = CGRectMake(25, thumbImgV.bottom+15, _window_width-50, 40);
    [buyBtn setBackgroundColor:normalColors];
    [buyBtn setTitle:@"去购买" forState:0];
    buyBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [buyBtn addTarget:self action:@selector(buyBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [buyBtn setCornerRadius:20];
    [whiteView addSubview:buyBtn];
    [whiteView layoutIfNeeded];
    [UIView animateWithDuration:0.2 animations:^{
        whiteView.y = _window_height-220-ShowDiff;
    }];
}
- (void)buyBtnClick{
//    [self addShopHits];
    SWGoodsDetailsViewController *vc = [[SWGoodsDetailsViewController alloc]init];
    vc.goodsID = _videoid;
    vc.liveUid = _videoUserid;
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

//    [MBProgressHUD showMessage:@""];
//    [SWToolClass postNetworkWithUrl:@"Shop.GetShopInfo" andParameter:@{@"touid":minstr(_videoUserid)} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
//        [MBProgressHUD hideHUD];
//        if (code == 0) {
//            [self btnHide];
//            NSDictionary *infoDic = [info firstObject];
//            GoodsDetailViewController *vc = [[GoodsDetailViewController alloc]init];
//            vc.goosDic = goodsDic;
//            vc.shopDic = infoDic;
//            vc.goodsNums = minstr([infoDic valueForKey:@"nums"]);
//            vc.isFromGoods = YES;
//            [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
//        }
//    } fail:^{
//        [MBProgressHUD hideHUD];
//
//    }];

//    if ([minstr([goodsDic valueForKey:@"type"]) isEqual:@"1"]) {
//        [SWToolClass openWXMiniProgram:minstr([goodsDic valueForKey:@"href"])];
//    }else{
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:minstr([goodsDic valueForKey:@"href"])]];
//    }
}
- (void)addShopHits{
//    NSString *url = [purl stringByAppendingFormat:@"?service=Shop.UpHits"];
//    NSDictionary *dic = @{
//                          @"uid":[SWConfig getOwnID],
//                          @"token":[SWConfig getOwnToken],
//                          @"videoid":_videoid
//                          };
//    
//    [YBNetworking postWithUrl:url Dic:dic Suc:^(NSDictionary *data, NSString *code, NSString *msg) {
//        
//    } Fail:^(id fail) {
//        
//    }];
}

- (void)btnHide{
    [UIView animateWithDuration:0.2 animations:^{
        whiteView.height = _window_height;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
