//
//  spreadViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/3.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "spreadViewController.h"
#import "DistributionPosterViewController.h"
#import "promoterListViewController.h"
#import "commissionHistoryViewController.h"
#import "promoterOrderViewController.h"
#import "promoterRankViewController.h"
#import "commissionRankViewController.h"
#import "historyProfitViewController.h"
#import "tiquProfitVC.h"
#import "SpreadTixianViewController.h"
#import "spreadTixianjiluViewController.h"

@interface spreadViewController (){
    UILabel *curBringL;
    UILabel *yestdayL;
    UILabel *allLabel;
}
@property (nonatomic,strong) UIScrollView *backScrollView;

@end

@implementation spreadViewController
- (UIScrollView *)backScrollView{
    if (!_backScrollView) {
        _backScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height- (64+statusbarHeight))];
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
- (void)viewWillAppear:(BOOL)animated{
    [self requestData];

}
- (void)creatUI{
    UIImageView *backImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_width*0.456)];
    backImgV.image = [UIImage imageNamed:@"我的推广背景"];
    backImgV.userInteractionEnabled = YES;
    [_backScrollView addSubview:backImgV];
    
    UILabel *lable1 = [[UILabel alloc]init];
    lable1.font = SYS_Font(15);
    lable1.text = @"当前佣金";
    lable1.textColor = [UIColor whiteColor];
    [backImgV addSubview:lable1];
    [lable1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgV);
        make.centerY.equalTo(backImgV).multipliedBy(0.33);
    }];
    UIButton *historyBtn = [UIButton buttonWithType:0];
    [historyBtn addTarget:self action:@selector(doHistory) forControlEvents:UIControlEventTouchUpInside];
    [backImgV addSubview:historyBtn];
    [historyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(backImgV).offset(-5);
        make.centerY.equalTo(lable1);
        make.height.mas_equalTo(16);
    }];
    UIImageView *rightImgV = [[UIImageView alloc]init];
    rightImgV.image = [UIImage imageNamed:@"mine_right"];
    [historyBtn addSubview:rightImgV];
    [rightImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.right.centerY.equalTo(historyBtn);
        make.width.equalTo(rightImgV.mas_width);
    }];
    UILabel *orderLabel = [[UILabel alloc]init];
    orderLabel.font = SYS_Font(13);
    orderLabel.textColor = RGB_COLOR(@"#e6e6e6", 1);
    orderLabel.text = @"提现记录";
    [historyBtn addSubview:orderLabel];
    [orderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(historyBtn);
        make.right.equalTo(rightImgV.mas_left).offset(-2);
        make.centerY.equalTo(historyBtn);
    }];

    curBringL = [[UILabel alloc]init];
    curBringL.font = SYS_Font(43);
//    curBringL.text = minstr([_userInfo valueForKey:@"brokerage_price"]);
    curBringL.textColor = [UIColor whiteColor];
    [backImgV addSubview:curBringL];
    [curBringL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgV);
        make.centerY.equalTo(backImgV).multipliedBy(0.85);
    }];


    yestdayL = [[UILabel alloc]init];
    yestdayL.font = SYS_Font(12);
//    yestdayL.attributedText = [self setAttText:[NSString stringWithFormat:@"昨日收益\n%@",minstr([_userInfo valueForKey:@"yesterDay"])]];
    yestdayL.textAlignment = NSTextAlignmentCenter;
    yestdayL.numberOfLines = 0;
    yestdayL.textColor = RGB_COLOR(@"#E6E6E6", 1);
    [backImgV addSubview:yestdayL];
    [yestdayL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgV).multipliedBy(0.322);
        make.centerY.equalTo(backImgV).multipliedBy(1.62);
    }];
    
    allLabel = [[UILabel alloc]init];
    allLabel.font = SYS_Font(12);
//    allLabel.attributedText = [self setAttText:[NSString stringWithFormat:@"累积已提\n%@",minstr([_userInfo valueForKey:@"extractTotalPrice"])]];
    allLabel.textAlignment = NSTextAlignmentCenter;
    allLabel.numberOfLines = 0;
    allLabel.textColor = RGB_COLOR(@"#E6E6E6", 1);
    [backImgV addSubview:allLabel];
    [allLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgV).multipliedBy(1.677);
        make.centerY.equalTo(backImgV).multipliedBy(1.62);
    }];

    
    UIButton *tiquBtn = [UIButton buttonWithType:0];
    [tiquBtn setBackgroundImage:[UIImage imageNamed:@"button_back"] forState:0];
    [tiquBtn setTitle:@"立即提现" forState:0];
    tiquBtn.titleLabel.font = SYS_Font(13);
    tiquBtn.layer.masksToBounds = YES;
    [tiquBtn addTarget:self action:@selector(doLijitixian) forControlEvents:UIControlEventTouchUpInside];
    [_backScrollView addSubview:tiquBtn];
    [tiquBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backImgV.mas_bottom);
        make.centerX.equalTo(_backScrollView);
        make.width.equalTo(_backScrollView).multipliedBy(0.344);
        make.height.equalTo(tiquBtn.mas_width).multipliedBy(0.264);
    }];
    [tiquBtn layoutIfNeeded];
    tiquBtn.layer.cornerRadius = tiquBtn.height/2;
    
    NSArray *array = @[@"推广名片",@"推广人统计",@"佣金记录",@"推广人订单",@"推广人排行",@"佣金排行"];
    CGFloat btnWidth = (_window_width-30)/2;
    CGFloat btnHeight = btnWidth * 0.7;

    for (int i = 0; i < array.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(10 + (i%2)*(btnWidth + 10), backImgV.bottom + 35 + (i/2)*(btnHeight  +10), btnWidth, btnHeight);
        [btn setTitle:array[i] forState:0];
        [btn setImage:[UIImage imageNamed:array[i]] forState:0];
        [btn setTitleColor:color64 forState:0];
        btn.titleLabel.font = SYS_Font(15);
        btn.tag = 1000 + i;
        [btn setBackgroundColor:[UIColor whiteColor]];
        btn.layer.cornerRadius = 10;
        btn.layer.masksToBounds = YES;
        [btn addTarget:self action:@selector(itemBtnCLick:) forControlEvents:UIControlEventTouchUpInside];
        [_backScrollView addSubview:btn];
        btn = [WYToolClass setUpImgDownText:btn space:15];
        if (i == array.count - 1) {
            _backScrollView.contentSize = CGSizeMake(0, btn.bottom + ShowDiff + 20);
        }
    }
}
- (NSAttributedString *)setAttText:(NSString *)str{
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;

    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc]initWithString:str];
    [muStr addAttributes:@{NSFontAttributeName:SYS_Font(17),NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(4, str.length-4)];
    [muStr addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, str.length)];
    return muStr;
}
- (void)requestData{
    [WYToolClass getQCloudWithUrl:@"commission" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            curBringL.text = minstr([info valueForKey:@"commissionCount"]);
            yestdayL.attributedText = [self setAttText:[NSString stringWithFormat:@"昨日收益\n%@",minstr([info valueForKey:@"lastDayCount"])]];
            yestdayL.textAlignment = NSTextAlignmentCenter;
            allLabel.attributedText = [self setAttText:[NSString stringWithFormat:@"累积已提\n%@",minstr([info valueForKey:@"extractCount"])]];
            allLabel.textAlignment = NSTextAlignmentCenter;
        }
    } Fail:^{
        
    }];
}

///立即提现
- (void)doLijitixian{
    SpreadTixianViewController *vc = [[SpreadTixianViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

//    [MBProgressHUD showMessage:@""];
//    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"spread/count/4"] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
//        [MBProgressHUD hideHUD];
//        if (code == 200) {
//            tiquProfitVC *vc = [[tiquProfitVC alloc]init];
//            vc.moneyStr = minstr([info valueForKey:@"count"]);
//            vc.ptofitType = 2;
//            [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
//
//        }
//    } Fail:^{
//
//    }];
}
///提现记录
- (void)doHistory{
    spreadTixianjiluViewController *vc = [[spreadTixianjiluViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
- (void)itemBtnCLick:(UIButton *)sender{
    if (sender.tag == 1000) {
        DistributionPosterViewController *vc = [[DistributionPosterViewController alloc]init];
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
    else if (sender.tag == 1001) {
        promoterListViewController *vc = [[promoterListViewController alloc]init];
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }else if (sender.tag == 1002) {
        commissionHistoryViewController *vc = [[commissionHistoryViewController alloc]init];
        vc.curCommNums = [Config brokerage_price];
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }else if (sender.tag == 1003) {
        promoterOrderViewController *vc = [[promoterOrderViewController alloc]init];
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }else if (sender.tag == 1004) {
        promoterRankViewController *vc = [[promoterRankViewController alloc]init];
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }else{
        commissionRankViewController *vc = [[commissionRankViewController alloc]init];
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
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
