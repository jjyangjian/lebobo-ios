//
//  SWRegisterAndForgetViewController.m
//  YBEducation
//
//  Created by IOS1 on 2020/2/27.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWRegisterAndForgetViewController.h"
#import "SWAppDelegate.h"
#import "SWTabBarController.h"

@interface SWRegisterAndForgetViewController ()
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *codeTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UITextField *spreadTextField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *codeButton;
@property (nonatomic, strong) NSTimer *messageTimer;
@property (nonatomic, assign) int messageCountdown;
@property (nonatomic, copy) NSString *codeKey;
@end

@implementation SWRegisterAndForgetViewController
- (void)ChangeBtnBackground{
    if (self.nameTextField.text.length == 11 && self.codeTextField.text.length == 6 && self.passwordTextField.text.length >= 6) {
        self.loginButton.alpha = 1;
        self.loginButton.userInteractionEnabled = YES;
    } else {
        self.loginButton.alpha = 0.5;
        self.loginButton.userInteractionEnabled = NO;
    }
    if (self.nameTextField.text.length == 11) {
        [self.codeButton setTitleColor:normalColors forState:0];
        self.codeButton.userInteractionEnabled = YES;
    } else {
        [self.codeButton setTitleColor:RGB_COLOR(@"#c9c9c9", 1) forState:0];
        self.codeButton.userInteractionEnabled = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lineView.hidden = YES;
    [self creatUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeBtnBackground) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)creatUI{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:label];
    NSArray *placeholderArray = [NSArray array];
    if (self.isregister) {
        label.text = @"手机号注册";
        placeholderArray = @[@"请输入您的手机号", @"请输入验证码", @"请设置密码", @"请输入推广人ID（选填）"];
    } else {
        label.text = @"找回密码";
        placeholderArray = @[@"请输入您的手机号", @"请输入验证码", @"请输入重置密码"];
    }
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.view).offset(80);
        make.height.mas_equalTo(30);
    }];

    for (NSInteger i = 0; i < placeholderArray.count; i++) {
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 110 + i * 70, _window_width, 70)];
        [self.view addSubview:containerView];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(25, 30, _window_width - 50, 40)];
        textField.placeholder = placeholderArray[i];
        textField.font = SYS_Font(16);
        [containerView addSubview:textField];
        [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(textField.left, 69, textField.width, 1) andColor:RGB_COLOR(@"#E8E8E8", 1) andView:containerView];
        if (i == 0) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
            self.nameTextField = textField;
        } else if (i == 1) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.width = (_window_width - 50) / 2;
            self.codeTextField = textField;
            self.codeButton = [UIButton buttonWithType:0];
            [self.codeButton setTitle:@"获取验证码" forState:0];
            [self.codeButton setTitleColor:RGB_COLOR(@"#c9c9c9", 1) forState:0];
            self.codeButton.titleLabel.font = SYS_Font(16);
            [self.codeButton addTarget:self action:@selector(requestCodeKey) forControlEvents:UIControlEventTouchUpInside];
            [containerView addSubview:self.codeButton];
            [self.codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(containerView).offset(-25);
                make.bottom.height.equalTo(textField);
            }];
        } else if (i == 2) {
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.secureTextEntry = YES;
            self.passwordTextField = textField;
        } else {
            textField.keyboardType = UIKeyboardTypeNumberPad;
            self.spreadTextField = textField;
        }
    }

    self.loginButton = [UIButton buttonWithType:0];
    if (self.isregister) {
        [self.loginButton setTitle:@"注册" forState:0];
    } else {
        [self.loginButton setTitle:@"登录" forState:0];
    }
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"button_back"] forState:0];
    [self.loginButton addTarget:self action:@selector(doCrontro) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton.frame = CGRectMake(25, 110 + 70 * placeholderArray.count + 30, _window_width - 50, 45);
    self.loginButton.layer.cornerRadius = 22.5;
    self.loginButton.layer.masksToBounds = YES;
    self.loginButton.alpha = 0.5;
    self.loginButton.userInteractionEnabled = NO;
    [self.view addSubview:self.loginButton];
}

- (void)requestCodeKey{
    [MBProgressHUD showMessage:@""];
    WeakSelf;
    [SWToolClass getQCloudWithUrl:@"verify_code" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            weakSelf.codeKey = minstr([info valueForKey:@"key"]);
            [weakSelf getCode];
        }
    } Fail:^{

    }];
}

- (void)getCode{
    self.codeButton.userInteractionEnabled = NO;
    [SWToolClass postNetworkWithUrl:@"register/verify" andParameter:@{@"phone": self.nameTextField.text, @"type": @"register", @"key": self.codeKey} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            if (self.messageTimer == nil) {
                self.messageCountdown = 60;
                self.messageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(daojishi) userInfo:nil repeats:YES];
            }
            [MBProgressHUD showError:msg];
            [self.codeTextField becomeFirstResponder];
        }
    } fail:^{
        self.codeButton.userInteractionEnabled = YES;
    }];
}

- (void)daojishi{
    self.messageCountdown -= 1;
    [self.codeButton setTitle:[NSString stringWithFormat:@"%ds", self.messageCountdown] forState:UIControlStateNormal];
    self.codeButton.userInteractionEnabled = NO;

    if (self.messageCountdown <= 0) {
        [self.codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.codeButton.userInteractionEnabled = YES;
        [self.messageTimer invalidate];
        self.messageTimer = nil;
        self.messageCountdown = 60;
    }
}

- (void)doCrontro{
    [self.view endEditing:YES];
    [MBProgressHUD showMessage:@""];
    NSString *pushid = @"";
    NSString *spreadID = @"";
    if (self.spreadTextField.text != nil && self.spreadTextField.text != NULL && self.spreadTextField.text.length > 0) {
        spreadID = self.spreadTextField.text;
    }
    NSDictionary *loginDictionary = @{
        @"account": self.nameTextField.text,
        @"password": self.passwordTextField.text,
        @"captcha": self.codeTextField.text,
        @"spread": spreadID,
        @"source": @"2",
    };

    [SWToolClass postNetworkWithUrl:self.isregister ? @"register" : @"Login.Forget" andParameter:loginDictionary success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            if (self.block) {
                self.block(self.nameTextField.text, self.codeTextField.text);
            }
            [MBProgressHUD showError:msg];
            [self doReturn];
        } else {
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];

    (void)pushid;
}

- (void)loginSucess{
    [self IMLogin];
    UIApplication *app = [UIApplication sharedApplication];
    SWAppDelegate *app2 = (SWAppDelegate *)app.delegate;
    SWTabBarController *tabbarV = [[SWTabBarController alloc] init];
    app2.window.rootViewController = tabbarV;
}

- (void)IMLogin{

}

@end
