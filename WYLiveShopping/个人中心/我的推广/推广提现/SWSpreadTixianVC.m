//
//  SWSpreadTixianVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWSpreadTixianVC.h"

@interface SWSpreadTixianVC ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) NSMutableArray *viewArray;
@property (nonatomic, strong) NSMutableArray *imageButtonArray;
@property (nonatomic, strong) UIView *bankView;
@property (nonatomic, strong) UIView *otherView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UITextField *bankUserTextField;
@property (nonatomic, strong) UITextField *bankNumberTextField;
@property (nonatomic, strong) UITextField *bankNameTextField;
@property (nonatomic, strong) UITextField *bankMoneyTextField;
@property (nonatomic, strong) NSArray *extractBankArray;
@property (nonatomic, strong) UIButton *withdrawButton;
@property (nonatomic, strong) UITextField *accountTextField;
@property (nonatomic, strong) UITextField *moneyTextField;
@property (nonatomic, strong) UIView *pickerBackgroundView;
@property (nonatomic, strong) UIView *pickerContainerView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) NSString *extractType;
@property (nonatomic, copy) NSString *minPrice;

@end

@implementation SWSpreadTixianVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.returnBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
    self.lineView.hidden = YES;
    self.naviView.image = [UIImage imageNamed:@"button_back"];
    self.titleL.textColor = [UIColor whiteColor];
    self.titleL.text = @"提现";
    self.viewArray = [NSMutableArray array];
    self.imageButtonArray = [NSMutableArray array];
    self.extractType = @"bank";
    [self creatUI];
    [self requestData];
}

- (void)creatUI{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, 65)];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];
    NSArray *array = @[@"银行卡",@"微信",@"支付宝"];
    for (int i = 0; i < array.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(i * _window_width/3, 0, _window_width/3, 65);
        [btn addTarget:self action:@selector(typeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1000 + i;
        [headerView addSubview:btn];
        if (i < 2) {
            [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(btn.width-1, 0, 1, btn.height) andColor:colorf0 andView:btn];
        }
        UIView *moveView = [[UIView alloc]init];
        moveView.userInteractionEnabled = NO;
        [btn addSubview:moveView];
        [moveView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(btn);
            make.width.equalTo(btn);
        }];
        UIButton *imgBtn = [UIButton buttonWithType:0];
        imgBtn.userInteractionEnabled = NO;
        [imgBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-nor",array[i]]] forState:0];
        [imgBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-sel",array[i]]] forState:UIControlStateSelected];
        [moveView addSubview:imgBtn];
        [imgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.equalTo(moveView);
            make.width.height.mas_equalTo(20);
        }];
        UILabel *label = [[UILabel alloc]init];
        label.text = array[i];
        label.textColor = RGB_COLOR(@"#f94347", 1);
        label.font = SYS_Font(13);
        [moveView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.centerX.equalTo(moveView);
            make.top.equalTo(imgBtn.mas_bottom).offset(3);
        }];
        [self.viewArray addObject:moveView];
        [self.imageButtonArray addObject:imgBtn];

        UIView *lineV = [[UIView alloc]init];
        lineV.backgroundColor = RGB_COLOR(@"#e6352d", 1);
        [btn addSubview:lineV];
        [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.equalTo(btn);
            make.bottom.equalTo(moveView.mas_top);
            make.width.mas_equalTo(1);
        }];
    }
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, headerView.bottom, _window_width, 10) andColor:RGB_COLOR(@"#fafafa", 1) andView:self.view];
    self.bankView = [[UIView alloc]initWithFrame:CGRectMake(0, headerView.bottom + 10, _window_width, 200)];
    [self.view addSubview:self.bankView];
    NSArray *bankArray = @[@"持卡人",@"卡号",@"银行",@"提现"];
    NSArray *bankPlaceArray = @[@"请输入持卡人姓名",@"请填写卡号",@"请选择银行",@"最低提现金额0"];
    for (int i = 0; i < bankArray.count; i ++) {
        UILabel *label = [[UILabel alloc]init];
        label.text = bankArray[i];
        label.font = SYS_Font(15);
        [self.bankView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bankView).offset(15);
            make.top.equalTo(self.bankView).offset(i * 50);
            make.height.mas_equalTo(50);
            make.width.mas_equalTo(90);
        }];
        UITextField *textT = [[UITextField alloc]init];
        textT.placeholder = bankPlaceArray[i];
        textT.font = SYS_Font(15);
        [self.bankView addSubview:textT];
        [textT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bankView).offset(-15);
            make.height.centerY.equalTo(label);
            make.left.equalTo(label.mas_right).offset(5);
        }];
        if (i == 2) {
            textT.text = bankPlaceArray[i];
            textT.enabled = NO;
            UIButton *btn = [UIButton buttonWithType:0];
            [btn addTarget:self action:@selector(doSelctedBank) forControlEvents:UIControlEventTouchUpInside];
            [self.bankView addSubview:btn];
            [btn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.center.width.height.equalTo(textT);
            }];
        }
        switch (i) {
            case 0:
                self.bankUserTextField = textT;
                break;
            case 1:
                self.bankNumberTextField = textT;
                break;
            case 2:
                self.bankNameTextField = textT;
                break;
            case 3:
                self.bankMoneyTextField = textT;
                break;
            default:
                break;
        }
        [[SWToolClass sharedInstance]lineViewWithFrame:CGRectMake(15, (i+1)*50-1, _window_width-30, 1) andColor:colorf0 andView:self.bankView];
    }
    self.bankNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.bankMoneyTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.bankUserTextField.keyboardType = UIKeyboardTypeDefault;

    self.otherView = [[UIView alloc]initWithFrame:CGRectMake(0, headerView.bottom + 10, _window_width, 100)];
    self.otherView.hidden = YES;
    [self.view addSubview:self.otherView];
    NSArray *numArray = @[@"账号",@"提现"];
    for (int i = 0; i < numArray.count; i ++) {
        UILabel *label = [[UILabel alloc]init];
        label.text = numArray[i];
        label.font = SYS_Font(15);
        [self.otherView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.otherView).offset(15);
            make.top.equalTo(self.otherView).offset(i * 50);
            make.height.mas_equalTo(50);
            make.width.mas_equalTo(90);
        }];
        UITextField *textT = [[UITextField alloc]init];
        textT.font = SYS_Font(15);
        [self.otherView addSubview:textT];
        [textT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.otherView).offset(-15);
            make.height.centerY.equalTo(label);
            make.left.equalTo(label.mas_right).offset(5);
        }];
        switch (i) {
            case 0:
                self.accountTextField = textT;
                break;
            case 1:
                self.moneyTextField = textT;
                break;
            default:
                break;
        }
        [[SWToolClass sharedInstance]lineViewWithFrame:CGRectMake(15, (i+1)*50-1, _window_width-30, 1) andColor:colorf0 andView:self.otherView];
    }
    self.accountTextField.keyboardType = UIKeyboardTypeDefault;
    self.moneyTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.tipsLabel = [[UILabel alloc]init];
    self.tipsLabel.font = SYS_Font(13);
    self.tipsLabel.textColor = color96;
    [self.view addSubview:self.tipsLabel];
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(self.bankView.mas_bottom);
        make.height.mas_equalTo(40);
    }];

    self.withdrawButton = [UIButton buttonWithType:0];
    [self.withdrawButton setTitle:@"提现" forState:0];
    [self.withdrawButton setBackgroundColor:normalColors];
    self.withdrawButton.titleLabel.font = SYS_Font(15);
    self.withdrawButton.layer.cornerRadius = 20;
    self.withdrawButton.layer.masksToBounds = YES;
    [self.withdrawButton addTarget:self action:@selector(doTxian) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.withdrawButton];
    [self.withdrawButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipsLabel.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(40);
    }];
    [self doSelectedIndex:0];
}

- (void)typeButtonClick:(UIButton *)sender{
    [self.view endEditing:YES];
    int index = (int)sender.tag - 1000;
    [self doSelectedIndex:index];
}

- (void)doSelectedIndex:(int)index{
    for (int i = 0; i < self.viewArray.count; i ++) {
        UIView *moveView = self.viewArray[i];
        UIButton *imgBtn = self.imageButtonArray[i];
        if (i == index) {
            imgBtn.selected = YES;
            [UIView animateWithDuration:0.2 animations:^{
                [moveView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(moveView.superview).offset(10);
                }];
            }];
        }else{
            imgBtn.selected = NO;
            [UIView animateWithDuration:0.2 animations:^{
                [moveView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(moveView.superview);
                }];
            }];
        }
    }
    if (index == 0) {
        self.extractType = @"bank";
        self.bankView.hidden = NO;
        self.otherView.hidden = YES;
        [self.tipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.top.equalTo(self.bankView.mas_bottom);
            make.height.mas_equalTo(40);
        }];
    }else{
        self.bankView.hidden = YES;
        self.otherView.hidden = NO;
        [self.tipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.top.equalTo(self.otherView.mas_bottom);
            make.height.mas_equalTo(40);
        }];
        if (index == 1) {
            self.extractType = @"weixin";
            self.accountTextField.placeholder = @"请填写您的微信账号";
        }else{
            self.extractType = @"alipay";
            self.accountTextField.placeholder = @"请填写您的支付宝账号";
        }
    }
}

- (void)requestData{
    [SWToolClass getQCloudWithUrl:@"extract/bank" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.extractBankArray = [info valueForKey:@"extractBank"];
            self.tipsLabel.text = [NSString stringWithFormat:@"当前可提现金额：%@",minstr([info valueForKey:@"commissionCount"])];
            self.minPrice = minstr([info valueForKey:@"minPrice"]);
            self.bankMoneyTextField.placeholder = [NSString stringWithFormat:@"最低提现金额%@",minstr([info valueForKey:@"minPrice"])];
            self.moneyTextField.placeholder = [NSString stringWithFormat:@"最低提现金额%@",minstr([info valueForKey:@"minPrice"])];
        }
    } Fail:^{

    }];
}

- (void)doSelctedBank{
    [self.view endEditing:YES];

    if (self.extractBankArray.count == 0) {
        [self requestData];
    }
    if (!self.pickerBackgroundView) {
        self.pickerBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        self.pickerBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self.view addSubview:self.pickerBackgroundView];
        UIButton *hideBtn = [UIButton buttonWithType:0];
        hideBtn.frame = CGRectMake(0, 0, _window_width, _window_height*0.6);
        [hideBtn addTarget:self action:@selector(hidePicker) forControlEvents:UIControlEventTouchUpInside];
        [self.pickerBackgroundView addSubview:hideBtn];

        self.pickerContainerView =  [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, _window_height*0.4)];
        self.pickerContainerView.backgroundColor = [UIColor whiteColor];
        [self.pickerBackgroundView addSubview:self.pickerContainerView];

        UIPickerView *pick = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, _window_width, self.pickerContainerView.height-40)];
        pick.backgroundColor = [UIColor whiteColor];
        pick.delegate = self;
        pick.dataSource = self;
        [self.pickerContainerView addSubview:pick];

        UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 40)];
        titleView.backgroundColor = [UIColor clearColor];
        [self.pickerContainerView addSubview:titleView];
        [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 39, _window_width, 1) andColor:colorf0 andView:titleView];
        UIButton *cancleBtn = [UIButton buttonWithType:0];
        cancleBtn.frame = CGRectMake(00, 0, 80, 40);
        cancleBtn.tag = 100;
        cancleBtn.titleLabel.font = SYS_Font(15);
        [cancleBtn setTitle:@"取消" forState:0];
        [cancleBtn setTitleColor:color64 forState:0];
        [cancleBtn addTarget:self action:@selector(cancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:cancleBtn];
        UIButton *sureBtn = [UIButton buttonWithType:0];
        sureBtn.frame = CGRectMake(titleView.width-80, 0, 80, 40);
        sureBtn.tag = 101;
        sureBtn.titleLabel.font = SYS_Font(15);
        [sureBtn setTitle:@"确定" forState:0];
        [sureBtn setTitleColor:normalColors forState:0];
        [sureBtn addTarget:self action:@selector(cancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:sureBtn];
    }
    [self showPicker];
}

- (void)showPicker{
    self.pickerBackgroundView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.pickerContainerView.bottom = _window_height;
    }];
}

- (void)hidePicker{
    [UIView animateWithDuration:0.2 animations:^{
        self.pickerContainerView.y = _window_height;
    }completion:^(BOOL finished) {
        self.pickerBackgroundView.hidden = YES;
    }];
}

- (void)cancleOrSure:(UIButton *)button{
    if (button.tag != 100) {
        self.bankNameTextField.text = self.extractBankArray[self.selectedIndex];
    }
    [self hidePicker];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.extractBankArray.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.extractBankArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedIndex = row;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _window_width, 40)];
    myView.textAlignment = NSTextAlignmentCenter;
    myView.text = self.extractBankArray[row];
    myView.textColor = color32;
    myView.font = [UIFont systemFontOfSize:15];
    myView.backgroundColor = [UIColor clearColor];
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 39, _window_width, 1) andColor:colorf0 andView:myView];
    return myView;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40.0;
}

- (void)doTxian{
    [self.view endEditing:YES];
    NSDictionary *dic;
    if ([self.extractType isEqual:@"bank"]) {
        if (self.bankUserTextField.text.length == 0) {
            [MBProgressHUD showError:@"请输入持卡人姓名"];
            return;
        }
        if (self.bankNumberTextField.text.length == 0) {
            [MBProgressHUD showError:@"请填写卡号"];
            return;
        }
        if ([self.bankNameTextField.text isEqual:@"请选择银行"]) {
            [MBProgressHUD showError:@"请选择银行"];
            return;
        }
        if ([self.bankMoneyTextField.text intValue] < [self.minPrice intValue]) {
            [MBProgressHUD showError:self.bankMoneyTextField.placeholder];
            return;
        }
        dic = @{
            @"extract_type":self.extractType,
            @"money":self.bankMoneyTextField.text,
            @"name":self.bankUserTextField.text,
            @"bankname":self.bankNameTextField.text,
            @"cardnum":self.bankNumberTextField.text
        };
    }else{
        if (self.accountTextField.text.length == 0) {
            [MBProgressHUD showError:self.accountTextField.placeholder];
            return;
        }
        if ([self.moneyTextField.text intValue] < [self.minPrice intValue]) {
            [MBProgressHUD showError:self.moneyTextField.placeholder];
            return;
        }
        if ([self.extractType isEqual:@"weixin"]){
            dic = @{
                @"extract_type":self.extractType,
                @"money":self.moneyTextField.text,
                @"name":@"",
                @"weixin":self.accountTextField.text,
            };
        }else{
            dic = @{
                @"extract_type":self.extractType,
                @"money":self.moneyTextField.text,
                @"name":@"",
                @"alipay_code":self.accountTextField.text,
            };
        }
    }
    [SWToolClass postNetworkWithUrl:@"extract/cash" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [MBProgressHUD showError:msg];
            [self doReturn];
        }
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
