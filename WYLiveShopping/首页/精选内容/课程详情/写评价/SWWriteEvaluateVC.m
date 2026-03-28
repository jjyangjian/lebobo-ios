//
//  SWWriteEvaluateVC.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/12.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWWriteEvaluateVC.h"
#import "SWCWStarRateView.h"
#import "SWMyTextView.h"

@interface SWWriteEvaluateVC ()<CWStarRateViewDelegate>
@property (nonatomic,strong) SWCWStarRateView *rateView;
@property (nonatomic,strong) UILabel *starLabel;
@property (nonatomic,strong) SWMyTextView *evaTextView;
@property (nonatomic,strong) UIButton *bottomButton;
@property (nonatomic,copy) NSString *starNumString;

@end

@implementation SWWriteEvaluateVC
- (void)bottomBtnClick{
    [self.view endEditing:YES];
    if ([self.starNumString isEqual:@"0"]) {
        [MBProgressHUD showError:@"请选择星级"];
        return;
    }
    if (self.evaTextView.text == NULL || self.evaTextView.text == nil || self.evaTextView.text.length == 0) {
        [MBProgressHUD showError:@"请填写评价内容"];
        return;
    }
    [MBProgressHUD showMessage:@""];
    [SWToolClass postNetworkWithUrl:@"coursesetcomment" andParameter:@{@"courseid":minstr([_courseMsgDic valueForKey:@"id"]),@"star":self.starNumString,@"content":self.evaTextView.text} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            if (self.block) {
                self.block();
            }
            [super doReturn];
        }
        [MBProgressHUD showError:msg];

    } fail:^{
        [MBProgressHUD hideHUD];
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = colorf0;
    self.titleL.text = @"评价";
    self.starNumString = @"0";
    [self creatUI];
}
- (void)creatUI{
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self.view);
        make.top.equalTo(self.view).offset(64+statusbarHeight);
    }];
    UILabel *label = [[UILabel alloc]init];
    label.font = SYS_Font(14);
    label.textColor = color32;
    label.numberOfLines = 0;
    [headerView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(15);
        make.right.equalTo(headerView).offset(-15);
        make.top.equalTo(headerView).offset(15);
        make.bottom.equalTo(headerView).offset(-50);
    }];
    label.text = minstr([_courseMsgDic valueForKey:@"name"]);
    
    NSDictionary *userinfo = [_courseMsgDic valueForKey:@"userinfo"];
    UIImageView *iconImgV = [[UIImageView alloc]init];
    iconImgV.contentMode = UIViewContentModeScaleToFill;
    iconImgV.layer.cornerRadius = 7;
    iconImgV.layer.masksToBounds = YES;
    iconImgV.clipsToBounds = YES;
    [iconImgV sd_setImageWithURL:[NSURL URLWithString:minstr([userinfo valueForKey:@"avatar"])]];
    [headerView addSubview:iconImgV];
    [iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label);
        make.top.equalTo(label.mas_bottom).offset(16);
        make.width.height.mas_equalTo(14);
    }];
    UILabel *nameL = [[UILabel alloc]init];
    nameL.font = SYS_Font(10);
    nameL.textColor = color32;
    [headerView addSubview:nameL];
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconImgV.mas_right).offset(6);
        make.centerY.equalTo(iconImgV);
    }];
    nameL.text = minstr([userinfo valueForKey:@"user_nickname"]);
    
    UIView *evaView = [[UIView alloc]init];
    evaView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:evaView];
    [evaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self.view);
        make.top.equalTo(headerView.mas_bottom).offset(5);
        make.bottom.equalTo(self.view).offset(-(80+ShowDiff));
    }];
    UIView *starView = [[UIView alloc]init];
    starView.backgroundColor = [UIColor whiteColor];
    [evaView addSubview:starView];
    [starView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(evaView);
        make.top.equalTo(evaView);
        make.height.mas_equalTo(55);
    }];

    UILabel *zongtiL = [[UILabel alloc]init];
    zongtiL.font = SYS_Font(14);
    zongtiL.textColor = color32;
    zongtiL.text = @"总体评价";
    [starView addSubview:zongtiL];
    [zongtiL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(starView).offset(15);
        make.centerY.equalTo(starView);
    }];
    self.rateView = [[SWCWStarRateView alloc]initWithFrame:CGRectMake(100, 25, 120, 20) numberOfStars:5];
    self.rateView.delegate = self;
    [starView addSubview:self.rateView];
    self.rateView.scorePercent = 0;
    [self.rateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(zongtiL.mas_right).offset(5);
        make.centerY.equalTo(zongtiL);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(20);
    }];
    
    self.starLabel = [[UILabel alloc]init];
    self.starLabel.font = SYS_Font(14);
    self.starLabel.textColor = RGB_COLOR(@"#FFC822", 1);
    [starView addSubview:self.starLabel];
    [self.starLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(starView).offset(-15);
        make.centerY.equalTo(starView);
    }];
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = colorf0;
    [starView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(starView);
        make.bottom.equalTo(starView);
        make.height.mas_equalTo(1);
    }];

    
    
    self.evaTextView = [[SWMyTextView alloc]init];
    self.evaTextView.font = SYS_Font(14);
    self.evaTextView.textColor = color32;
    self.evaTextView.placeholder = @"老师水平怎么样？教学效果好不好？说说你的感受吧";
    self.evaTextView.placeholderColor = RGB_COLOR(@"#C7C7C7", 1);
    [evaView addSubview:self.evaTextView];
    [self.evaTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(evaView).offset(15);
        make.right.equalTo(evaView).offset(-15);
        make.top.equalTo(starView.mas_bottom).offset(15);
        make.height.mas_equalTo(150);
//        make.bottom.equalTo(evaView);
    }];
    
    
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.bottom.equalTo(self.view);
        make.height.mas_equalTo(60+ShowDiff);
    }];
    
    self.bottomButton = [UIButton buttonWithType:0];
    [self.bottomButton setBackgroundColor:normalColors];
    [self.bottomButton setTitle:@"发表评价" forState:0];
    self.bottomButton.titleLabel.font = SYS_Font(15);
    [self.bottomButton addTarget:self action:@selector(bottomBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.bottomButton.layer.cornerRadius = 5;
    self.bottomButton.layer.masksToBounds = YES;
    [bottomView addSubview:self.bottomButton];
    [self.bottomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(bottomView).offset(-30);
        make.centerX.equalTo(bottomView);
        make.height.mas_equalTo(40);
        make.top.equalTo(bottomView).offset(10);
    }];


}
- (void)starRateView:(SWCWStarRateView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent{
    if (newScorePercent == 0) {
        self.starLabel.text = @"";
        self.starNumString = @"0";
    }
    if (newScorePercent == 0.2) {
        self.starLabel.text = @"极不满意";
        self.starNumString = @"1";
    }
    if (newScorePercent == 0.4) {
        self.starLabel.text = @"不满意";
        self.starNumString = @"2";
    }
    if (newScorePercent == 0.6) {
        self.starLabel.text = @"一般";
        self.starNumString = @"3";
    }
    if (newScorePercent == 0.8) {
        self.starLabel.text = @"满意";
        self.starNumString = @"4";
    }
    if (newScorePercent == 1) {
        self.starLabel.text = @"非常满意";
        self.starNumString = @"5";

    }

}
- (void)doReturn{
    if (![self.starNumString isEqual:@"0"] || self.evaTextView.text.length > 0) {
        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:@"" message:@"离开后评价内容将清空，仍要\n离开吗？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"离开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [super doReturn];
        }];
        [cancleAction setValue:RGB_COLOR(@"#C7C7C7", 1) forKey:@"_titleTextColor"];

        [alertContro addAction:cancleAction];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"继续评价" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [sureAction setValue:normalColors forKey:@"_titleTextColor"];
        [alertContro addAction:sureAction];
        [self presentViewController:alertContro animated:YES completion:nil];

    }else{
        [super doReturn];
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
