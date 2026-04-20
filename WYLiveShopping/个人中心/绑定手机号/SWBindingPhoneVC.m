//
//  SWBindingPhoneVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWBindingPhoneVC.h"

@interface SWBindingPhoneVC ()
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *codeTextField;
@property (nonatomic, strong) UIButton *codeButton;
@property (nonatomic, copy) NSString *codeKey;
@property (nonatomic, strong) NSTimer *messageTimer;
@property (nonatomic, assign) NSInteger messageCountdown;
@property (nonatomic, copy) NSString *step;

@end

@implementation SWBindingPhoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.returnBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
    self.lineView.hidden = YES;
    self.naviView.image = [UIImage imageNamed:@"button_back"];
    self.titleL.textColor = [UIColor whiteColor];
    self.titleL.text = @"绑定手机号";
    self.codeKey = @"";
    self.step = @"0";
    [self creatUI];
}

- (void)creatUI{
    NSArray *array = @[@"填写手机号",@"填写验证码"];
    for (int i = 0; i < array.count; i ++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom + 20 +i * 60, _window_width, 60)];
        [self.view addSubview:view];
        UITextField *text = [[UITextField alloc]initWithFrame:CGRectMake(25, 20, _window_width-50, 40)];
        text.placeholder = array[i];
        text.font = SYS_Font(16);
        text.keyboardType = UIKeyboardTypeNumberPad;
        [view addSubview:text];
        [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(text.left, 59, text.width, 1) andColor:RGB_COLOR(@"#E8E8E8", 1) andView:view];
        if (i == 0) {
            self.phoneTextField = text;
        }else{
            text.width = (_window_width-50)/2;
            self.codeTextField = text;
            self.codeButton = [UIButton buttonWithType:0];
            [self.codeButton setTitle:@"获取验证码" forState:0];
            [self.codeButton setTitleColor:normalColors forState:0];
            self.codeButton.titleLabel.font = SYS_Font(16);
            [self.codeButton addTarget:self action:@selector(requestCodeKey) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:self.codeButton];
            [self.codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(view).offset(-25);
                make.bottom.height.equalTo(text);
            }];
        }
    }
    UIButton *changeBtn = [UIButton buttonWithType:0];
    [changeBtn setTitle:@"确认绑定" forState:0];
    [changeBtn setBackgroundImage:[UIImage imageNamed:@"button_back"] forState:0];
    [changeBtn addTarget:self action:@selector(doBinding) forControlEvents:UIControlEventTouchUpInside];
    changeBtn.frame = CGRectMake(25, self.naviView.bottom + 20 + 160, _window_width-50, 40);
    changeBtn.layer.cornerRadius = 20;
    changeBtn.layer.masksToBounds = YES;
    changeBtn.clipsToBounds = YES;
    [self.view addSubview:changeBtn];
}

- (void)requestCodeKey{
    [MBProgressHUD showMessage:@""];
    WeakSelf;
    [SWToolClass getQCloudWithUrl:@"verify_code" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.codeKey = minstr([info valueForKey:@"key"]);
            [weakSelf getCode];
        }
    } Fail:^{

    }];
}

- (void)getCode{
    if (self.phoneTextField.text.length == 0) {
        [MBProgressHUD showError:@"请输入手机号"];
        return;
    }

    self.codeButton.userInteractionEnabled = NO;
    [SWToolClass postNetworkWithUrl:@"register/verify" andParameter:@{@"phone":self.phoneTextField.text,@"key":self.codeKey} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {

        if (code == 200) {
            [self.codeTextField becomeFirstResponder];
            if (self.messageTimer == nil) {
                self.messageCountdown = 60;
                self.messageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(daojishi) userInfo:nil repeats:YES];
            }
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        self.codeButton.userInteractionEnabled = YES;
    }];
}

- (void)daojishi{
    self.messageCountdown -= 1;
    [self.codeButton setTitle:[NSString stringWithFormat:@"%lds", (long)self.messageCountdown] forState:UIControlStateNormal];
    self.codeButton.userInteractionEnabled = NO;

    if (self.messageCountdown <= 0) {
        [self.codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.codeButton.userInteractionEnabled = YES;
        [self.messageTimer invalidate];
        self.messageTimer = nil;
        self.messageCountdown = 60;
    }
}

- (void)doBinding{
    [self.view endEditing:YES];
    if (self.phoneTextField.text.length == 0) {
        [MBProgressHUD showError:@"请输入手机号"];
        return;
    }
    if (self.codeTextField.text.length == 0) {
        [MBProgressHUD showError:@"请输入验证码"];
        return;
    }

    [MBProgressHUD showMessage:@""];
    NSDictionary *dic = @{
        @"phone":self.phoneTextField.text,
        @"captcha":self.codeTextField.text,
        @"step":self.step
    };
    [SWToolClass postNetworkWithUrl:@"binding" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            if ([minstr([info valueForKey:@"is_bind"]) isEqual:@"1"]) {
                UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                }];
                [alertContro addAction:cancleAction];
                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"继续绑定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    self.step = @"1";
                    [self doBinding];
                }];
                [sureAction setValue:normalColors forKey:@"_titleTextColor"];
                [alertContro addAction:sureAction];
                [self presentViewController:alertContro animated:YES completion:nil];
            }else{
                [MBProgressHUD showError:msg];
                [self doReturn];
            }
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
