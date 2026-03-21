//
//  ConsignmentViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/3.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "ConsignmentViewController.h"
#import "GoodsAdminViewController.h"
#import "mineProfitViewController.h"
#import "StoreOrderListViewController.h"
@interface ConsignmentViewController ()
@property (nonatomic,strong) NSMutableArray *labelArray;
@property (nonatomic,strong) NSDictionary *infoDic;

@end

@implementation ConsignmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.returnBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
    self.lineView.hidden = YES;
    self.naviView.backgroundColor = normalColors;
    self.titleL.textColor = [UIColor whiteColor];
    self.titleL.text = @"我的代销";
    _labelArray = [NSMutableArray array];
    [self creatUI];
    [self requestData];
}
- (void)creatUI{
    UIImageView *colorImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, 76)];
    colorImgView.backgroundColor = normalColors;
    colorImgView.userInteractionEnabled = YES;
    [self.view addSubview:colorImgView];
    colorImgView.layer.mask = [[WYToolClass sharedInstance] setViewLeftBottom:25 andRightBottom:25 andView:colorImgView];
    NSArray *array = @[@"商品管理",@"代销订单",@"代销收益"];
    NSArray *array2 = @[@[@"在售商品",@"下架商品"],@[@"今日订单",@"累计订单"],@[@"今日收益(元)",@"总收益(元)",@"已结算(元)",@"未结算(元)"]];
    for (int i = 0; i < array.count; i ++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(15, 80+statusbarHeight+i*120, _window_width-30, i==2?200:110)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 3.0;
        view.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.05].CGColor;
        view.layer.borderWidth = 0.5;
        [self.view addSubview:view];
        UIButton *rightBtn = [UIButton buttonWithType:0];
        [rightBtn addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        rightBtn.tag = 1000 + i;
        [view addSubview:rightBtn];
        [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(view).offset(-5);
            make.top.equalTo(view);
            make.height.mas_equalTo(44);
        }];
        UIImageView *rightImgV = [[UIImageView alloc]init];
        rightImgV.image = [UIImage imageNamed:@"mine_right"];
        [rightBtn addSubview:rightImgV];
        [rightImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.centerY.equalTo(rightBtn);
            make.height.mas_equalTo(13);
            make.width.equalTo(rightImgV.mas_width);
        }];
        UILabel *rightLabel = [[UILabel alloc]init];
        rightLabel.font = SYS_Font(12);
        rightLabel.textColor = RGB_COLOR(@"#dcdcdc", 1);
        if (i == 1) {
            rightLabel.text = @"查看全部订单";
        }else{
            rightLabel.text = @"查看详情";
        }
        [rightBtn addSubview:rightLabel];
        [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(rightBtn);
            make.right.equalTo(rightImgV.mas_left).offset(-2);
            make.centerY.equalTo(rightBtn);
        }];
        UIImageView *leftImgV = [[UIImageView alloc]init];
        leftImgV.image = [UIImage imageNamed:@"代销竖线"];
        [view addSubview:leftImgV];
        [leftImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(20);
            make.centerY.equalTo(rightBtn);
            make.width.mas_equalTo(3);
            make.height.mas_equalTo(13);
        }];

        UILabel *label = [[UILabel alloc]init];
        label.font = [UIFont boldSystemFontOfSize:14];
        label.textColor = color32;
        label.text = array[i];
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftImgV.mas_right).offset(5);
            make.centerY.equalTo(rightBtn);
        }];

        NSArray *contentArray = array2[i];
        for (int j = 0; j < contentArray.count; j ++) {
            UILabel *topLabel = [[UILabel alloc]init];
            topLabel.font = SYS_Font(12);
            topLabel.textColor = color64;
            topLabel.text = contentArray[j];
            [view addSubview:topLabel];
            [topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                if (j%2 == 0) {
                    make.left.equalTo(label);
                }else{
                    make.left.equalTo(view.mas_centerX).offset(30);
                }
                make.centerY.equalTo(rightBtn.mas_bottom).offset(16 + (j/2)*75);
            }];
            UILabel *botLabel = [[UILabel alloc]init];
            if (i == 2) {
                botLabel.font = SYS_Font(12);
                botLabel.textColor = normalColors;
            }else{
                botLabel.font = [UIFont boldSystemFontOfSize:20];
                botLabel.textColor = color64;
            }
            botLabel.text = @"0";
            [view addSubview:botLabel];
            [botLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(topLabel);
                make.top.equalTo(topLabel.mas_bottom).offset(10);
            }];
            [_labelArray addObject:botLabel];
        }
    }
}
- (void)rightButtonClick:(UIButton *)sender{
    NSLog(@"代销%ld",sender.tag - 1000);
    if (sender.tag == 1000) {
        GoodsAdminViewController *vc = [[GoodsAdminViewController alloc]init];
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

    }else if (sender.tag == 1001){
        StoreOrderListViewController *vc = [[StoreOrderListViewController alloc]init];
        vc.statusType = @"1";
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

    }
    else{
        mineProfitViewController *vc = [[mineProfitViewController alloc]init];
        vc.ptofitType = 0;
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

    }

}
- (void)requestData{
    [WYToolClass getQCloudWithUrl:@"mybring" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            _infoDic = info;
            for (int i = 0; i < _labelArray.count; i ++) {
                UILabel *label = _labelArray[i];
                if (i == 0) {
                    label.text = minstr([info valueForKey:@"onnums"]);
                }
                else if (i == 1) {
                    label.text = minstr([info valueForKey:@"unnums"]);
                }
                else if (i == 2) {
                    label.text = minstr([info valueForKey:@"orders_t"]);
                }
                else if (i == 3) {
                    label.text = minstr([info valueForKey:@"orders_all"]);
                }
                else if (i == 4) {
                    label.attributedText = [self setAttText:minstr([info valueForKey:@"bring_t"])];
                }
                else if (i == 5) {
                    label.attributedText = [self setAttText:minstr([info valueForKey:@"bring_all"])];
                }
                else if (i == 6) {
                    label.attributedText = [self setAttText:minstr([info valueForKey:@"bring_ok"])];
                }
                else if (i == 7) {
                    label.attributedText = [self setAttText:minstr([info valueForKey:@"bring_no"])];
                }

            }
        }
    } Fail:^{
        
    }];

}
- (NSAttributedString *)setAttText:(NSString *)nums{
    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc]initWithString:nums];
    [muStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(0, [nums rangeOfString:@"."].location)];
    return muStr;
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
