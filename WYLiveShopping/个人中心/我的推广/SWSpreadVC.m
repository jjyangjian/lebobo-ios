//
//  SWSpreadVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/3.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWSpreadVC.h"
#import "SWDistributionPosterVC.h"
#import "SWPromoterListVC.h"
#import "SWCommissionHistoryVC.h"
#import "SWPromoterOrderVC.h"
#import "SWPromoterRankVC.h"
#import "SWCommissionRankVC.h"
#import "SWHistoryProfitVC.h"
#import "SWTiquProfitVC.h"
#import "SWSpreadTixianVC.h"
#import "SWSpreadTixianjiluVC.h"

@interface SWSpreadVC ()
@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) UILabel *currentCommissionLabel;
@property (nonatomic, strong) UILabel *yesterdayProfitLabel;
@property (nonatomic, strong) UILabel *allExtractedLabel;

@end

@implementation SWSpreadVC

- (UIScrollView *)backScrollView {
    if (!_backScrollView) {
        _backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight, _window_width, _window_height - (64 + statusbarHeight))];
        _backScrollView.backgroundColor = colorf0;
    }
    return _backScrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.returnBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
    self.lineView.hidden = YES;
    self.naviView.image = [UIImage imageNamed:@"button_back"];
    self.titleL.textColor = [UIColor whiteColor];
    self.titleL.text = @"我的推广";
    [self.view addSubview:self.backScrollView];
    [self creatUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [self requestData];
}

- (void)creatUI {
    UIImageView *backImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_width * 0.456)];
    backImgV.image = [UIImage imageNamed:@"我的推广背景"];
    backImgV.userInteractionEnabled = YES;
    [self.backScrollView addSubview:backImgV];

    UILabel *label1 = [[UILabel alloc] init];
    label1.font = SYS_Font(15);
    label1.text = @"当前佣金";
    label1.textColor = [UIColor whiteColor];
    [backImgV addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgV);
        make.centerY.equalTo(backImgV).multipliedBy(0.33);
    }];

    UIButton *historyButton = [UIButton buttonWithType:0];
    [historyButton addTarget:self action:@selector(doHistory) forControlEvents:UIControlEventTouchUpInside];
    [backImgV addSubview:historyButton];
    [historyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(backImgV).offset(-5);
        make.centerY.equalTo(label1);
        make.height.mas_equalTo(16);
    }];

    UIImageView *rightImgV = [[UIImageView alloc] init];
    rightImgV.image = [UIImage imageNamed:@"mine_right"];
    [historyButton addSubview:rightImgV];
    [rightImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.right.centerY.equalTo(historyButton);
        make.width.equalTo(rightImgV.mas_width);
    }];

    UILabel *orderLabel = [[UILabel alloc] init];
    orderLabel.font = SYS_Font(13);
    orderLabel.textColor = RGB_COLOR(@"#e6e6e6", 1);
    orderLabel.text = @"提现记录";
    [historyButton addSubview:orderLabel];
    [orderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(historyButton);
        make.right.equalTo(rightImgV.mas_left).offset(-2);
        make.centerY.equalTo(historyButton);
    }];

    self.currentCommissionLabel = [[UILabel alloc] init];
    self.currentCommissionLabel.font = SYS_Font(43);
    self.currentCommissionLabel.textColor = [UIColor whiteColor];
    [backImgV addSubview:self.currentCommissionLabel];
    [self.currentCommissionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgV);
        make.centerY.equalTo(backImgV).multipliedBy(0.85);
    }];

    self.yesterdayProfitLabel = [[UILabel alloc] init];
    self.yesterdayProfitLabel.font = SYS_Font(12);
    self.yesterdayProfitLabel.textAlignment = NSTextAlignmentCenter;
    self.yesterdayProfitLabel.numberOfLines = 0;
    self.yesterdayProfitLabel.textColor = RGB_COLOR(@"#E6E6E6", 1);
    [backImgV addSubview:self.yesterdayProfitLabel];
    [self.yesterdayProfitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgV).multipliedBy(0.322);
        make.centerY.equalTo(backImgV).multipliedBy(1.62);
    }];

    self.allExtractedLabel = [[UILabel alloc] init];
    self.allExtractedLabel.font = SYS_Font(12);
    self.allExtractedLabel.textAlignment = NSTextAlignmentCenter;
    self.allExtractedLabel.numberOfLines = 0;
    self.allExtractedLabel.textColor = RGB_COLOR(@"#E6E6E6", 1);
    [backImgV addSubview:self.allExtractedLabel];
    [self.allExtractedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgV).multipliedBy(1.677);
        make.centerY.equalTo(backImgV).multipliedBy(1.62);
    }];

    UIButton *tiquButton = [UIButton buttonWithType:0];
    [tiquButton setBackgroundImage:[UIImage imageNamed:@"button_back"] forState:0];
    [tiquButton setTitle:@"立即提现" forState:0];
    tiquButton.titleLabel.font = SYS_Font(13);
    tiquButton.layer.masksToBounds = YES;
    [tiquButton addTarget:self action:@selector(doLijitixian) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:tiquButton];
    [tiquButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backImgV.mas_bottom);
        make.centerX.equalTo(self.backScrollView);
        make.width.equalTo(self.backScrollView).multipliedBy(0.344);
        make.height.equalTo(tiquButton.mas_width).multipliedBy(0.264);
    }];
    [tiquButton layoutIfNeeded];
    tiquButton.layer.cornerRadius = tiquButton.height / 2;

    NSArray *array = @[@"推广名片", @"推广人统计", @"佣金记录", @"推广人订单", @"推广人排行", @"佣金排行"];
    CGFloat buttonWidth = (_window_width - 30) / 2;
    CGFloat buttonHeight = buttonWidth * 0.7;

    for (int i = 0; i < array.count; i++) {
        UIButton *button = [UIButton buttonWithType:0];
        button.frame = CGRectMake(10 + (i % 2) * (buttonWidth + 10), backImgV.bottom + 35 + (i / 2) * (buttonHeight + 10), buttonWidth, buttonHeight);
        [button setTitle:array[i] forState:0];
        [button setImage:[UIImage imageNamed:array[i]] forState:0];
        [button setTitleColor:color64 forState:0];
        button.titleLabel.font = SYS_Font(15);
        button.tag = 1000 + i;
        [button setBackgroundColor:[UIColor whiteColor]];
        button.layer.cornerRadius = 10;
        button.layer.masksToBounds = YES;
        [button addTarget:self action:@selector(itemBtnCLick:) forControlEvents:UIControlEventTouchUpInside];
        [self.backScrollView addSubview:button];
        button = [SWToolClass setUpImgDownText:button space:15];
        if (i == array.count - 1) {
            self.backScrollView.contentSize = CGSizeMake(0, button.bottom + ShowDiff + 20);
        }
    }
}

- (NSAttributedString *)setAttText:(NSString *)str {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;

    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc] initWithString:str];
    [muStr addAttributes:@{NSFontAttributeName: SYS_Font(17), NSForegroundColorAttributeName: [UIColor whiteColor]} range:NSMakeRange(4, str.length - 4)];
    [muStr addAttributes:@{NSParagraphStyleAttributeName: paragraphStyle} range:NSMakeRange(0, str.length)];
    return muStr;
}

- (void)requestData {
    [SWToolClass getQCloudWithUrl:@"commission" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.currentCommissionLabel.text = minstr([info valueForKey:@"commissionCount"]);
            self.yesterdayProfitLabel.attributedText = [self setAttText:[NSString stringWithFormat:@"昨日收益\n%@", minstr([info valueForKey:@"lastDayCount"])]];
            self.yesterdayProfitLabel.textAlignment = NSTextAlignmentCenter;
            self.allExtractedLabel.attributedText = [self setAttText:[NSString stringWithFormat:@"累积已提\n%@", minstr([info valueForKey:@"extractCount"])]];
            self.allExtractedLabel.textAlignment = NSTextAlignmentCenter;
        }
    } Fail:^{
    }];
}

- (void)doLijitixian {
    SWSpreadTixianVC *vc = [[SWSpreadTixianVC alloc] init];
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)doHistory {
    SWSpreadTixianjiluVC *vc = [[SWSpreadTixianjiluVC alloc] init];
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)itemBtnCLick:(UIButton *)sender {
    if (sender.tag == 1000) {
        SWDistributionPosterVC *vc = [[SWDistributionPosterVC alloc] init];
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    } else if (sender.tag == 1001) {
        SWPromoterListVC *vc = [[SWPromoterListVC alloc] init];
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    } else if (sender.tag == 1002) {
        SWCommissionHistoryVC *vc = [[SWCommissionHistoryVC alloc] init];
        vc.curCommNums = [SWConfig brokerage_price];
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    } else if (sender.tag == 1003) {
        SWPromoterOrderVC *vc = [[SWPromoterOrderVC alloc] init];
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    } else if (sender.tag == 1004) {
        SWPromoterRankVC *vc = [[SWPromoterRankVC alloc] init];
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    } else {
        SWCommissionRankVC *vc = [[SWCommissionRankVC alloc] init];
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

@end
