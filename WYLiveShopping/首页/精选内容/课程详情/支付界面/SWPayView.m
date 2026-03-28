//
//  SWPayView.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/21.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWPayView.h"
#import <WXApi.h>
#import "SWOrder.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "DataVerifier.h"

@interface SWPayView ()
@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) UIImageView *wxSelectImageView;
@property (nonatomic, strong) UIImageView *aliSelectImageView;
@property (nonatomic, strong) UIImageView *coinSelectImageView;
@property (nonatomic, strong) NSArray *payListArray;
@property (nonatomic, strong) NSDictionary *selectedDictionary;
@property (nonatomic, strong) UILabel *moneyLabel;

@end

@implementation SWPayView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)doHideSelf {
    [UIView animateWithDuration:0.3 animations:^{
        if (self.whiteView) {
            self.whiteView.y = _window_height;
        }
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.15];
        self.frame = CGRectMake(0, 0, _window_width, _window_height);
        [self requestData];
    }
    return self;
}

- (void)requestData {
    [SWToolClass postNetworkWithUrl:@"Cart.GetPayList" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            self.payListArray = info;
            if (self.payListArray.count == 0) {
                [self doHideSelf];
                [MBProgressHUD showError:@"支付未开启"];
            } else {
                [self creatUI];
            }
        } else {
            [self doHideSelf];
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [self doHideSelf];
        [MBProgressHUD showError:@"网络错误"];
    }];
}

- (void)creatUI {
    UIButton *maskButton = [UIButton buttonWithType:0];
    maskButton.frame = CGRectMake(0, 0, _window_width, _window_height - ShowDiff - 118 - self.payListArray.count * 61);
    [maskButton addTarget:self action:@selector(doHideSelf) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:maskButton];

    self.whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, _window_height, _window_width, 168 + self.payListArray.count * 61 + ShowDiff)];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.whiteView];
    self.whiteView.layer.mask = [[SWToolClass sharedInstance] setViewLeftTop:10 andRightTop:10 andView:self.whiteView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"收银台";
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textColor = color32;
    [self.whiteView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.whiteView);
        make.top.equalTo(self.whiteView).offset(2.5);
        make.height.mas_offset(40);
    }];

    UIButton *closeButton = [UIButton buttonWithType:0];
    [closeButton addTarget:self action:@selector(doHideSelf) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImage:[UIImage imageNamed:@"screen_close"] forState:0];
    closeButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [self.whiteView addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLabel).offset(-2);
        make.right.equalTo(self.whiteView).offset(-8);
        make.height.width.mas_offset(30);
    }];

    UIView *lineView1 = [[UIView alloc] init];
    lineView1.backgroundColor = colorf0;
    [self.whiteView addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom);
        make.left.width.equalTo(self.whiteView);
        make.height.mas_equalTo(1);
    }];

    self.moneyLabel = [[UILabel alloc] init];
    self.moneyLabel.font = [UIFont boldSystemFontOfSize:20];
    self.moneyLabel.textColor = color32;
    self.moneyLabel.text = @"0";
    [self.whiteView addSubview:self.moneyLabel];
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.whiteView);
        make.top.equalTo(lineView1.mas_bottom);
        make.height.mas_offset(50);
    }];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥ %@", self.moneyStr]];
    [attStr addAttribute:NSFontAttributeName value:SYS_Font(12) range:NSMakeRange(0, 1)];
    self.moneyLabel.attributedText = attStr;

    MASViewAttribute *masTop = self.moneyLabel.mas_bottom;

    for (int i = 0; i < self.payListArray.count; i++) {
        UIButton *itemButton = [UIButton buttonWithType:0];
        [itemButton addTarget:self action:@selector(payItemButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        itemButton.tag = 1000 + i;
        [self.whiteView addSubview:itemButton];
        [itemButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self.whiteView);
            make.height.mas_equalTo(60);
            if (i == 0) {
                make.top.equalTo(masTop).offset(15);
            } else {
                make.top.equalTo(masTop).offset(1);
            }
        }];
        masTop = itemButton.mas_bottom;

        NSDictionary *dic = self.payListArray[i];
        int payID = [minstr([dic valueForKey:@"id"]) intValue];

        UIImageView *typeImageView = [[UIImageView alloc] init];
        [typeImageView sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"thumb"])]];
        [itemButton addSubview:typeImageView];
        [typeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(itemButton);
            make.left.equalTo(itemButton).offset(30);
            make.width.height.mas_equalTo(16);
        }];

        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = minstr([dic valueForKey:@"name"]);
        nameLabel.font = SYS_Font(14);
        nameLabel.textColor = color32;
        [itemButton addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(typeImageView.mas_right).offset(10);
            make.centerY.equalTo(itemButton);
        }];

        if (payID == 5) {
            UILabel *coinLabel = [[UILabel alloc] init];
            coinLabel.text = [NSString stringWithFormat:@"（¥%@）", minstr([dic valueForKey:@"coin"])];
            coinLabel.font = SYS_Font(14);
            coinLabel.textColor = RGB_COLOR(@"#b3b3b3", 1);
            [itemButton addSubview:coinLabel];
            [coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(nameLabel.mas_right).offset(2);
                make.centerY.equalTo(itemButton);
            }];
        }

        UIImageView *selectImageView = [[UIImageView alloc] init];
        selectImageView.hidden = YES;
        selectImageView.contentMode = UIViewContentModeScaleAspectFit;
        selectImageView.image = [UIImage imageNamed:@"支付选中"];
        [itemButton addSubview:selectImageView];
        [selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(itemButton);
            make.right.equalTo(itemButton).offset(-30);
            make.width.height.mas_equalTo(20);
        }];

        if (i != self.payListArray.count - 1) {
            UIView *lineView2 = [[UIView alloc] init];
            lineView2.backgroundColor = colorf0;
            [self.whiteView addSubview:lineView2];
            [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(itemButton.mas_bottom);
                make.centerX.equalTo(self.whiteView);
                make.width.equalTo(self.whiteView).offset(-60);
                make.height.mas_equalTo(1);
            }];
        }

        if (payID == 2) {
            self.wxSelectImageView = selectImageView;
        } else if (payID == 1) {
            self.aliSelectImageView = selectImageView;
        } else {
            self.coinSelectImageView = selectImageView;
        }
    }

    UIView *lineView3 = [[UIView alloc] init];
    lineView3.backgroundColor = colorf0;
    [self.whiteView addSubview:lineView3];
    [lineView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(masTop).offset(9);
        make.left.width.equalTo(self.whiteView);
        make.height.mas_equalTo(1);
    }];

    UIButton *payButton = [UIButton buttonWithType:0];
    [payButton addTarget:self action:@selector(doPay:) forControlEvents:UIControlEventTouchUpInside];
    [payButton setTitle:@"立即支付" forState:0];
    [payButton setTitleColor:normalColors forState:0];
    payButton.titleLabel.font = SYS_Font(15);
    [self.whiteView addSubview:payButton];
    [payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self.whiteView);
        make.height.mas_equalTo(50);
        make.top.equalTo(lineView3.mas_bottom);
    }];

    [self show];
}

- (void)payItemButtonClick:(UIButton *)sender {
    self.selectedDictionary = self.payListArray[sender.tag - 1000];
    int payID = [minstr([self.selectedDictionary valueForKey:@"id"]) intValue];
    if (payID == 2) {
        self.wxSelectImageView.hidden = NO;
        self.aliSelectImageView.hidden = YES;
        self.coinSelectImageView.hidden = YES;
    } else if (payID == 1) {
        self.wxSelectImageView.hidden = YES;
        self.aliSelectImageView.hidden = NO;
        self.coinSelectImageView.hidden = YES;
    } else {
        self.wxSelectImageView.hidden = YES;
        self.aliSelectImageView.hidden = YES;
        self.coinSelectImageView.hidden = NO;
    }
}

- (void)doPay:(UIButton *)sender {
    if (!self.selectedDictionary) {
        [MBProgressHUD showError:@"请选择支付方式"];
        return;
    }
    sender.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.userInteractionEnabled = YES;
    });

    NSMutableDictionary *parameterDic;
    NSString *url;
    if ([self.method isEqual:@"vip"]) {
        parameterDic = [self.vipMessage mutableCopy];
        [parameterDic setObject:minstr([self.selectedDictionary valueForKey:@"id"]) forKey:@"payid"];
        url = @"Vip.Buy";
    } else if ([self.method isEqual:@"order"]) {
        parameterDic = @{
            @"payid": minstr([self.selectedDictionary valueForKey:@"id"]),
            @"orderno": self.orderNum,
        }.mutableCopy;
        url = @"Orders.Pay";
    } else {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.goodsArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        parameterDic = @{
            @"goods": jsonStr,
            @"payid": minstr([self.selectedDictionary valueForKey:@"id"]),
            @"addrid": self.addrid,
            @"method": self.method,
            @"deduct_integral": self.deduct_integral,
            @"couponid": self.couponid
        }.mutableCopy;
        [parameterDic addEntriesFromDictionary:self.pinkMessage];
        url = @"Cart.Buy";
    }

    [SWToolClass postNetworkWithUrl:url andParameter:parameterDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            if ([minstr([parameterDic valueForKey:@"payid"]) isEqual:@"1"]) {
                NSString *infos = [infoDic valueForKey:@"orderid"];
                NSDictionary *aliDic = [infoDic valueForKey:@"ali"];
                NSString *partner = minstr([aliDic valueForKey:@"partner"]);
                NSString *seller = minstr([aliDic valueForKey:@"seller_id"]);
                NSString *privateKey = minstr([aliDic valueForKey:@"key"]);
                if ([partner length] == 0 || [seller length] == 0 || [privateKey length] == 0) {
                    [MBProgressHUD showError:@"缺少partner或者seller或者私钥"];
                    return;
                }
                SWOrder *order = [[SWOrder alloc] init];
                order.partner = partner;
                order.seller = seller;
                order.tradeNO = infos;
                if ([self.method isEqual:@"vip"]) {
                    order.notifyURL = [h5url stringByAppendingString:@"/appapi/vippay/notify_ali"];
                } else {
                    order.notifyURL = [h5url stringByAppendingString:@"/appapi/cartpay/notify_ali"];
                }
                order.amount = minstr([infoDic valueForKey:@"money"]);
                order.productName = [NSString stringWithFormat:@"¥%@", [infoDic valueForKey:@"money"]];
                order.productDescription = @"productDescription";
                order.service = @"mobile.securitypay.pay";
                order.paymentType = @"1";
                order.inputCharset = @"utf-8";
                order.itBPay = @"30m";
                order.showUrl = @"m.alipay.com";
                NSString *appScheme = @"wanyueEducation";
                NSString *orderSpec = [order description];
                NSLog(@"orderSpec = %@", orderSpec);
                id<DataSigner> signer = CreateRSADataSigner(privateKey);
                NSString *signedString = [signer signString:orderSpec];
                NSString *orderString = nil;
                if (signedString != nil) {
                    orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", orderSpec, signedString, @"RSA"];
                    NSArray *array = [[UIApplication sharedApplication] windows];
                    UIWindow *win = [array objectAtIndex:0];
                    NSURL *myURL_APP_A = [NSURL URLWithString:@"alipay:"];
                    if (![[UIApplication sharedApplication] canOpenURL:myURL_APP_A]) {
                        [win setHidden:NO];
                    }
                    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [win setHidden:YES];
                        });
                        [[NSNotificationCenter defaultCenter] postNotificationName:WYAlipayRsultttt object:resultDic];
                        NSLog(@"reslut = %@", resultDic);
                        NSInteger resultStatus = [resultDic[@"resultStatus"] integerValue];
                        NSLog(@"#######%ld", (long)resultStatus);
                        NSLog(@"支付状态信息---%ld---%@", resultStatus, [resultDic valueForKey:@"memo"]);
                    }];
                }
            } else if ([minstr([parameterDic valueForKey:@"payid"]) isEqual:@"2"]) {
                NSDictionary *wxDic = [infoDic valueForKey:@"wx"];
                [WXApi registerApp:minstr([wxDic valueForKey:@"appid"]) universalLink:WechatUniversalLink];
                NSString *times = [wxDic objectForKey:@"timestamp"];
                PayReq *req = [[PayReq alloc] init];
                req.partnerId = [wxDic objectForKey:@"partnerid"];
                NSString *pid = [NSString stringWithFormat:@"%@", [wxDic objectForKey:@"prepayid"]];
                if ([pid isEqual:[NSNull null]] || pid == NULL || [pid isEqual:@"null"]) {
                    pid = @"123";
                }
                req.prepayId = pid;
                req.nonceStr = [wxDic objectForKey:@"noncestr"];
                req.timeStamp = times.intValue;
                req.package = [wxDic objectForKey:@"package"];
                req.sign = [wxDic objectForKey:@"sign"];
                [WXApi sendReq:req completion:nil];
            } else {
                [MBProgressHUD hideHUD];
                NSDictionary *coindic = @{@"wx": @"-99"};
                [[NSNotificationCenter defaultCenter] postNotificationName:WYWXApiPaySuccess object:nil userInfo:coindic];
            }
        } else if (code == 970) {
            [MBProgressHUD showError:msg];
            [[SWMXBADelegate sharedAppDelegate] popViewController:YES];
        } else if (code == 900) {
            [MBProgressHUD showError:msg];
            if (self.block) {
                self.block();
            }
        } else {
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
}

- (void)show {
    self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.whiteView.y = _window_height - ShowDiff - 168 - self.payListArray.count * 61;
    }];
}

- (void)setMoneyStr:(NSString *)moneyStr {
    _moneyStr = moneyStr;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥ %@", self.moneyStr]];
    [attStr addAttribute:NSFontAttributeName value:SYS_Font(12) range:NSMakeRange(0, 1)];
    self.moneyLabel.attributedText = attStr;
}

@end
