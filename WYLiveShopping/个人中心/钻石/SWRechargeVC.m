//
//  SWRechargeVC.m
//  live1v1
//
//  Created by IOS1 on 2019/4/4.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "SWRechargeVC.h"
#import "SWApplePay.h"
#import <WXApi.h>
#import "SWOrder.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "DataVerifier.h"

@interface SWRechargeVC ()<SWApplePayDelegate, WXApiDelegate>
@property (nonatomic, strong) UILabel *coinLabel;
@property (nonatomic, strong) UILabel *jifenLabel;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) NSDictionary *subDictionary;
@property (nonatomic, strong) NSArray *allArray;
@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) NSMutableArray *payTypeArray;
@property (nonatomic, strong) NSMutableArray *coinArray;
@property (nonatomic, strong) SWApplePay *applePayManager;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, copy) NSString *payTypeID;
@property (nonatomic, assign) BOOL hasCreatedUI;
@property (nonatomic, strong) NSDictionary *payTypeSelectedDictionary;
@property (nonatomic, strong) UILabel *tipsTitleLabel;
@property (nonatomic, strong) UILabel *tipsContentLabel;
@property (nonatomic, strong) NSDictionary *seleDic;
@property (nonatomic, copy) NSString *aliapp_key_ios;
@property (nonatomic, copy) NSString *aliapp_partner;
@property (nonatomic, copy) NSString *aliapp_seller_id;
@property (nonatomic, copy) NSString *wx_appid;
@property (nonatomic, copy) NSString *wx_mchid;
@property (nonatomic, copy) NSString *wx_appsecret;
@property (nonatomic, copy) NSString *wx_key;
@property (nonatomic, copy) NSString *h5Url;
@property (nonatomic, strong) NSMutableArray *payArr;

@end

@implementation SWRechargeVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"我的钻石";
    self.payTypeArray = [NSMutableArray array];
    self.coinArray = [NSMutableArray array];
    self.applePayManager = [[SWApplePay alloc] init];
    self.applePayManager.delegate = self;
    self.payArr = [NSMutableArray array];

    self.backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight, _window_width, _window_height - 64 - statusbarHeight - 50 - ShowDiff)];
    [self.view addSubview:self.backScrollView];
    self.backScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestData];
    }];

    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_width * 0.35)];
    self.headerImageView.userInteractionEnabled = YES;
    self.headerImageView.contentMode = UIViewContentModeScaleToFill;
    self.headerImageView.clipsToBounds = YES;
    self.headerImageView.image = [UIImage imageNamed:@"recharge_背景"];
    [self.backScrollView addSubview:self.headerImageView];

    UILabel *labelll = [[UILabel alloc] init];
    labelll.textColor = [UIColor whiteColor];
    labelll.font = SYS_Font(12);
    labelll.text = [NSString stringWithFormat:@"我的%@", [SWCommon name_coin]];
    [self.headerImageView addSubview:labelll];
    [labelll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headerImageView);
        make.centerY.equalTo(self.headerImageView).multipliedBy(0.65);
    }];

    self.coinLabel = [[UILabel alloc] init];
    self.coinLabel.textColor = [UIColor whiteColor];
    self.coinLabel.font = [UIFont boldSystemFontOfSize:28];
    self.coinLabel.text = @"0";
    [self.headerImageView addSubview:self.coinLabel];
    [self.coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(labelll);
        make.centerY.equalTo(self.headerImageView).multipliedBy(1.11);
    }];

    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [self.headerImageView addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.headerImageView);
        make.width.mas_equalTo(1);
        make.height.equalTo(self.headerImageView).multipliedBy(0.45);
    }];
    lineV.hidden = YES;

    self.tipsTitleLabel = [[UILabel alloc] init];
    self.tipsTitleLabel.font = SYS_Font(10);
    self.tipsTitleLabel.textColor = RGB_COLOR(@"#969696", 1);
    [self.backScrollView addSubview:self.tipsTitleLabel];
    [self.tipsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backScrollView).offset(15);
        make.top.equalTo(self.headerImageView.mas_bottom).offset(8);
    }];

    self.tipsContentLabel = [[UILabel alloc] init];
    self.tipsContentLabel.font = SYS_Font(10);
    self.tipsContentLabel.textColor = RGB_COLOR(@"#969696", 1);
    self.tipsContentLabel.numberOfLines = 0;
    [self.backScrollView addSubview:self.tipsContentLabel];
    [self.tipsContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipsTitleLabel);
        make.top.equalTo(self.tipsTitleLabel.mas_bottom).offset(5);
        make.width.equalTo(self.backScrollView).offset(-30);
    }];

    NSString *xieyiStr = @"《用户充值协议》";
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"已阅读并同意%@", xieyiStr];
    label.textColor = RGB_COLOR(@"#646464", 1);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backScrollView);
        make.top.equalTo(self.backScrollView.mas_bottom).offset(20);
    }];
    NSRange range = [label.text rangeOfString:xieyiStr];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    [str addAttribute:NSForegroundColorAttributeName value:normalColors range:range];
    label.attributedText = str;
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eula)];
    [label addGestureRecognizer:tap];

    UIButton *sureButton = [UIButton buttonWithType:0];
    [sureButton setBackgroundColor:normalColors];
    [sureButton setTitle:@"确认充值" forState:0];
    sureButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [sureButton setTitleColor:UIColor.whiteColor forState:0];
    sureButton.layer.cornerRadius = 20;
    sureButton.layer.masksToBounds = YES;
    [sureButton addTarget:self action:@selector(clickSureAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:sureButton];
    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(label.mas_top).offset(-50);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(_window_width - 80);
        make.centerX.equalTo(self.backScrollView);
    }];
}

- (void)requestData {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSNumber *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    (void)app_build;
    [SWToolClass postNetworkWithUrl:@"getinfo" andParameter:@{} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.backScrollView.mj_header endRefreshing];
        if (code == 200) {
            NSDictionary *infoDic = info;
            NSDictionary *config = infoDic[@"config"];
            self.coinLabel.text = minstr([infoDic valueForKey:@"coin"]);
            self.jifenLabel.text = minstr([infoDic valueForKey:@"score"]);
            [SWConfig saveIcon:minstr([infoDic valueForKey:@"coin"] )];
            self.tipsTitleLabel.text = minstr([infoDic valueForKey:@"tip_t"]);
            self.tipsContentLabel.text = minstr([infoDic valueForKey:@"tip_d"]);
            if (self.block) {
                self.block(minstr([infoDic valueForKey:@"coin"]));
            }
            if ([minstr(config[@"aliapp_switch"]) isEqualToString:@"1"]) {
                self.aliapp_key_ios = [config valueForKey:@"aliapp_key_ios"];
                self.aliapp_partner = [infoDic valueForKey:@"aliapp_partner"];
                self.aliapp_seller_id = [infoDic valueForKey:@"aliapp_seller_id"];
                NSDictionary *payDic = @{@"name": @"支付宝", @"thumb": @"profit_alipay", @"id": @"ali"};
                [self.payArr addObject:payDic];
            }
            if ([minstr(config[@"wx_switch"]) isEqualToString:@"1"]) {
                self.wx_appid = [config valueForKey:@"wx_appid"];
                [WXApi registerApp:self.wx_appid universalLink:WechatUniversalLink];
                NSDictionary *payDic = @{@"name": @"微信", @"thumb": @"profit_wx", @"id": @"wx"};
                [self.payArr addObject:payDic];
            }
            NSArray *listArray = [infoDic valueForKey:@"list"];
            if (listArray.count > 0) {
                self.allArray = listArray;
                if (!self.hasCreatedUI) {
                    [self creatUI];
                }
            }
        }
    } fail:^{
        [self.backScrollView.mj_header endRefreshing];
    }];
}

- (void)creatUI {
    [self.backScrollView layoutIfNeeded];
    self.hasCreatedUI = YES;
    CGFloat btnWidth;
    CGFloat btnHeight;
    CGFloat btnSH = 0.0;
    if (IS_IPHONE_5) {
        btnWidth = 90;
        btnHeight = 41;
        btnSH = 49;
    } else {
        btnWidth = 110;
        btnHeight = 50;
        btnSH = 60;
    }
    CGFloat speace = (_window_width - 30 - btnWidth * 3) / 2;
    CGFloat y = self.tipsContentLabel.bottom + 20;
    for (int i = 0; i < 2; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 100, 20)];
        label.font = SYS_Font(12);
        label.textColor = RGB_COLOR(@"#646464", 1);
        [self.backScrollView addSubview:label];
        if (i == 0) {
            if (self.payArr.count == 0) {
                self.payTypeID = @"";
                continue;
            }
            label.text = @"请选择支付方式";
            for (int j = 0; j < self.payArr.count; j++) {
                UIButton *btn = [UIButton buttonWithType:0];
                btn.frame = CGRectMake(15 + j % 3 * (btnWidth + speace), label.bottom + 10 + (j / 3) * (btnHeight + 30), btnWidth, btnHeight);
                [btn addTarget:self action:@selector(payTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [btn setBackgroundImage:[UIImage imageNamed:@""] forState:0];
                [btn setBackgroundImage:[UIImage imageNamed:@"recharge_sel"] forState:UIControlStateSelected];
                [self.backScrollView addSubview:btn];
                if (j == 0) {
                    btn.selected = YES;
                    self.payTypeID = minstr([self.payArr[j] valueForKey:@"id"]);
                }
                btn.tag = 1000 + j;
                UILabel *titleL = [[UILabel alloc] init];
                titleL.font = SYS_Font(13);
                titleL.textColor = RGB_COLOR(@"#323232", 1);
                titleL.text = minstr([self.payArr[j] valueForKey:@"name"]);
                [btn addSubview:titleL];
                [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(btn);
                    make.centerX.equalTo(btn).multipliedBy(1.21);
                }];
                UIImageView *imgV = [[UIImageView alloc] init];
                [imgV setImage:[UIImage imageNamed:minstr([self.payArr[j] valueForKey:@"thumb"])]];
                [btn addSubview:imgV];
                [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(btn);
                    make.height.width.mas_equalTo(16);
                    make.right.equalTo(titleL.mas_left).offset(-5);
                }];
                [self.payTypeArray addObject:btn];
                if (j == self.payArr.count - 1) {
                    [self.backScrollView layoutIfNeeded];
                    y = btn.bottom + 20;
                }
            }
        } else {
            label.text = @"请选择充值金额";
            for (int j = 0; j < self.allArray.count; j++) {
                UIButton *btn = [UIButton buttonWithType:0];
                btn.frame = CGRectMake(15 + j % 3 * (btnWidth + speace), label.bottom + 10 + (j / 3) * (btnSH + 30), btnWidth, btnSH);
                [btn addTarget:self action:@selector(coinBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [btn setBackgroundColor:RGB_COLOR(@"#f5f5f5", 1)];
                btn.clipsToBounds = NO;
                btn.layer.cornerRadius = 5;
                btn.layer.masksToBounds = YES;
                btn.layer.borderWidth = 1;
                btn.tag = 2000 + j;
                [self.backScrollView addSubview:btn];
                NSString *give = minstr([self.allArray[j] valueForKey:@"give"]);
                if (![give isEqual:@"0"]) {
                    CGFloat width = [[SWToolClass sharedInstance] widthOfString:[NSString stringWithFormat:@"赠送%@%@", give, [SWCommon name_coin]] andFont:SYS_Font(10) andHeight:15];
                    UIImageView *giveImgV = [[UIImageView alloc] initWithFrame:CGRectMake(btn.right - width - 5, btn.top - 7.5, width + 10, 20)];
                    giveImgV.image = [UIImage imageNamed:@"recharge_send"];
                    [self.backScrollView addSubview:giveImgV];
                    UILabel *giveLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, width, 15)];
                    giveLabel.text = [NSString stringWithFormat:@"赠送%@%@", give, [SWCommon name_coin]];
                    giveLabel.font = SYS_Font(10);
                    giveLabel.textColor = [UIColor whiteColor];
                    [giveImgV addSubview:giveLabel];
                }
                btn.layer.borderColor = [UIColor clearColor].CGColor;
                UILabel *titleL = [[UILabel alloc] init];
                titleL.font = SYS_Font(15);
                titleL.textColor = RGB_COLOR(@"#323232", 1);
                titleL.text = minstr([self.allArray[j] valueForKey:@"coin"]);
                titleL.tag = btn.tag + 3000;
                [btn addSubview:titleL];
                [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(btn).multipliedBy(0.73);
                    make.centerX.equalTo(btn);
                }];
                UIImageView *imgV = [[UIImageView alloc] init];
                imgV.image = [UIImage imageNamed:@"logFirst_钻石"];
                [btn addSubview:imgV];
                [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(titleL);
                    make.height.width.mas_equalTo(12);
                    make.left.equalTo(titleL.mas_right).offset(5);
                }];
                UILabel *moneyL = [[UILabel alloc] init];
                moneyL.font = SYS_Font(12);
                moneyL.textColor = RGB_COLOR(@"#666666", 1);
                moneyL.text = [NSString stringWithFormat:@"¥%@", minstr([self.allArray[j] valueForKey:@"money"])];
                [btn addSubview:moneyL];
                [moneyL mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(btn).multipliedBy(1.3);
                    make.centerX.equalTo(btn);
                }];
                [self.coinArray addObject:btn];
                if (j == self.allArray.count - 1) {
                    [self.backScrollView layoutIfNeeded];
                    y = btn.bottom + 20;
                }
                if (j == 0) {
                    [self coinBtnClick:btn];
                }
            }
        }
    }
    CGFloat bottomLY;
    if (y > self.backScrollView.height - 40 - ShowDiff) {
        bottomLY = y + 40;
    } else {
        bottomLY = self.backScrollView.height - 40 - ShowDiff;
    }
    self.backScrollView.contentSize = CGSizeMake(0, bottomLY);
}

- (void)payTypeBtnClick:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    for (UIButton *btn in self.payTypeArray) {
        btn.selected = (btn == sender);
    }
    self.payTypeID = minstr([self.payArr[sender.tag - 1000] valueForKey:@"id"]);

    for (int i = 0; i < self.coinArray.count; i++) {
        UIButton *btn = self.coinArray[i];
        UILabel *label = (UILabel *)[btn viewWithTag:btn.tag + 3000];
        if ([self.payTypeID isEqual:@"apple"]) {
            label.text = minstr([self.allArray[i] valueForKey:@"coin_ios"]);
        } else {
            label.text = minstr([self.allArray[i] valueForKey:@"coin"]);
        }
    }
}

- (void)clickSureAction {
    if (minstr([self.payTypeSelectedDictionary valueForKey:@"href"]).length > 6) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:minstr([self.payTypeSelectedDictionary valueForKey:@"href"])]];
    } else {
        if ([self.payTypeID isEqual:@"ali"]) {
            [self doAlipayPay];
        }
        if ([self.payTypeID isEqual:@"wx"]) {
            [self WeiXinPay];
        }
        if ([self.payTypeID isEqual:@"apple"]) {
            [self.applePayManager SWApplePay:self.seleDic];
        }
    }
}

- (void)coinBtnClick:(UIButton *)sender {
    for (UIButton *btn in self.coinArray) {
        if (btn == sender) {
            btn.layer.borderColor = normalColors.CGColor;
        } else {
            btn.layer.borderColor = RGB_COLOR(@"#f5f5f5", 1).CGColor;
        }
    }
    self.seleDic = self.allArray[sender.tag - 2000];
}

- (void)eula {
    SWWebViewController *VC = [[SWWebViewController alloc] init];
    VC.urls = self.h5Url;
    [self.navigationController pushViewController:VC animated:YES];
}

/******************   内购  ********************/
- (void)SWApplePayHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)SWApplePayShowHUD {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)SWApplePaySuccess {
    NSLog(@"苹果支付成功");
    [self requestData];
}

-(void)WeiXinPay {
    NSLog(@"微信支付");
    [MBProgressHUD showMessage:@""];
    NSLog(@"%@", minstr([SWConfig getOwnID]));
    NSDictionary *subdic = @{
        @"uid": minstr([SWConfig getOwnID]),
        @"ruleid": [self.seleDic valueForKey:@"id"],
        @"coin": [self.seleDic valueForKey:@"coin"],
        @"money": [self.seleDic valueForKey:@"money"]
    };
    [SWToolClass postNetworkWithUrl:@"getorderbywx" andParameter:subdic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [MBProgressHUD hideHUD];
            NSDictionary *dict = info;
            NSString *times = [dict objectForKey:@"timestamp"];
            PayReq *req = [[PayReq alloc] init];
            req.partnerId = [dict objectForKey:@"partnerid"];
            NSString *pid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"prepayid"]];
            if ([pid isEqual:[NSNull null]] || pid == NULL || [pid isEqual:@"null"]) {
                pid = @"123";
            }
            req.prepayId = pid;
            req.nonceStr = [dict objectForKey:@"noncestr"];
            req.timeStamp = times.intValue;
            req.package = [dict objectForKey:@"package"];
            req.sign = [dict objectForKey:@"sign"];
            [WXApi sendReq:req completion:^(BOOL success) {
                NSLog(@"wxapi调用 %d", success);
            }];
        } else {
            [MBProgressHUD hideHUD];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
}

- (void)onResp:(BaseResp *)resp {
    NSString *strMsg = [NSString stringWithFormat:@"支付结果"];
    switch (resp.errCode) {
        case WXSuccess:
            strMsg = @"支付结果：成功！";
            NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
            [self requestData];
            break;
        default:
            strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode, resp.errStr];
            NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode, resp.errStr);
            break;
    }
    (void)strMsg;
}

- (void)doAlipayPay {
    NSString *partner = self.aliapp_partner;
    NSString *seller = self.aliapp_seller_id;
    NSString *privateKey = self.aliapp_key_ios;

    if ([partner length] == 0 || [seller length] == 0 || [privateKey length] == 0) {
        [MBProgressHUD showError:@"缺少partner或者seller或者私钥"];
        return;
    }

    SWOrder *order = [[SWOrder alloc] init];
    order.partner = partner;
    order.seller = seller;

    NSDictionary *subdic = @{
        @"uid": [SWConfig getOwnID],
        @"changeid": [self.seleDic valueForKey:@"id"],
        @"coin": [self.seleDic valueForKey:@"coin"],
        @"money": [self.seleDic valueForKey:@"money"]
    };

    [SWToolClass postNetworkWithUrl:@"Charge.getAliOrder" andParameter:subdic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSString *infos = [[info firstObject] valueForKey:@"orderid"];
            order.tradeNO = infos;
            order.notifyURL = [h5url stringByAppendingString:@"/Appapi/Pay/notify_ali"];
            order.amount = [self.seleDic valueForKey:@"money"];
            order.productName = [NSString stringWithFormat:@"%@%@", [self.seleDic valueForKey:@"coin"], [SWCommon name_coin]];
            order.productDescription = @"productDescription";
            order.service = @"mobile.securitypay.pay";
            order.paymentType = @"1";
            order.inputCharset = @"utf-8";
            order.itBPay = @"30m";
            order.showUrl = @"m.alipay.com";
            NSString *appScheme = [[NSBundle mainBundle] bundleIdentifier];
            NSString *orderSpec = [order description];
            NSLog(@"orderSpec = %@", orderSpec);
            id<DataSigner> signer = CreateRSADataSigner(privateKey);
            NSString *signedString = [signer signString:orderSpec];
            NSString *orderString = nil;
            if (signedString != nil) {
                orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", orderSpec, signedString, @"RSA"];
                [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                    NSLog(@"reslut = %@", resultDic);
                    NSInteger resultStatus = [resultDic[@"resultStatus"] integerValue];
                    NSLog(@"#######%ld", (long)resultStatus);
                    NSLog(@"支付状态信息---%ld---%@", resultStatus, [resultDic valueForKey:@"memo"]);
                    if (9000 == resultStatus) {
                        [self requestData];
                    }
                }];
            }
        }
    } fail:^{
    }];
}

@end
