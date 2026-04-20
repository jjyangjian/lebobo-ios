//
//  SWProfitVC.m
//  WYLiveShopping
//
//  Created by apple on 2020/8/15.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWProfitVC.h"
#import "SWProfitTypeVC.h"
@interface SWProfitVC ()
@property (nonatomic, strong) UILabel *allVotesLabel;
@property (nonatomic, strong) UILabel *nowVotesLabel;
@property (nonatomic, strong) UITextField *votesTextField;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, assign) CGFloat cashRate;
@property (nonatomic, strong) UIButton *inputButton;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) NSDictionary *typeDictionary;
@property (nonatomic, strong) UIImageView *selectedTypeImageView;

@end

@implementation SWProfitVC

- (void)addBtnClick:(UIButton *)sender{
    SWWebViewController *web = [[SWWebViewController alloc]init];
    web.urls = [NSString stringWithFormat:@"%@/Appapi/cash/index?uid=%@&token=%@",h5url,[SWConfig getOwnID],[SWConfig getOwnToken]];
    [self.navigationController pushViewController:web animated:YES];
}

- (void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB_COLOR(@"#f4f5f6", 1);
    self.titleL.text = @"礼物收益";
    [self creatUI];
    [self requestData];
}

- (void)requestData{
    [SWToolClass getQCloudWithUrl:@"votes" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.nowVotesLabel.text = [NSString stringWithFormat:@"%@", [info valueForKey:@"votes"]];
            self.allVotesLabel.text = [NSString stringWithFormat:@"%@", [info valueForKey:@"votestotal"]];
            self.cashRate = [minstr([info valueForKey:@"votes_per"]) floatValue];

            NSString *tips = minstr([info valueForKey:@"tips"]);
            CGFloat height = [[SWToolClass sharedInstance] heightOfString:tips andFont:[UIFont systemFontOfSize:11] andWidth:_window_width*0.7-30];
            self.tipsLabel.text = tips;
            self.tipsLabel.height = height;
            NSLog(@"收益数据........%@",info);
        }
    } Fail:^{

    }];
}

- (void)tapClick{
    [self.votesTextField resignFirstResponder];
}

- (void)creatUI{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [self.view addGestureRecognizer:tap];

    UIImageView *backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width*0.04, 64+statusbarHeight+10, _window_width*0.92, _window_width*0.92*24/69)];
    backImgView.image = [UIImage imageNamed:@"profitBg"];
    [self.view addSubview:backImgView];

    for (int i = 0; i < 4; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(backImgView.width/2*(i%2), backImgView.height/4*(i/2+1), backImgView.width/2, backImgView.height/4)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        if (i<2) {
            label.font = [UIFont systemFontOfSize:15];
            if (i == 0) {
                label.text = [NSString stringWithFormat:@"%@%@%@",@"总",[SWCommon name_votes],@"数"];
            }else{
                label.text = [NSString stringWithFormat:@"%@%@%@",@"可提取",[SWCommon name_votes],@"数"];
                [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(backImgView.width/2-0.5, backImgView.height/4, 1, backImgView.height/2) andColor:[UIColor whiteColor] andView:backImgView];
            }
        }else{
            label.font = [UIFont boldSystemFontOfSize:22];
            label.text = @"0";
            if (i == 2) {
                self.allVotesLabel = label;
            }else{
                self.nowVotesLabel = label;
            }
        }
        [backImgView addSubview:label];
    }

    UIView *textView = [[UIView alloc]initWithFrame:CGRectMake(backImgView.left, backImgView.bottom+10, backImgView.width, backImgView.height)];
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.cornerRadius = 5.0;
    textView.layer.masksToBounds = YES;
    [self.view addSubview:textView];
    NSArray *arr = @[[NSString stringWithFormat:@"%@%@%@",@"输入要提取的",[SWCommon name_votes],@"数"],@"可到账金额"];
    for (int i = 0; i < 2; i++) {
        CGFloat labelW = [[SWToolClass sharedInstance] widthOfString:arr[i] andFont:[UIFont systemFontOfSize:15] andHeight:textView.height/2];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(textView.width*0.05, textView.height/2*i, labelW+20, textView.height/2)];
        label.textColor = RGB_COLOR(@"#333333", 1);
        label.font = [UIFont systemFontOfSize:15];
        label.text = arr[i];
        [textView addSubview:label];
        if (i == 0) {
            [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(textView.width*0.05, textView.height/2-0.5, textView.width*0.9, 1) andColor:RGB_COLOR(@"#f4f5f6", 1) andView:textView];
            self.votesTextField = [[UITextField alloc]initWithFrame:CGRectMake(label.right, 0, textView.width*0.95-label.right, textView.height/2)];
            self.votesTextField.textColor = normalColors;
            self.votesTextField.font = [UIFont boldSystemFontOfSize:17];
            self.votesTextField.placeholder = @"0";
            self.votesTextField.keyboardType = UIKeyboardTypeNumberPad;
            [textView addSubview:self.votesTextField];
        }else{
            self.moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right, label.top, textView.width*0.95-label.right, textView.height/2)];
            self.moneyLabel.textColor = [UIColor redColor];
            self.moneyLabel.font = [UIFont boldSystemFontOfSize:17];
            self.moneyLabel.text = @"¥0";
            [textView addSubview:self.moneyLabel];
        }
    }

    UIView *typeView = [[UIView alloc]initWithFrame:CGRectMake(backImgView.left, textView.bottom+10, backImgView.width, 50)];
    typeView.backgroundColor = [UIColor whiteColor];
    typeView.layer.cornerRadius = 5.0;
    typeView.layer.masksToBounds = YES;
    [self.view addSubview:typeView];
    self.typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(textView.width*0.05, 0, typeView.width*0.95-40, 50)];
    self.typeLabel.textColor = RGB_COLOR(@"#333333", 1);
    self.typeLabel.font = [UIFont systemFontOfSize:15];
    self.typeLabel.text = @"请选择提现账户";
    [typeView addSubview:self.typeLabel];
    self.selectedTypeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.typeLabel.left, 15, 20, 20)];
    self.selectedTypeImageView.hidden = YES;
    [typeView addSubview:self.selectedTypeImageView];

    UIImageView *rightImgView = [[UIImageView alloc]initWithFrame:CGRectMake(typeView.width-30, 18, 14, 14)];
    rightImgView.image = [UIImage imageNamed:@"person_right"];
    rightImgView.userInteractionEnabled = YES;
    [typeView addSubview:rightImgView];

    UIButton *btn = [UIButton buttonWithType:0];
    btn.frame = CGRectMake(0, 0, typeView.width, typeView.height);
    [btn addTarget:self action:@selector(selectPayType) forControlEvents:UIControlEventTouchUpInside];
    [typeView addSubview:btn];

    self.inputButton = [UIButton buttonWithType:0];
    self.inputButton.frame = CGRectMake(_window_width*0.15, typeView.bottom + 30, _window_width*0.7, 30);
    [self.inputButton setBackgroundColor:RGB_COLOR(@"#dcdcdc", 1)];
    [self.inputButton setTitle:@"立即提现" forState:0];
    [self.inputButton addTarget:self action:@selector(inputButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.inputButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.inputButton.layer.cornerRadius = 15;
    self.inputButton.layer.masksToBounds = YES;
    self.inputButton.userInteractionEnabled = NO;
    [self.view addSubview:self.inputButton];

    self.tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.inputButton.left+15, self.inputButton.bottom + 15, self.inputButton.width-30, 100)];
    self.tipsLabel.font = [UIFont systemFontOfSize:11];
    self.tipsLabel.textColor = RGB_COLOR(@"#666666", 1);
    self.tipsLabel.numberOfLines = 0;
    [self.view addSubview:self.tipsLabel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeMoenyLabelValue) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)selectPayType{
    SWProfitTypeVC *vc = [[SWProfitTypeVC alloc]init];
    if (self.typeDictionary) {
        vc.selectID = minstr([self.typeDictionary valueForKey:@"id"]);
    }else{
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
                self.typeLabel.text = [NSString stringWithFormat:@"%@(%@)",minstr([dic valueForKey:@"account"]),minstr([dic valueForKey:@"name"])];
                break;
            case 2:
                self.selectedTypeImageView.image = [UIImage imageNamed:@"profit_wx"];
                self.typeLabel.text = [NSString stringWithFormat:@"%@",minstr([dic valueForKey:@"account"])];
                break;
            case 3:
                self.selectedTypeImageView.image = [UIImage imageNamed:@"profit_card"];
                self.typeLabel.text = [NSString stringWithFormat:@"%@(%@)",minstr([dic valueForKey:@"account"]),minstr([dic valueForKey:@"name"])];
                break;
            default:
                break;
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputButtonClick{
    if (!self.typeDictionary) {
        [MBProgressHUD showError:@"请选择提现账号"];
        return;
    }
    NSDictionary *dic = @{@"accountid":minstr([self.typeDictionary valueForKey:@"id"]),@"money":self.votesTextField.text};
    [SWToolClass postNetworkWithUrl:@"cashvotes" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            self.votesTextField.text = @"";
            [MBProgressHUD showError:msg];
            [self requestData];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{

    }];
}

- (void)ChangeMoenyLabelValue{
    if (self.cashRate == 0) {
        return;
    }
    self.moneyLabel.text = [NSString stringWithFormat:@"¥%d", (int)([self.votesTextField.text integerValue] / self.cashRate)];
    if ([[NSString stringWithFormat:@"%d", (int)([self.votesTextField.text integerValue] / self.cashRate)] integerValue] > 0) {
        self.inputButton.userInteractionEnabled = YES;
        [self.inputButton setBackgroundColor:normalColors];
    }else{
        self.inputButton.userInteractionEnabled = NO;
        [self.inputButton setBackgroundColor:RGB_COLOR(@"#dcdcdc", 1)];
    }
}

@end
