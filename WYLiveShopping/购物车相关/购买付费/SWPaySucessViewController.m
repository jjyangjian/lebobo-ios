//
//  SWPaySucessViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/2.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWPaySucessViewController.h"
#import "SWOrderDetailsVC.h"
#import "SWLivePlayerViewController.h"

@interface SWPaySucessViewController ()
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UIImageView *payStateImageView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UIButton *detailsButton;
@end

@implementation SWPaySucessViewController
- (void)doReturn{
    NSArray *viewControllers = self.navigationController.viewControllers;
    SWLivePlayerViewController *playerVC;
    for (UIViewController *temVC in viewControllers) {
        if ([temVC isKindOfClass:[SWLivePlayerViewController class]]) {
            playerVC = (SWLivePlayerViewController *)temVC;
        }
    }
    if (playerVC) {
        [self.navigationController popToViewController:playerVC animated:YES];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.view.backgroundColor = colorf0;
    [self creatUI];
    [self requestData];
}

- (void)creatUI{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(15, self.naviView.bottom + 60, _window_width - 30, 420)];
    [self.view addSubview:containerView];

    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, containerView.width, containerView.height - 30)];
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.layer.cornerRadius = 10;
    [containerView addSubview:whiteView];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(containerView.width / 2 - 30, 0, 60, 60)];
    [containerView addSubview:imageView];
    self.payStateImageView = imageView;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, whiteView.width, 40)];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.textColor = color32;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [whiteView addSubview:titleLabel];
    self.tipsLabel = titleLabel;

    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(15, titleLabel.bottom + 5, whiteView.width - 30, 1) andColor:colorf0 andView:whiteView];

    self.leftLabel = [[UILabel alloc] init];
    self.leftLabel.font = SYS_Font(14);
    self.leftLabel.textColor = color32;
    self.leftLabel.numberOfLines = 0;
    self.leftLabel.text = @"订单编号\n\n下单时间\n\n支付方式\n\n支付金额";
    [whiteView addSubview:self.leftLabel];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(whiteView).offset(15);
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
    }];

    self.rightLabel = [[UILabel alloc] init];
    self.rightLabel.font = SYS_Font(14);
    self.rightLabel.textColor = RGB_COLOR(@"#656565", 1);
    self.rightLabel.numberOfLines = 0;
    self.rightLabel.textAlignment = NSTextAlignmentRight;
    [whiteView addSubview:self.rightLabel];
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(whiteView).offset(-15);
        make.top.equalTo(self.leftLabel);
    }];

    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = colorf0;
    [whiteView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftLabel);
        make.right.equalTo(self.rightLabel);
        make.top.equalTo(self.leftLabel.mas_bottom).offset(15);
        make.height.mas_equalTo(1);
    }];

    NSArray *buttonTitles;
    if (self.liveUid && self.liveUid.length > 0) {
        buttonTitles = @[@"查看订单", @"返回直播间"];
    } else {
        buttonTitles = @[@"查看订单", @"返回首页"];
    }

    for (NSInteger i = 0; i < buttonTitles.count; i++) {
        UIButton *button = [UIButton buttonWithType:0];
        [button setTitle:buttonTitles[i] forState:0];
        [button setBorderColor:normalColors];
        [button setBorderWidth:1];
        [button setCornerRadius:21.5];
        button.titleLabel.font = SYS_Font(15);
        if (i == 0) {
            [button setBackgroundColor:normalColors];
            [button addTarget:self action:@selector(doOrderDetails) forControlEvents:UIControlEventTouchUpInside];
            self.detailsButton = button;
        } else {
            [button setTitleColor:normalColors forState:0];
            [button addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
        }
        [whiteView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftLabel);
            make.right.equalTo(self.rightLabel);
            make.top.equalTo(lineView.mas_bottom).offset(15 + i * 53);
            make.height.mas_equalTo(43);
        }];
    }
}

- (void)requestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"order/detail/%@", self.orderID] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            NSString *payTypeString = @"";
            if ([minstr([info valueForKey:@"pay_type"]) isEqual:@"weixin"]) {
                payTypeString = @"微信支付";
            } else if ([minstr([info valueForKey:@"pay_type"]) isEqual:@"yue"]) {
                payTypeString = @"余额支付";
            } else {
                payTypeString = @"线下付款";
            }

            if ([minstr([info valueForKey:@"paid"]) isEqual:@"1"]) {
                self.titleL.text = @"支付成功";
                self.tipsLabel.text = @"订单支付成功";
                self.payStateImageView.image = [UIImage imageNamed:@"支付成功"];
                self.leftLabel.text = @"订单编号\n\n下单时间\n\n支付方式\n\n支付金额";
                self.rightLabel.text = [NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@", minstr([info valueForKey:@"order_id"]), minstr([info valueForKey:@"_add_time"]), payTypeString, minstr([info valueForKey:@"pay_price"])];
            } else {
                self.titleL.text = @"支付失败";
                [self.detailsButton setTitle:@"重新支付" forState:0];
                self.tipsLabel.text = @"订单支付失败";
                self.payStateImageView.image = [UIImage imageNamed:@"支付失败"];
                self.leftLabel.text = @"订单编号\n\n下单时间\n\n支付方式\n\n支付金额\n\n失败原因";
                self.rightLabel.text = [NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@\n\n%@", minstr([info valueForKey:@"order_id"]), minstr([info valueForKey:@"_add_time"]), payTypeString, minstr([info valueForKey:@"pay_price"]), self.failReason];
            }
        }
    } Fail:^{

    }];
}

- (void)doOrderDetails{
    [MBProgressHUD showMessage:@""];
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"order/detail/%@?status=0", self.orderID] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            SWOrderDetailsVC *vc = [[SWOrderDetailsVC alloc] init];
            vc.orderMessage = info;
            vc.isCart = YES;
            vc.orderType = 0;
            [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
        }
    } Fail:^{

    }];
}

@end
