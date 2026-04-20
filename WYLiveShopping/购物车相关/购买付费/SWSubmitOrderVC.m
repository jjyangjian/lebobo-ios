//
//  SWSubmitOrderVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/30.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWSubmitOrderVC.h"
#import "SWSubmitGoodsCell.h"
#import "SWAddressView.h"
#import "SWAddressModel.h"
#import "SWMyTextView.h"
#import "SWUseCouponView.h"
#import <WXApi.h>
#import "SWPaySucessViewController.h"

@interface SWSubmitOrderVC ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
@property (nonatomic, strong) UITableView *submitTableView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) SWAddressView *addressView;
@property (nonatomic, strong) NSMutableArray *addressArray;
@property (nonatomic, strong) UILabel *totalAmountLabel;
@property (nonatomic, strong) UIButton *integralButton;
@property (nonatomic, strong) NSMutableArray *payButtonArray;
@property (nonatomic, strong) NSMutableArray *payImageButtonArray;
@property (nonatomic, strong) NSString *payTypeString;
@property (nonatomic, strong) SWUseCouponView *couponView;
@property (nonatomic, strong) NSString *createdOrderID;
@end

@implementation SWSubmitOrderVC
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _window_height - 60 - ShowDiff, _window_width, 60 + ShowDiff)];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (void)creatBottomViewContent{
    UILabel *label = [[UILabel alloc] init];
    label.text = @"合计：";
    label.font = SYS_Font(13);
    label.textColor = color32;
    [self.bottomView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(23);
        make.centerY.equalTo(self.bottomView.mas_top).offset(30.5);
    }];

    self.totalAmountLabel = [[UILabel alloc] init];
    self.totalAmountLabel.font = [UIFont boldSystemFontOfSize:17];
    self.totalAmountLabel.textColor = normalColors;
    self.totalAmountLabel.text = [NSString stringWithFormat:@"¥%@", minstr([self.orderMessage valueForKey:@"pay_price"])];
    [self.bottomView addSubview:self.totalAmountLabel];
    [self.totalAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label.mas_right).offset(5);
        make.centerY.equalTo(label);
    }];

    UIButton *submitButton = [UIButton buttonWithType:0];
    [submitButton setBackgroundColor:normalColors];
    [submitButton setTitle:@"立即结算" forState:0];
    submitButton.titleLabel.font = SYS_Font(14);
    submitButton.layer.cornerRadius = 15;
    submitButton.layer.masksToBounds = YES;
    [submitButton addTarget:self action:@selector(doSubmit) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:submitButton];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-15);
        make.centerY.equalTo(label);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(30);
    }];
}

- (void)doSubmit{
    if ([self.payTypeString isEqual:@"yue"]) {
        CGFloat nowMoney = [minstr([[self.orderMessage valueForKey:@"userInfo"] valueForKey:@"now_money"]) floatValue];
        CGFloat payPrice = [minstr([self.orderMessage valueForKey:@"pay_price"]) floatValue];
        if (nowMoney < payPrice) {
            [MBProgressHUD showError:@"余额不足"];
            return;
        }
    }

    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    if ([self.addressView.adressDic count] > 0) {
        [parameterDictionary setObject:minstr([self.addressView.adressDic valueForKey:@"id"]) forKey:@"addressId"];
    } else {
        [MBProgressHUD showError:@"请填写收货地址"];
        return;
    }
    [MBProgressHUD showMessage:@"订单支付中"];

    NSMutableDictionary *couponDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *markDictionary = [NSMutableDictionary dictionary];
    for (NSMutableDictionary *dictionary in self.dataArray) {
        id usableCoupon = [dictionary valueForKey:@"usableCoupon"];
        if ([usableCoupon isKindOfClass:[NSDictionary class]] && [usableCoupon count] > 0) {
            [couponDictionary setObject:minstr([usableCoupon valueForKey:@"id"]) forKey:minstr([dictionary valueForKey:@"mer_id"])];
        } else {
            [couponDictionary setObject:@"" forKey:minstr([dictionary valueForKey:@"mer_id"])];
        }
        [markDictionary setObject:minstr([dictionary valueForKey:@"beizhu"]) forKey:minstr([dictionary valueForKey:@"mer_id"])];
    }

    NSData *couponData = [NSJSONSerialization dataWithJSONObject:couponDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *couponString = [[NSString alloc] initWithData:couponData encoding:NSUTF8StringEncoding];
    [parameterDictionary setObject:couponString forKey:@"couponId"];

    NSData *markData = [NSJSONSerialization dataWithJSONObject:markDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *markString = [[NSString alloc] initWithData:markData encoding:NSUTF8StringEncoding];
    [parameterDictionary setObject:markString forKey:@"mark"];
    [parameterDictionary setObject:self.payTypeString forKey:@"payType"];
    [parameterDictionary setObject:@"ios" forKey:@"from"];
    if (self.liveUid && self.liveUid.length > 0) {
        [parameterDictionary setObject:self.liveUid forKey:@"liveuid"];
    }
    [parameterDictionary setObject:[NSString stringWithFormat:@"%d", self.integralButton.selected] forKey:@"useIntegral"];

    [SWToolClass postNetworkWithUrl:[NSString stringWithFormat:@"order/create/%@", minstr([self.orderMessage valueForKey:@"orderKey"])] andParameter:parameterDictionary success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [[NSNotificationCenter defaultCenter] postNotificationName:WYCarNumChange object:nil];
            NSDictionary *result = [info valueForKey:@"result"];
            self.createdOrderID = minstr([result valueForKey:@"orderId"]);
            if ([minstr([info valueForKey:@"status"]) isEqual:@"PAY_ERROR"]) {
                [MBProgressHUD hideHUD];
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                SWPaySucessViewController *vc = [[SWPaySucessViewController alloc] init];
                vc.orderID = self.createdOrderID;
                vc.failReason = @"支付失败";
                vc.liveUid = self.liveUid;
                [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
            } else {
                if ([self.payTypeString isEqual:@"weixin"]) {
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
                } else {
                    [MBProgressHUD hideHUD];
                    [[NSNotificationCenter defaultCenter] removeObserver:self];
                    SWPaySucessViewController *vc = [[SWPaySucessViewController alloc] init];
                    vc.orderID = self.createdOrderID;
                    vc.liveUid = self.liveUid;
                    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
                }
            }
        }
    } fail:^{
    }];
}

- (void)wxPayResult:(NSNotification *)not{
    [MBProgressHUD hideHUD];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    PayResp *response = not.object;
    SWPaySucessViewController *vc = [[SWPaySucessViewController alloc] init];
    vc.orderID = self.createdOrderID;
    vc.liveUid = self.liveUid;

    switch (response.errCode) {
        case WXSuccess:
            NSLog(@"支付成功");
            break;
        case WXErrCodeUserCancel:
            [MBProgressHUD showError:@"已取消支付"];
            vc.failReason = @"取消支付";
            break;
        default:
            [MBProgressHUD showError:@"支付失败"];
            vc.failReason = @"支付失败";
            break;
    }
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)addTableFootView{
    self.payButtonArray = [NSMutableArray array];
    self.payImageButtonArray = [NSMutableArray array];
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width - 20, 220)];
    footView.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);

    UIView *integralContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width - 20, 50)];
    integralContainerView.backgroundColor = [UIColor whiteColor];
    integralContainerView.layer.cornerRadius = 5;
    [footView addSubview:integralContainerView];

    UILabel *label = [[UILabel alloc] init];
    label.text = @"积分抵扣";
    label.font = SYS_Font(13);
    label.textColor = color32;
    [integralContainerView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(integralContainerView).offset(14);
        make.centerY.equalTo(integralContainerView);
    }];

    self.integralButton = [UIButton buttonWithType:0];
    [self.integralButton setImage:[UIImage imageNamed:@"jubao_nor"] forState:0];
    [self.integralButton setImage:[UIImage imageNamed:@"cart_sel"] forState:UIControlStateSelected];
    [self.integralButton addTarget:self action:@selector(doSelectJifen) forControlEvents:UIControlEventTouchUpInside];
    [integralContainerView addSubview:self.integralButton];
    [self.integralButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(integralContainerView).offset(-10);
        make.centerY.equalTo(label);
        make.width.height.mas_equalTo(25);
    }];

    UILabel *rightLabel = [[UILabel alloc] init];
    rightLabel.font = SYS_Font(13);
    rightLabel.textColor = RGB_COLOR(@"#c8c8c8", 1);
    rightLabel.attributedText = [self getJifen:minstr([[self.orderMessage valueForKey:@"userInfo"] valueForKey:@"integral"])];
    [integralContainerView addSubview:rightLabel];
    [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.integralButton.mas_left).offset(-5);
        make.centerY.equalTo(integralContainerView);
    }];

    UIView *payContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, _window_width - 20, 150)];
    payContainerView.backgroundColor = [UIColor whiteColor];
    payContainerView.layer.cornerRadius = 5;
    [footView addSubview:payContainerView];

    UILabel *payLabel = [[UILabel alloc] init];
    payLabel.text = @"支付方式";
    payLabel.font = SYS_Font(13);
    payLabel.textColor = color32;
    [payContainerView addSubview:payLabel];
    [payLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(payContainerView).offset(14);
        make.centerY.equalTo(payContainerView.mas_top).offset(25.5);
    }];

    NSArray *titleArray = @[@"微信支付", @"余额支付"];
    NSArray *descArray = @[@"微信快捷支付", [NSString stringWithFormat:@"可用余额:%@", minstr([[self.orderMessage valueForKey:@"userInfo"] valueForKey:@"now_money"])]];
    for (int i = 0; i < titleArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:0];
        button.frame = CGRectMake(15, 43 + i * 53, _window_width - 50, 43);
        button.layer.cornerRadius = 3;
        button.layer.masksToBounds = YES;
        [button setBorderWidth:1];
        button.tag = 1000 + i;
        [button addTarget:self action:@selector(payTypeClick:) forControlEvents:UIControlEventTouchUpInside];
        [payContainerView addSubview:button];

        UIButton *imageButton = [UIButton buttonWithType:0];
        [imageButton setImage:[UIImage imageNamed:titleArray[i]] forState:0];
        [imageButton setTitle:[NSString stringWithFormat:@" %@", titleArray[i]] forState:0];
        [imageButton setTitleColor:color32 forState:0];
        [imageButton setTitleColor:normalColors forState:UIControlStateSelected];
        imageButton.titleLabel.font = SYS_Font(14);
        imageButton.userInteractionEnabled = NO;
        imageButton.tag = button.tag + 1000;
        [button addSubview:imageButton];
        [imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(button);
            make.centerX.equalTo(button).multipliedBy(0.5);
        }];

        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = RGB_COLOR(@"#EEEEEE", 1);
        [button addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(button);
            make.width.mas_equalTo(1);
            make.height.mas_equalTo(22);
        }];

        UILabel *tipsLabel = [[UILabel alloc] init];
        tipsLabel.text = descArray[i];
        tipsLabel.font = SYS_Font(13);
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.textColor = RGB_COLOR(@"#aaaaaa", 1);
        [button addSubview:tipsLabel];
        [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(button);
            make.centerX.equalTo(button).multipliedBy(1.5);
            make.width.equalTo(button).multipliedBy(0.5).offset(-5);
        }];

        if (i == 0) {
            [button setBorderColor:normalColors];
            imageButton.selected = YES;
        } else {
            [button setBorderColor:RGB_COLOR(@"#EEEEEE", 1)];
            imageButton.selected = NO;
        }
        [self.payButtonArray addObject:button];
        [self.payImageButtonArray addObject:imageButton];
    }

    self.submitTableView.tableFooterView = footView;
}

- (NSAttributedString *)getJifen:(NSString *)nums{
    NSMutableAttributedString *mustr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"当前积分 %@", nums]];
    [mustr setAttributes:@{NSForegroundColorAttributeName:normalColors} range:NSMakeRange(5, nums.length)];
    return mustr;
}

- (void)doSelectJifen{
    NSString *integral = minstr([[self.orderMessage valueForKey:@"userInfo"] valueForKey:@"integral"]);
    if ([integral floatValue] == 0) {
        [MBProgressHUD showError:@"暂无可用积分"];
    } else {
        self.integralButton.selected = !self.integralButton.selected;
        [self computedOrderPrice];
    }
}

- (void)payTypeClick:(UIButton *)sender{
    for (int i = 0; i < self.payButtonArray.count; i++) {
        UIButton *button = self.payButtonArray[i];
        UIButton *imageButton = self.payImageButtonArray[i];
        if (sender == button) {
            [button setBorderColor:normalColors];
            imageButton.selected = YES;
            if (i == 0) {
                self.payTypeString = @"weixin";
            } else {
                self.payTypeString = @"yue";
            }
        } else {
            [button setBorderColor:RGB_COLOR(@"#EEEEEE", 1)];
            imageButton.selected = NO;
        }
    }
}

- (UITableView *)submitTableView{
    if (!_submitTableView) {
        _submitTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, self.naviView.bottom, _window_width - 20, _window_height - (self.naviView.bottom + 60 + ShowDiff)) style:1];
        _submitTableView.delegate = self;
        _submitTableView.dataSource = self;
        _submitTableView.separatorStyle = 0;
        _submitTableView.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
        _submitTableView.showsVerticalScrollIndicator = NO;
        _submitTableView.estimatedSectionFooterHeight = 0;
        _submitTableView.estimatedSectionHeaderHeight = 0;
        if (@available(iOS 15.0, *)) {
            _submitTableView.sectionHeaderTopPadding = 0;
        }
    }
    return _submitTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviView.backgroundColor = normalColors;
    self.lineView.hidden = YES;
    self.titleL.text = @"提交订单";
    self.titleL.textColor = [UIColor whiteColor];
    [self.returnBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
    self.view.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
    self.dataArray = [NSMutableArray array];
    self.addressArray = [NSMutableArray array];
    self.payTypeString = @"weixin";
    for (NSDictionary *dic in [self.orderMessage valueForKey:@"cartInfo"]) {
        NSMutableDictionary *mutableDictionary = [dic mutableCopy];
        NSArray *list = [dic valueForKey:@"list"];
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *itemDictionary in list) {
            SWCartModel *model = [[SWCartModel alloc] initWithDic:itemDictionary];
            [array addObject:model];
        }
        [mutableDictionary setObject:array forKey:@"model"];
        [mutableDictionary setObject:@"" forKey:@"beizhu"];
        [self.dataArray addObject:mutableDictionary];
    }
    [self.view addSubview:self.submitTableView];
    [self.view addSubview:self.bottomView];
    [self creatBottomViewContent];
    [self creatAddressView];
    [self addTableFootView];
    [self computedOrderPrice];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxPayResult:) name:WYWXApiPaySuccess object:nil];
}

- (void)creatAddressView{
    self.addressView = [[[NSBundle mainBundle] loadNibNamed:@"SWAddressView" owner:nil options:nil] lastObject];
    self.addressView.frame = CGRectMake(0, 0, self.submitTableView.width, 110);
    id addressInfo = [self.orderMessage valueForKey:@"addressInfo"];
    if ([addressInfo isKindOfClass:[NSDictionary class]] && [addressInfo count] > 0) {
        self.addressView.adressDic = addressInfo;
    } else {
        self.addressView.adressDic = @{};
    }
    WeakSelf;
    self.addressView.block = ^{
        [weakSelf computedOrderPrice];
    };
    self.submitTableView.tableHeaderView = self.addressView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = [self.dataArray[section] valueForKey:@"model"];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWSubmitGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"submitGoodsCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWSubmitGoodsCell" owner:nil options:nil] lastObject];
    }
    NSArray *array = [self.dataArray[indexPath.section] valueForKey:@"model"];
    cell.model = array[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width - 20, 40)];
    view.backgroundColor = [UIColor whiteColor];
    view.clipsToBounds = YES;

    UIImageView *imgV = [[UIImageView alloc] init];
    imgV.image = [UIImage imageNamed:@"小店"];
    [view addSubview:imgV];
    [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(14);
        make.centerY.equalTo(view);
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(16);
    }];

    NSDictionary *dictionary = self.dataArray[section];
    UILabel *label = [[UILabel alloc] init];
    label.text = minstr([dictionary valueForKey:@"name"]);
    label.font = SYS_Font(14);
    label.textColor = color32;
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgV.mas_right).offset(8);
        make.centerY.equalTo(view);
    }];
    view.layer.mask = [[SWToolClass sharedInstance] setViewLeftTop:5 andRightTop:5 andView:view];
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 39, _window_width - 20, 1) andColor:RGB_COLOR(@"#eeeeee", 1) andView:view];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 260;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width - 20, 260)];
    view.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width - 20, 250)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.clipsToBounds = YES;
    [view addSubview:contentView];
    contentView.layer.mask = [[SWToolClass sharedInstance] setViewLeftBottom:5 andRightBottom:5 andView:contentView];

    NSDictionary *priceGroup = [self.dataArray[section] valueForKey:@"priceGroup"];
    id usableCoupon = [self.dataArray[section] valueForKey:@"usableCoupon"];
    NSArray *array = @[@"优惠券", @"快递费用"];
    for (int i = 0; i < array.count; i++) {
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, i * 51, _window_width - 20, 50)];
        [contentView addSubview:aView];
        UILabel *label = [[UILabel alloc] init];
        label.text = array[i];
        label.font = SYS_Font(13);
        label.textColor = color32;
        [aView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(aView).offset(14);
            make.centerY.equalTo(aView);
        }];

        UILabel *rightLabel = [[UILabel alloc] init];
        rightLabel.font = SYS_Font(13);
        rightLabel.textColor = RGB_COLOR(@"#c8c8c8", 1);
        [aView addSubview:rightLabel];
        [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(aView).offset(-15);
            make.centerY.equalTo(aView);
        }];

        if (i == 0) {
            UIImageView *rightImgV = [[UIImageView alloc] init];
            rightImgV.image = [UIImage imageNamed:@"profit_right"];
            [aView addSubview:rightImgV];
            [rightImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(aView).offset(-10);
                make.centerY.equalTo(label);
                make.width.height.mas_equalTo(15);
            }];
            [rightLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(rightImgV.mas_left).offset(-5);
                make.centerY.equalTo(aView);
            }];
            if ([usableCoupon isKindOfClass:[NSDictionary class]] && [usableCoupon count] > 0) {
                rightLabel.text = minstr([usableCoupon valueForKey:@"coupon_title"]);
            } else {
                rightLabel.text = @"请选择";
            }
            UIButton *button = [UIButton buttonWithType:0];
            button.tag = 10000 + section;
            [button addTarget:self action:@selector(showCoupon:) forControlEvents:UIControlEventTouchUpInside];
            [aView addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.width.height.equalTo(aView);
            }];
        } else {
            if ([minstr([priceGroup valueForKey:@"storePostage"]) intValue] == 0) {
                rightLabel.text = @"免运费";
            } else {
                rightLabel.text = [NSString stringWithFormat:@"运费：%@", minstr([priceGroup valueForKey:@"storePostage"])];
            }
        }

        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = colorf0;
        [contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(label);
            make.right.equalTo(contentView).offset(-15);
            make.top.equalTo(aView.mas_bottom);
            make.height.mas_equalTo(1);
        }];
    }

    UILabel *label = [[UILabel alloc] init];
    label.text = @"备注信息";
    label.font = SYS_Font(13);
    label.textColor = color32;
    [contentView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(14);
        make.top.equalTo(contentView).offset(112);
        make.height.mas_equalTo(31);
    }];

    SWMyTextView *textView = [[SWMyTextView alloc] initWithFrame:CGRectMake(15, 143, _window_width - 50, 60)];
    textView.placeholder = @"请添加备注（150字以内）";
    textView.font = SYS_Font(13);
    textView.textColor = color32;
    textView.placeholderColor = RGB_COLOR(@"#C8C8C8", 1);
    textView.backgroundColor = colorf0;
    textView.delegate = self;
    textView.tag = 20000 + section;
    [contentView addSubview:textView];
    if (minstr([self.dataArray[section] valueForKey:@"beizhu"]).length > 0) {
        textView.text = minstr([self.dataArray[section] valueForKey:@"beizhu"]);
    } else {
        textView.text = @"";
    }

    UILabel *totalLabel = [[UILabel alloc] init];
    totalLabel.font = SYS_Font(13);
    totalLabel.textColor = normalColors;
    [contentView addSubview:totalLabel];
    [totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(textView);
        make.centerY.equalTo(textView.mas_bottom).offset(24);
    }];
    NSArray *modelArray = [self.dataArray[section] valueForKey:@"model"];
    int nums = 0;
    for (SWCartModel *model in modelArray) {
        nums += [model.cart_num intValue];
    }
    totalLabel.attributedText = [self getAttStrWithNums:[NSString stringWithFormat:@"%d", nums] andTotalMoney:minstr([[self.dataArray[section] valueForKey:@"priceGroup"] valueForKey:@"totalPrice"])];
    return view;
}

- (NSAttributedString *)getAttStrWithNums:(NSString *)nums andTotalMoney:(NSString *)money{
    NSMutableAttributedString *mustr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"共%@件 小计：¥%@", nums, money]];
    [mustr setAttributes:@{NSForegroundColorAttributeName:RGB_COLOR(@"#C8C8C8", 1)} range:NSMakeRange(0, nums.length + 2)];
    [mustr setAttributes:@{NSForegroundColorAttributeName:color32} range:NSMakeRange(nums.length + 3, 3)];
    return mustr;
}

- (void)showCoupon:(UIButton *)sender{
    if (self.couponView) {
        [self.couponView removeFromSuperview];
        self.couponView = nil;
    }
    NSMutableDictionary *mutableDictionary = self.dataArray[sender.tag - 10000];
    id usableCoupon = [mutableDictionary valueForKey:@"usableCoupon"];
    NSString *selectID = @"";
    if ([usableCoupon isKindOfClass:[NSDictionary class]] && [usableCoupon count] > 0) {
        selectID = minstr([usableCoupon valueForKey:@"id"]);
    }
    NSDictionary *priceGroup = [mutableDictionary valueForKey:@"priceGroup"];
    self.couponView = [[SWUseCouponView alloc] initWithCouponID:selectID andIsDraw:NO andUsePrice:minstr([priceGroup valueForKey:@"totalPrice"]) andCart:mutableDictionary];
    WeakSelf;
    self.couponView.block = ^(NSDictionary * _Nonnull dic) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (dic) {
                [mutableDictionary setObject:dic forKey:@"usableCoupon"];
                [weakSelf.submitTableView reloadData];
                [weakSelf computedOrderPrice];
            }
            [weakSelf.couponView removeFromSuperview];
            weakSelf.couponView = nil;
        });
    };
    [self.view addSubview:self.couponView];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    NSMutableDictionary *mutableDictionary = self.dataArray[textView.tag - 20000];
    [mutableDictionary setObject:minstr(textView.text) forKey:@"beizhu"];
}

- (void)computedOrderPrice{
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    if ([self.addressView.adressDic count] > 0) {
        [parameterDictionary setObject:minstr([self.addressView.adressDic valueForKey:@"id"]) forKey:@"addressId"];
    } else {
        [parameterDictionary setObject:@"" forKey:@"addressId"];
    }

    NSMutableDictionary *couponDictionary = [NSMutableDictionary dictionary];
    for (NSMutableDictionary *dictionary in self.dataArray) {
        id usableCoupon = [dictionary valueForKey:@"usableCoupon"];
        if ([usableCoupon isKindOfClass:[NSDictionary class]] && [usableCoupon count] > 0) {
            [couponDictionary setObject:minstr([usableCoupon valueForKey:@"id"]) forKey:minstr([dictionary valueForKey:@"mer_id"])];
        } else {
            [couponDictionary setObject:@"" forKey:minstr([dictionary valueForKey:@"mer_id"])];
        }
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:couponDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [parameterDictionary setObject:jsonString forKey:@"couponId"];
    [parameterDictionary setObject:self.payTypeString forKey:@"payType"];
    [parameterDictionary setObject:[NSString stringWithFormat:@"%d", self.integralButton.selected] forKey:@"useIntegral"];

    [SWToolClass postNetworkWithUrl:[NSString stringWithFormat:@"order/computed/%@", minstr([self.orderMessage valueForKey:@"orderKey"])] andParameter:parameterDictionary success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            NSDictionary *result = [info valueForKey:@"result"];
            [self.orderMessage setObject:minstr([result valueForKey:@"pay_price"]) forKey:@"pay_price"];
            self.totalAmountLabel.text = [NSString stringWithFormat:@"¥%@", minstr([self.orderMessage valueForKey:@"pay_price"])];
            NSArray *priceGroupArray = [result valueForKey:@"priceGroup"];
            for (NSDictionary *dictionary in priceGroupArray) {
                for (NSMutableDictionary *merchantDictionary in self.dataArray) {
                    if ([minstr([dictionary valueForKey:@"mer_id"]) isEqual:minstr([merchantDictionary valueForKey:@"mer_id"])]) {
                        [merchantDictionary setObject:dictionary forKey:@"priceGroup"];
                    }
                }
            }
            [self.submitTableView reloadData];
        }
    } fail:^{
    }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
