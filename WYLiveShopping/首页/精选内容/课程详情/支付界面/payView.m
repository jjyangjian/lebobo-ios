//
//  payView.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/21.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "payView.h"
#import <WXApi.h>
//支付宝
#import "Order.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "DataVerifier.h"
@interface payView (){
    UIView *whiteView;
    UIImageView *wxSelectImgV;
    UIImageView *aliSelectImgV;
    UIImageView *coinSelectImgV;
    NSArray *payListArray;
    NSDictionary *selectDic;
    UILabel *moneyL;
}

@end
@implementation payView
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)doHideSelf{
    [UIView animateWithDuration:0.3 animations:^{
        if (whiteView) {
            whiteView.y = _window_height;
        }
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}
- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor  = [[UIColor blackColor] colorWithAlphaComponent:0.15];
        self.frame = CGRectMake(0, 0, _window_width, _window_height);
        [self requestData];
    }
    return self;
}
- (void)requestData{
    [WYToolClass postNetworkWithUrl:@"Cart.GetPayList" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            payListArray = info;
            if (payListArray.count == 0) {
                [self doHideSelf];
                [MBProgressHUD showError:@"支付未开启"];
            }else{
//                selectDic = [payListArray firstObject];
                [self creatUI];

            }
        }else{
            [self doHideSelf];
            [MBProgressHUD showError:msg];

        }
    } fail:^{
        [self doHideSelf];
        [MBProgressHUD showError:@"网络错误"];
    }];
}
- (void)creatUI{
    UIButton *btn = [UIButton buttonWithType:0];
    btn.frame = CGRectMake(0, 0, _window_width, _window_height-ShowDiff-118 - payListArray.count*61);
    [btn addTarget:self action:@selector(doHideSelf) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, 168 + payListArray.count*61+ShowDiff)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:whiteView];
    whiteView.layer.mask = [[WYToolClass sharedInstance] setViewLeftTop:10 andRightTop:10 andView:whiteView];
    UILabel *titleL = [[UILabel alloc]init];
    titleL.text = @"收银台";
    titleL.font = [UIFont boldSystemFontOfSize:16];
    titleL.textColor = color32;
    [whiteView addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(whiteView);
        make.top.equalTo(whiteView).offset(2.5);
        make.height.mas_offset(40);
    }];
    UIButton *closeBtn = [UIButton buttonWithType:0];
    [closeBtn addTarget:self action:@selector(doHideSelf) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setImage:[UIImage imageNamed:@"screen_close"] forState:0];
    closeBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [whiteView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleL).offset(-2);
        make.right.equalTo(whiteView).offset(-8);
        make.height.width.mas_offset(30);
    }];

    UIView *lineV1 = [[UIView alloc]init];
    lineV1.backgroundColor = colorf0;
    [whiteView addSubview:lineV1];
    [lineV1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleL.mas_bottom);
        make.left.width.equalTo(whiteView);
        make.height.mas_equalTo(1);
    }];
    moneyL = [[UILabel alloc]init];
    moneyL.font = [UIFont boldSystemFontOfSize:20];
    moneyL.textColor = color32;
    moneyL.text = @"0";
    [whiteView addSubview:moneyL];
    [moneyL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(whiteView);
        make.top.equalTo(lineV1.mas_bottom);
        make.height.mas_offset(50);
    }];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"¥ %@",_moneyStr]];
    [attStr addAttribute:NSFontAttributeName value:SYS_Font(12) range:NSMakeRange(0, 1)];
    moneyL.attributedText = attStr;

    MASViewAttribute *masTop = moneyL.mas_bottom;
    
    for (int i = 0; i < payListArray.count; i ++) {
        UIButton *btnn = [UIButton buttonWithType:0];
        [btnn addTarget:self action:@selector(payItemButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        btnn.tag = 1000 + i;
        [whiteView addSubview:btnn];
        [btnn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(whiteView);
            make.height.mas_equalTo(60);
            if (i == 0) {
                make.top.equalTo(masTop).offset(15);
            }else{
                make.top.equalTo(masTop).offset(1);
            }
        }];
        masTop = btnn.mas_bottom;
        NSDictionary *dic = payListArray[i];
        int payID = [minstr([dic valueForKey:@"id"]) intValue];
        UIImageView *typeImgV = [[UIImageView alloc]init];
        [typeImgV sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"thumb"])]];
        [btnn addSubview:typeImgV];
        [typeImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(btnn);
            make.left.equalTo(btnn).offset(30);
            make.width.height.mas_equalTo(16);
        }];
        UILabel *nameL = [[UILabel alloc]init];
        nameL.text = minstr([dic valueForKey:@"name"]);
        nameL.font = SYS_Font(14);
        nameL.textColor = color32;
        [btnn addSubview:nameL];
        [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(typeImgV.mas_right).offset(10);
            make.centerY.equalTo(btnn);
        }];

        if (payID == 5) {
            UILabel *coinL= [[UILabel alloc]init];
            coinL.text = [NSString stringWithFormat:@"（¥%@）",minstr([dic valueForKey:@"coin"])];
            coinL.font = SYS_Font(14);
            coinL.textColor = RGB_COLOR(@"#b3b3b3", 1);
            [btnn addSubview:coinL];
            [coinL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(nameL.mas_right).offset(2);
                make.centerY.equalTo(btnn);
            }];

        }
        UIImageView *selectImgV = [[UIImageView alloc]init];
        selectImgV.hidden = YES;
        selectImgV.contentMode = UIViewContentModeScaleAspectFit;
        selectImgV.image  = [UIImage imageNamed:@"支付选中"];
        [btnn addSubview:selectImgV];
        [selectImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(btnn);
            make.right.equalTo(btnn).offset(-30);
            make.width.height.mas_equalTo(20);
        }];
        if (i != payListArray.count - 1) {
            UIView *lineV2 = [[UIView alloc]init];
            lineV2.backgroundColor = colorf0;
            [whiteView addSubview:lineV2];
            [lineV2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(btnn.mas_bottom);
                make.centerX.equalTo(whiteView);
                make.width.equalTo(whiteView).offset(-60);
                make.height.mas_equalTo(1);
            }];
        }
//        if (i == 0) {
//            selectImgV.hidden = NO;
//        }
        if (payID == 2) {
            wxSelectImgV = selectImgV;
        }else if (payID == 1) {
            aliSelectImgV = selectImgV;
        }else{
            coinSelectImgV = selectImgV;
        }
    }
    UIView *lineV3 = [[UIView alloc]init];
    lineV3.backgroundColor = colorf0;
    [whiteView addSubview:lineV3];
    [lineV3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(masTop).offset(9);
        make.left.width.equalTo(whiteView);
        make.height.mas_equalTo(1);
    }];

    UIButton *payButton = [UIButton buttonWithType:0];
    [payButton addTarget:self action:@selector(doPay:) forControlEvents:UIControlEventTouchUpInside];
    [payButton setTitle:@"立即支付" forState:0];
    [payButton setTitleColor:normalColors forState:0];
    payButton.titleLabel.font = SYS_Font(15);
    [whiteView addSubview:payButton];
    [payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(whiteView);
        make.height.mas_equalTo(50);
        make.top.equalTo(lineV3.mas_bottom);
    }];
    [self show];
}
- (void)payItemButtonClick:(UIButton *)sender{
    selectDic = payListArray[sender.tag - 1000];
    int payID = [minstr([selectDic valueForKey:@"id"]) intValue];
    if (payID == 2) {
        wxSelectImgV.hidden = NO;
        aliSelectImgV.hidden = YES;
        coinSelectImgV.hidden = YES;

    }else if (payID == 1) {
        wxSelectImgV.hidden = YES;
        aliSelectImgV.hidden = NO;
        coinSelectImgV.hidden = YES;
    }else{
        wxSelectImgV.hidden = YES;
        aliSelectImgV.hidden = YES;
        coinSelectImgV.hidden = NO;
    }

//    if (sender.tag == 1000) {
//        //wx
//        wxSelectImgV.hidden = NO;
//        aliSelectImgV.hidden = YES;
//    }else{
//        //支付宝
//        aliSelectImgV.hidden = NO;
//        wxSelectImgV.hidden = YES;
//    }
}
- (void)doPay:(UIButton *)sender{
    if (!selectDic) {
        [MBProgressHUD showError:@"请选择支付方式"];
        return;
    }
    sender.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.userInteractionEnabled = YES;
    });
    NSMutableDictionary *parameterDic;
    NSString *url;
    if ([_method isEqual:@"vip"]) {
        parameterDic = [_vipMessage mutableCopy];
        [parameterDic setObject:minstr([selectDic valueForKey:@"id"]) forKey:@"payid"];
        url = @"Vip.Buy";
    }else if ([_method isEqual:@"order"]) {
        parameterDic = @{
            @"payid":minstr([selectDic valueForKey:@"id"]),
            @"orderno":_orderNum,
        }.mutableCopy;
        url = @"Orders.Pay";

    }
    else{
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_goodsArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];

        parameterDic = @{
                              @"goods":jsonStr,
                              @"payid":minstr([selectDic valueForKey:@"id"]),
                              @"addrid":_addrid,
                              @"method":_method,
                              @"deduct_integral":_deduct_integral,
                              @"couponid":_couponid
        }.mutableCopy;
        [parameterDic addEntriesFromDictionary:_pinkMessage];
        url = @"Cart.Buy";
    }
    [WYToolClass postNetworkWithUrl:url andParameter:parameterDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            if ([minstr([parameterDic valueForKey:@"payid"]) isEqual:@"1"]){
                NSString *infos = [infoDic valueForKey:@"orderid"];
                NSDictionary *aliDic = [infoDic valueForKey:@"ali"];
                NSString *partner = minstr([aliDic valueForKey:@"partner"]);
                NSString *seller =  minstr([aliDic valueForKey:@"seller_id"]);
                NSString *privateKey = minstr([aliDic valueForKey:@"key"]);
                
                //partner和seller获取失败,提示
                if ([partner length] == 0 ||
                    [seller length] == 0 ||
                    [privateKey length] == 0){
                    [MBProgressHUD showError:@"缺少partner或者seller或者私钥"];
                    return;
                }
                /*
                 *生成订单信息及签名
                 */
                //将商品信息赋予AlixPayOrder的成员变量
                Order *order = [[Order alloc] init];
                order.partner = partner;
                order.seller = seller;
                
                order.tradeNO = infos;
                if ([_method isEqual:@"vip"]) {
                    order.notifyURL = [h5url stringByAppendingString:@"/appapi/vippay/notify_ali"];
                }else{
                    order.notifyURL = [h5url stringByAppendingString:@"/appapi/cartpay/notify_ali"];
                }
                order.amount = minstr([infoDic valueForKey:@"money"]);
                order.productName = [NSString stringWithFormat:@"¥%@",[infoDic valueForKey:@"money"]];
                order.productDescription = @"productDescription";
                //以下配置信息是默认信息,不需要更改.
                order.service = @"mobile.securitypay.pay";
                order.paymentType = @"1";
                order.inputCharset = @"utf-8";
                order.itBPay = @"30m";
                order.showUrl = @"m.alipay.com";
                //应用注册scheme,在AlixPayDemo-Info.plist定义URL types,用于快捷支付成功后重新唤起商户应用
                //[[NSBundle mainBundle] bundleIdentifier]
                NSString *appScheme = @"wanyueEducation";
                //将商品信息拼接成字符串
                NSString *orderSpec = [order description];
                NSLog(@"orderSpec = %@",orderSpec);
                //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
                id<DataSigner> signer = CreateRSADataSigner(privateKey);
                NSString *signedString = [signer signString:orderSpec];
                
                //将签名成功字符串格式化为订单字符串,请严格按照该格式
                NSString *orderString = nil;
                if (signedString != nil) {
                    orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                                   orderSpec, signedString, @"RSA"];
                    NSArray *array = [[UIApplication sharedApplication] windows];
                    UIWindow* win=[array objectAtIndex:0];
                    NSURL * myURL_APP_A = [NSURL URLWithString:@"alipay:"];
                    if (![[UIApplication sharedApplication] canOpenURL:myURL_APP_A]) {
                        [win setHidden:NO];
                    }
                    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                              [win setHidden:YES];
                        });
                        [[NSNotificationCenter defaultCenter] postNotificationName:WYAlipayRsultttt object:resultDic];

                        NSLog(@"reslut = %@",resultDic);
                        NSInteger resultStatus = [resultDic[@"resultStatus"] integerValue];
                        NSLog(@"#######%ld",(long)resultStatus);
                        // NSString *publicKey = alipaypublicKey;
                        NSLog(@"支付状态信息---%ld---%@",resultStatus,[resultDic valueForKey:@"memo"]);
                        // 是否支付成功
//                        if (9000 == resultStatus) {
//                            /*
//                             *用公钥验证签名
//                             */
//                            [MBProgressHUD showError:@"支付成功"];
//                        }else {
//                            [MBProgressHUD showError:@"支付失败"];
//                        }
                    }];
                }

            }else if ([minstr([parameterDic valueForKey:@"payid"]) isEqual:@"2"]){
                NSDictionary *wxDic = [infoDic valueForKey:@"wx"];
                
                [WXApi registerApp:minstr([wxDic valueForKey:@"appid"]) universalLink:WechatUniversalLink];
                
                //调起微信支付
                NSString *times = [wxDic objectForKey:@"timestamp"];
                PayReq* req             = [[PayReq alloc] init];
                req.partnerId           = [wxDic objectForKey:@"partnerid"];
                NSString *pid = [NSString stringWithFormat:@"%@",[wxDic objectForKey:@"prepayid"]];
                if ([pid isEqual:[NSNull null]] || pid == NULL || [pid isEqual:@"null"]) {
                    pid = @"123";
                }
                req.prepayId            = pid;
                req.nonceStr            = [wxDic objectForKey:@"noncestr"];
                req.timeStamp           = times.intValue;
                req.package             = [wxDic objectForKey:@"package"];
                req.sign                = [wxDic objectForKey:@"sign"];
                [WXApi sendReq:req completion:nil];

            }else{
                [MBProgressHUD hideHUD];
//                if (![_method isEqual:@"vip"]) {
                    NSDictionary *coindic = @{@"wx":@"-99"};
                    [[NSNotificationCenter defaultCenter] postNotificationName:WYWXApiPaySuccess object:nil userInfo:coindic];
//                }
//                [MBProgressHUD showError:@"支付成功"];
//                MineOrderPageViewController *vc = [[MineOrderPageViewController alloc]init];
//                [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
            }


        }else if (code == 970){
            [MBProgressHUD showError:msg];
            [[MXBADelegate sharedAppDelegate] popViewController:YES];
        }else if (code == 900){
            [MBProgressHUD showError:msg];
            if (self.block) {
                self.block();
            }
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];

    }];

    
}
- (void)show{
    self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        whiteView.y = _window_height-ShowDiff-168 - payListArray.count*61;
    }];
}
- (void)setMoneyStr:(NSString *)moneyStr{
    _moneyStr = moneyStr;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"¥ %@",_moneyStr]];
    [attStr addAttribute:NSFontAttributeName value:SYS_Font(12) range:NSMakeRange(0, 1)];
    moneyL.attributedText = attStr;
}
@end
