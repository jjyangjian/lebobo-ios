//
//  WYSignINSucessView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYSignINSucessView.h"

@implementation WYSignINSucessView

-(instancetype)init{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, _window_width, _window_height);
        self.backgroundColor = RGB_COLOR(@"#000000", 0.2);
        [self creatUI];
    }
    return self;
}
- (void)creatUI{
    UIView *showView = [[UIView alloc]init];
    showView.backgroundColor = [UIColor clearColor];
    [self addSubview:showView];
    [showView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).multipliedBy(0.92);
        make.width.mas_equalTo(210);
        make.height.mas_equalTo(165);
    }];
    UIView *whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, 25, 210, 140)];
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.layer.cornerRadius = 11;
    [showView addSubview:whiteView];
    
    UILabel *tipsL = [[UILabel alloc]init];
    tipsL.text = @"赠送的积分已发到您的账户中";
    tipsL.font = SYS_Font(10);
    tipsL.textColor = color64;
    [whiteView addSubview:tipsL];
    [tipsL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(whiteView);
        make.bottom.equalTo(whiteView.mas_centerY);
    }];
    
    UIButton *sureBtn = [UIButton buttonWithType:0];
    [sureBtn setTitle:@"我知道了" forState:0];
    sureBtn.titleLabel.font = SYS_Font(14);
    [sureBtn setBackgroundColor:normalColors];
    [sureBtn setCornerRadius:15];
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(whiteView);
        make.bottom.equalTo(whiteView).offset(-26);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
    }];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 210, 60)];
    imageView.image = [UIImage imageNamed:@"sign-sucs-header"];
    [showView addSubview:imageView];
}
- (void)sureBtnClick{
    self.hidden = YES;
    [self removeFromSuperview];
}
@end
