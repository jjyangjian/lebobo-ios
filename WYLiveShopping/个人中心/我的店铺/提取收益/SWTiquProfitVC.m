//
//  myProfitVC.m
//  yunbaolive
//
//  Created by Boom on 2018/9/26.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "SWTiquProfitVC.h"
#import "SWProfitTypeVC.h"

@interface SWTiquProfitVC ()
@property (nonatomic, strong) UILabel *allVotesLabel;
@property (nonatomic, strong) UITextField *votesTextField;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UIButton *inputButton;
@property (nonatomic, strong) NSDictionary *typeDictionary;
@property (nonatomic, strong) UIImageView *selectedTypeImageView;

@end

@implementation SWTiquProfitVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"提取收益";
    self.view.backgroundColor = colorf0;
    [self creatUI];
}

- (void)creatUI {
    UIImageView *backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 64 + statusbarHeight + 7, _window_width - 30, (_window_width - 30) * 0.35)];
    backImgView.image = [UIImage imageNamed:@"profitBg"];
    [self.view addSubview:backImgView];

    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:15];
    label.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    label.text = @"可提取金额";
    [backImgView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgView);
        make.centerY.equalTo(backImgView).multipliedBy(0.6);
    }];

    UILabel *label2 = [[UILabel alloc] init];
    label2.font = SYS_Font(15);
    label2.textColor = [UIColor whiteColor];
    label2.attributedText = [self setAttText:self.moneyStr];
    [backImgView addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgView);
        make.centerY.equalTo(backImgView).multipliedBy(1.32);
    }];
    self.allVotesLabel = label2;

    CGFloat labelWidth = [[SWToolClass sharedInstance] widthOfString:@"输入提取金额" andFont:SYS_Font(13) andHeight:15] + 5;
    UIView *textView = [[UIView alloc] initWithFrame:CGRectMake(backImgView.left, backImgView.bottom + 10, backImgView.width, 50)];
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.cornerRadius = 5.0;
    textView.layer.masksToBounds = YES;
    [self.view addSubview:textView];

    UILabel *leftLabel = [[UILabel alloc] init];
    leftLabel.textColor = color64;
    leftLabel.font = SYS_Font(13);
    leftLabel.text = @"输入提取金额";
    [textView addSubview:leftLabel];
    [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(textView).offset(15);
        make.centerY.equalTo(textView);
        make.width.mas_equalTo(labelWidth);
    }];

    self.votesTextField = [[UITextField alloc] init];
    self.votesTextField.textColor = normalColors;
    self.votesTextField.font = [UIFont boldSystemFontOfSize:18];
    self.votesTextField.placeholder = @"0";
    self.votesTextField.keyboardType = UIKeyboardTypeNumberPad;
    [textView addSubview:self.votesTextField];
    [self.votesTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftLabel.mas_right).offset(20);
        make.centerY.equalTo(textView);
        make.height.equalTo(textView);
        make.right.equalTo(textView).offset(-15);
    }];

    UIView *typeView = [[UIView alloc] initWithFrame:CGRectMake(backImgView.left, textView.bottom + 10, backImgView.width, 50)];
    typeView.backgroundColor = [UIColor whiteColor];
    typeView.layer.cornerRadius = 5.0;
    typeView.layer.masksToBounds = YES;
    [self.view addSubview:typeView];

    self.typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(textView.width * 0.05, 0, typeView.width * 0.95 - 40, 50)];
    self.typeLabel.textColor = color64;
    self.typeLabel.font = SYS_Font(13);
    self.typeLabel.text = @"请选择提现账户";
    [typeView addSubview:self.typeLabel];

    self.selectedTypeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.typeLabel.left, 15, 20, 20)];
    self.selectedTypeImageView.hidden = YES;
    [typeView addSubview:self.selectedTypeImageView];

    UIImageView *rightImgView = [[UIImageView alloc] initWithFrame:CGRectMake(typeView.width - 30, 18, 14, 14)];
    rightImgView.image = [UIImage imageNamed:@"profit_right"];
    rightImgView.userInteractionEnabled = YES;
    [typeView addSubview:rightImgView];

    UIButton *button = [UIButton buttonWithType:0];
    button.frame = CGRectMake(0, 0, typeView.width, typeView.height);
    [button addTarget:self action:@selector(selectPayType) forControlEvents:UIControlEventTouchUpInside];
    [typeView addSubview:button];

    self.inputButton = [UIButton buttonWithType:0];
    self.inputButton.frame = CGRectMake(15, typeView.bottom + 55, _window_width - 30, 40);
    [self.inputButton setBackgroundColor:normalColors];
    [self.inputButton setTitle:@"立即提现" forState:0];
    [self.inputButton addTarget:self action:@selector(inputBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.inputButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.inputButton.layer.cornerRadius = 20;
    self.inputButton.layer.masksToBounds = YES;
    [self.view addSubview:self.inputButton];
}

- (NSAttributedString *)setAttText:(NSString *)nums {
    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc] initWithString:nums];
    [muStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25] range:NSMakeRange(0, [nums rangeOfString:@"."].location)];
    return muStr;
}

- (void)selectPayType {
    SWProfitTypeVC *vc = [[SWProfitTypeVC alloc] init];
    if (self.typeDictionary) {
        vc.selectID = minstr([self.typeDictionary valueForKey:@"id"]);
    } else {
        vc.selectID = @"未选择提现方式";
    }
    vc.block = ^(NSDictionary * _Nonnull dic) {
        self.typeDictionary = dic;
        self.selectedTypeImageView.hidden = NO;
        self.typeLabel.x = self.selectedTypeImageView.right + 5;
        int type = [minstr([dic valueForKey:@"type"]) intValue];
        switch (type) {
            case 1:
                self.selectedTypeImageView.image = [UIImage imageNamed:@"profit_alipay"];
                self.typeLabel.text = [NSString stringWithFormat:@"%@(%@)", minstr([dic valueForKey:@"account"]), minstr([dic valueForKey:@"name"])];
                break;
            case 2:
                self.selectedTypeImageView.image = [UIImage imageNamed:@"profit_wx"];
                self.typeLabel.text = [NSString stringWithFormat:@"%@", minstr([dic valueForKey:@"account"])];
                break;
            case 3:
                self.selectedTypeImageView.image = [UIImage imageNamed:@"profit_card"];
                self.typeLabel.text = [NSString stringWithFormat:@"%@(%@)", minstr([dic valueForKey:@"account"]), minstr([dic valueForKey:@"name"])];
                break;
            default:
                break;
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputBtnClick {
    if (!self.votesTextField.text || [self.votesTextField.text integerValue] <= 0) {
        [MBProgressHUD showError:@"请输入要提取的金额"];
        return;
    }
    if (!self.typeDictionary) {
        [MBProgressHUD showError:@"请选择提现账号"];
        return;
    }
    NSDictionary *dic = @{@"accountid": minstr([self.typeDictionary valueForKey:@"id"]), @"money": self.votesTextField.text};
    NSString *url;
    if (self.ptofitType == 0) {
        url = @"cashbring";
    } else if (self.ptofitType == 1) {
        url = @"cashshop";
    } else if (self.ptofitType == 2) {
        url = @"cashshop";
    }

    [SWToolClass postNetworkWithUrl:url andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [MBProgressHUD showError:msg];
            [self doReturn];
        }
    } fail:^{
    }];
}

@end
