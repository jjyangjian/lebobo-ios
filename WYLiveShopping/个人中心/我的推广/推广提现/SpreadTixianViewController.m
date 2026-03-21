//
//  SpreadTixianViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SpreadTixianViewController.h"

@interface SpreadTixianViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>{
    NSMutableArray *viewArray;
    NSMutableArray *imgArray;
    UIView *bankView;
    UIView *otherView;
    UILabel *tipsLabel;
    
    UITextField *bankUserT;
    UITextField *bankNumT;
    UITextField *bankNameT;
    UITextField *bankMoneyT;

    NSArray *extractBank;
    
    UIButton *tixianBtn;
    
    
    UITextField *numTextT;
    UITextField *moneyTextT;
    
    UIView *pickBackView;
    UIView *pickShowView;
    NSInteger selectIndex;

    NSString *extract_type;
    NSString *minPrice;
}

@end

@implementation SpreadTixianViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.returnBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
    self.lineView.hidden = YES;
    self.naviView.image = [UIImage imageNamed:@"button_back"];
    self.titleL.textColor = [UIColor whiteColor];
    self.titleL.text = @"提现";
    viewArray = [NSMutableArray array];
    imgArray = [NSMutableArray array];
    extract_type = @"bank";
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
            [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(btn.width-1, 0, 1, btn.height) andColor:colorf0 andView:btn];
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
        [viewArray addObject:moveView];
        [imgArray addObject:imgBtn];
        
        UIView *lineV = [[UIView alloc]init];
        lineV.backgroundColor = RGB_COLOR(@"#e6352d", 1);
        [btn addSubview:lineV];
        [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.equalTo(btn);
            make.bottom.equalTo(moveView.mas_top);
            make.width.mas_equalTo(1);
        }];
    }
    [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, headerView.bottom, _window_width, 10) andColor:RGB_COLOR(@"#fafafa", 1) andView:self.view];
    bankView = [[UIView alloc]initWithFrame:CGRectMake(0, headerView.bottom + 10, _window_width, 200)];
    [self.view addSubview:bankView];
    NSArray *bankArray = @[@"持卡人",@"卡号",@"银行",@"提现"];
    NSArray *bankPlaceArray = @[@"请输入持卡人姓名",@"请填写卡号",@"请选择银行",@"最低提现金额0"];
    for (int i = 0; i < bankArray.count; i ++) {
        UILabel *label = [[UILabel alloc]init];
        label.text = bankArray[i];
        label.font = SYS_Font(15);
        [bankView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bankView).offset(15);
            make.top.equalTo(bankView).offset(i * 50);
            make.height.mas_equalTo(50);
            make.width.mas_equalTo(90);
        }];
        UITextField *textT = [[UITextField alloc]init];
        textT.placeholder = bankPlaceArray[i];
        textT.font = SYS_Font(15);
        [bankView addSubview:textT];
        [textT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(bankView).offset(-15);
            make.height.centerY.equalTo(label);
            make.left.equalTo(label.mas_right).offset(5);
        }];
        if (i == 2) {
            textT.text = bankPlaceArray[i];
            textT.enabled = NO;
            UIButton *btn = [UIButton buttonWithType:0];
            [btn addTarget:self action:@selector(doSelctedBank) forControlEvents:UIControlEventTouchUpInside];
            [bankView addSubview:btn];
            [btn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.center.width.height.equalTo(textT);
            }];
        }
        switch (i) {
            case 0:
                bankUserT = textT;
            case 1:
                bankNumT = textT;
                break;
            case 2:
                bankNameT = textT;
                break;
            case 3:
                bankMoneyT = textT;
                break;
            default:
                break;
        }
        [[WYToolClass sharedInstance]lineViewWithFrame:CGRectMake(15, (i+1)*50-1, _window_width-30, 1) andColor:colorf0 andView:bankView];
        
    }
    bankNumT.keyboardType = UIKeyboardTypeNumberPad;
    bankMoneyT.keyboardType = UIKeyboardTypeNumberPad;
    bankUserT.keyboardType = UIKeyboardTypeDefault;

    otherView = [[UIView alloc]initWithFrame:CGRectMake(0, headerView.bottom + 10, _window_width, 100)];
    otherView.hidden = YES;
    [self.view addSubview:otherView];
    NSArray *numArray = @[@"账号",@"提现"];
    for (int i = 0; i < numArray.count; i ++) {
        UILabel *label = [[UILabel alloc]init];
        label.text = numArray[i];
        label.font = SYS_Font(15);
        [otherView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(otherView).offset(15);
            make.top.equalTo(otherView).offset(i * 50);
            make.height.mas_equalTo(50);
            make.width.mas_equalTo(90);
        }];
        UITextField *textT = [[UITextField alloc]init];
        textT.font = SYS_Font(15);
        [otherView addSubview:textT];
        [textT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(otherView).offset(-15);
            make.height.centerY.equalTo(label);
            make.left.equalTo(label.mas_right).offset(5);
        }];
        switch (i) {
            case 0:
                numTextT = textT;
            case 1:
                moneyTextT = textT;
                break;
            default:
                break;
        }
        [[WYToolClass sharedInstance]lineViewWithFrame:CGRectMake(15, (i+1)*50-1, _window_width-30, 1) andColor:colorf0 andView:otherView];
    }
    numTextT.keyboardType = UIKeyboardTypeDefault;
    moneyTextT.keyboardType = UIKeyboardTypeNumberPad;
    tipsLabel = [[UILabel alloc]init];
    tipsLabel.font = SYS_Font(13);
    tipsLabel.textColor = color96;
    [self.view addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(bankView.mas_bottom);
        make.height.mas_equalTo(40);
    }];

    tixianBtn = [UIButton buttonWithType:0];
    [tixianBtn setTitle:@"提现" forState:0];
    [tixianBtn setBackgroundColor:normalColors];
    tixianBtn.titleLabel.font = SYS_Font(15);
    tixianBtn.layer.cornerRadius = 20;
    tixianBtn.layer.masksToBounds = YES;
    [tixianBtn addTarget:self action:@selector(doTxian) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tixianBtn];
    [tixianBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLabel.mas_bottom).offset(20);
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
    for (int i = 0; i < viewArray.count; i ++) {
        UIView *moveView = viewArray[i];
        UIButton *imgBtn = imgArray[i];
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
        extract_type = @"bank";
        bankView.hidden = NO;
        otherView.hidden = YES;
        [tipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.top.equalTo(bankView.mas_bottom);
            make.height.mas_equalTo(40);
        }];

    }else{
        bankView.hidden = YES;
        otherView.hidden = NO;
        [tipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.top.equalTo(otherView.mas_bottom);
            make.height.mas_equalTo(40);
        }];
        if (index == 1) {
            extract_type = @"weixin";
            numTextT.placeholder = @"请填写您的微信账号";
        }else{
            extract_type = @"alipay";
            numTextT.placeholder = @"请填写您的支付宝账号";
        }
    }
}


- (void)requestData{
    [WYToolClass getQCloudWithUrl:@"extract/bank" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            extractBank = [info valueForKey:@"extractBank"];
            tipsLabel.text = [NSString stringWithFormat:@"当前可提现金额：%@",minstr([info valueForKey:@"commissionCount"])];
            minPrice = minstr([info valueForKey:@"minPrice"]);
            bankMoneyT.placeholder = [NSString stringWithFormat:@"最低提现金额%@",minstr([info valueForKey:@"minPrice"])];
            moneyTextT.placeholder = [NSString stringWithFormat:@"最低提现金额%@",minstr([info valueForKey:@"minPrice"])];
        }
    } Fail:^{
        
    }];

}
- (void)doSelctedBank{
    [self.view endEditing:YES];

    if (extractBank.count == 0) {
        [self requestData];
    }
    if (!pickBackView) {
        pickBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        pickBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self.view addSubview:pickBackView];
        UIButton *hideBtn = [UIButton buttonWithType:0];
        hideBtn.frame = CGRectMake(0, 0, _window_width, _window_height*0.6);
        [hideBtn addTarget:self action:@selector(hidePicker) forControlEvents:UIControlEventTouchUpInside];
        [pickBackView addSubview:hideBtn];

        pickShowView =  [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, _window_height*0.4)];
        pickShowView.backgroundColor = [UIColor whiteColor];
        [pickBackView addSubview:pickShowView];
       
        UIPickerView *pick = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, _window_width, pickShowView.height-40)];
        pick.backgroundColor = [UIColor whiteColor];
        pick.delegate = self;
        pick.dataSource = self;
        [pickShowView addSubview:pick];
       
        UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 40)];
        titleView.backgroundColor = [UIColor clearColor];
        [pickShowView addSubview:titleView];
        [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 39, _window_width, 1) andColor:colorf0 andView:titleView];
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
    pickBackView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        pickShowView.bottom = _window_height;
    }];
}
- (void)hidePicker{
    [UIView animateWithDuration:0.2 animations:^{
        pickShowView.y = _window_height;
    }completion:^(BOOL finished) {
        pickBackView.hidden = YES;
    }];
}

- (void)cancleOrSure:(UIButton *)button{
    if (button.tag == 100) {
        //        return;
    }else{
        bankNameT.text = extractBank[selectIndex];
    }
    [self hidePicker];
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return extractBank.count;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return extractBank[row];
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:
(NSInteger)row inComponent:(NSInteger)component {
    selectIndex = row;
    
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _window_width, 40)];
    myView.textAlignment = NSTextAlignmentCenter;
    myView.text = extractBank[row];
    myView.textColor = color32;
    myView.font = [UIFont systemFontOfSize:15];
    myView.backgroundColor = [UIColor clearColor];
    [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 39, _window_width, 1) andColor:colorf0 andView:myView];
    return myView;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40.0;
}





- (void)doTxian{
    [self.view endEditing:YES];
    NSDictionary *dic;
    if ([extract_type isEqual:@"bank"]) {
        if (bankUserT.text.length == 0) {
            [MBProgressHUD showError:@"请输入持卡人姓名"];
            return;
        }
        if (bankNumT.text.length == 0) {
            [MBProgressHUD showError:@"请填写卡号"];
            return;
        }
        if ([bankNameT.text isEqual:@"请选择银行"]) {
            [MBProgressHUD showError:@"请选择银行"];
            return;
        }
        if ([bankMoneyT.text intValue] < [minPrice intValue]) {
            [MBProgressHUD showError:bankMoneyT.placeholder];
            return;
        }
        dic = @{
            @"extract_type":extract_type,
            @"money":bankMoneyT.text,
            @"name":bankUserT.text,
            @"bankname":bankNameT.text,
            @"cardnum":bankNumT.text
        };
    }else{// if ([extract_type isEqual:@"wx"])
        if (numTextT.text.length == 0) {
            [MBProgressHUD showError:numTextT.placeholder];
            return;
        }
        if ([moneyTextT.text intValue] < [minPrice intValue]) {
            [MBProgressHUD showError:moneyTextT.placeholder];
            return;
        }
        if ([extract_type isEqual:@"weixin"]){
            dic = @{
                @"extract_type":extract_type,
                @"money":moneyTextT.text,
                @"name":@"",
                @"weixin":numTextT.text,
            };
        }else{
            dic = @{
                @"extract_type":extract_type,
                @"money":moneyTextT.text,
                @"name":@"",
                @"alipay_code":numTextT.text,
            };
        }

    }
    [WYToolClass postNetworkWithUrl:@"extract/cash" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
//            [self requestData];
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
