//
//  SWSignInViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/30.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWSignInViewController.h"
#import "WHUCalendarView.h"
#import "WYSignINSucessView.h"

@interface SWSignInViewController (){
    UIView *currentLineV;
    UILabel *currentNameL;
    UILabel *currentValueL;
    UIImageView *currentImgView;
    UILabel *coinLabel;
}
@property (nonatomic,strong) WHUCalendarView *calview;

@end

@implementation SWSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"积分签到";
    self.view.backgroundColor = colorf0;
    UIView *headerbBackView = [[UIView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, 130)];
    headerbBackView.backgroundColor = normalColors;
    [self.view addSubview:headerbBackView];
    UIImageView *coinImgV = [[UIImageView alloc]initWithFrame:CGRectMake(15, 38, 14, 15)];
    coinImgV.image = [UIImage imageNamed:@"sign-jifen"];
    [headerbBackView addSubview:coinImgV];
    coinLabel = [[UILabel alloc]init];
    coinLabel.text = [NSString stringWithFormat:@"积分：%@",[Config getIntegral]];
    coinLabel.font = SYS_Font(14);
    coinLabel.textColor = [UIColor whiteColor];
    [headerbBackView addSubview:coinLabel];
    [coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(coinImgV);
        make.left.equalTo(coinImgV.mas_right).offset(8);
    }];
    UIView *signInView = [[UIView alloc]initWithFrame:CGRectMake(15, headerbBackView.top + 75, _window_width-30, 180)];
    signInView.layer.cornerRadius = 10;
    signInView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:signInView];
    UILabel *tipsLabel = [[UILabel alloc]init];
    tipsLabel.font = SYS_Font(12);
    tipsLabel.textColor = color64;
    [signInView addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(signInView.mas_top).offset(21);
        make.left.equalTo(signInView).offset(10);
    }];
    
    NSArray *array = [_messageDic valueForKey:@"config"];
    
    UIView *lastView;
    int days = [minstr([_messageDic valueForKey:@"days"]) intValue];
    NSDictionary *curDayDic;
    if (days < array.count) {
        curDayDic = [array objectAtIndex:days];
    }else{
        curDayDic = [array lastObject];
    }
    if ([minstr([_messageDic valueForKey:@"issign"]) isEqual:@"1"]) {
        tipsLabel.text = [NSString stringWithFormat:@"今日签到可获得%@积分",minstr([[array objectAtIndex:days-1] valueForKey:@"integral"])];
    }else{
        tipsLabel.text = [NSString stringWithFormat:@"今日签到可获得%@积分",minstr([curDayDic valueForKey:@"integral"])];
    }


    for (int i = 0 ; i < array.count; i ++) {
        NSDictionary *dic = array[i];
        UILabel *label = [[UILabel alloc]init];
        label.text = minstr([dic valueForKey:@"day_txt"]);
        label.font = SYS_Font(12);
        label.textColor = RGB_COLOR(@"#b4b4b4", 1);
        [signInView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(signInView).multipliedBy(0.125 + i*0.25);
            make.centerY.equalTo(signInView.mas_top).offset(51.5);
        }];
        UIImageView *imgV = [[UIImageView alloc]init];
        [signInView addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(label);
            make.centerY.equalTo(signInView.mas_top).offset(75);
            make.width.height.mas_equalTo(10);
        }];
        if (lastView) {
            [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(imgV.mas_left).offset(-7);
            }];
        }
        UIView *lineV;
        if (i < 7) {
            lineV = [[UIView alloc]init];
            lineV.backgroundColor = RGB_COLOR(@"#DCDCDC", 1);
            [signInView addSubview:lineV];
            [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(imgV.mas_right).offset(7);
                make.centerY.equalTo(imgV);
                make.height.mas_equalTo(1);
            }];
            lastView = lineV;
        }
        UILabel *stocelabel = [[UILabel alloc]init];
        stocelabel.text = [NSString stringWithFormat:@"+%@",minstr([dic valueForKey:@"integral"])];
        stocelabel.font = SYS_Font(10);
        stocelabel.textColor = RGB_COLOR(@"#b4b4b4", 1);
        [signInView addSubview:stocelabel];
        [stocelabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(label);
            make.centerY.equalTo(signInView.mas_top).offset(102);
        }];
        if (i<days) {
            if (i == days-1) {
                imgV.image = [UIImage imageNamed:@"cart_sel"];
            }else{
                imgV.image = [UIImage imageNamed:@"sign_sel"];
                if (days != 1) {
                    lineV.backgroundColor = normalColors;
                }
            }
            stocelabel.textColor = normalColors;
        }else{
            imgV.image = [UIImage imageNamed:@"sign_nor"];
        }
        if (i == days) {
            if (days != 0) {
                currentLineV = lineV;
            }
            currentNameL = label;
            currentValueL = stocelabel;
            currentImgView = imgV;
        }
    }
    UIButton *signInBtn = [UIButton buttonWithType:0];
    [signInBtn setBackgroundImage:[WYToolClass getImgWithColor:normalColors] forState:0];
    [signInBtn setTitle:@"签到" forState:0];
    [signInBtn setBackgroundImage:[WYToolClass getImgWithColor:RGB_COLOR(@"#B4B4B4", 1)] forState:UIControlStateSelected];
    [signInBtn setTitle:@"已签到" forState:UIControlStateSelected];
    signInBtn.titleLabel.font = SYS_Font(14);
    [signInBtn addTarget:self action:@selector(doSignIn:) forControlEvents:UIControlEventTouchUpInside];
    [signInBtn setCornerRadius:17];
    if ([minstr([_messageDic valueForKey:@"issign"]) isEqual:@"1"]) {
        signInBtn.selected = YES;
        signInBtn.userInteractionEnabled = NO;
    }else{
        signInBtn.selected = NO;
        signInBtn.userInteractionEnabled = YES;
    }
    [signInView addSubview:signInBtn];
    [signInBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(34);
        make.centerX.equalTo(signInView);
        make.bottom.equalTo(signInView).offset(-15);
    }];
    _calview = [[WHUCalendarView alloc]initWithFrame:CGRectMake(15, signInView.bottom+10, _window_width-30, 290)];
    _calview.isSignIn = signInBtn.selected;
    _calview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_calview];

}

- (void)doSignIn:(UIButton *)sender{
    [MBProgressHUD showMessage:@""];
    [WYToolClass postNetworkWithUrl:@"setSign" andParameter:@{} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                if (code == 200) {
                    LiveUser *userInfo = [[LiveUser alloc] initWithDic:info];
                    [Config updateProfile:userInfo];
                    coinLabel.text = [NSString stringWithFormat:@"积分：%@",[Config getIntegral]];
                    currentImgView.image = [UIImage imageNamed:@"cart_sel"];
                    currentValueL.textColor = normalColors;
                    currentNameL.textColor = normalColors;
                    if (currentLineV) {
                        currentLineV.backgroundColor = normalColors;
                    }
                    sender.selected = YES;
                    sender.userInteractionEnabled = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_calview removeFromSuperview];
                        _calview = nil;
                        _calview = [[WHUCalendarView alloc]initWithFrame:CGRectMake(15, 329 + statusbarHeight, _window_width-30, 290)];
                        _calview.isSignIn = YES;
                        _calview.backgroundColor = [UIColor whiteColor];
                    //        _calview.youkeArray = monthCourseArray;
                        [self.view addSubview:_calview];
                        WYSignINSucessView *view = [[WYSignINSucessView alloc]init];
                        [self.view addSubview:view];
                    });

                }else{
                    [MBProgressHUD showError:msg];
                }

            });

    } fail:^{
        
    }];
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
