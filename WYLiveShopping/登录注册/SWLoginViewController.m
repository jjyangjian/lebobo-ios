//
//  YBLoginViewController.m
//  YBEducation
//
//  Created by IOS1 on 2020/2/21.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWLoginViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "SWAppDelegate.h"
#import "SWTabBarController.h"
#import "SWLogInCodePutView.h"
#import "SWLoginPwdPutView.h"
#import "SWRegisterAndForgetViewController.h"
#import "SBJson.h"
#import <AuthenticationServices/AuthenticationServices.h>
#import "SWLivebroadViewController.h"

@interface SWLoginViewController ()<ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>
@property (nonatomic, strong) UIButton *codeButton;
@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UIButton *loginCodeButton;
@property (nonatomic, strong) UIButton *loginPhoneButton;
@property (nonatomic, strong) SWLogInCodePutView *codeLoginView;
@property (nonatomic, strong) SWLoginPwdPutView *passwordLoginView;
@property (nonatomic, strong) NSArray *platformsArray;
@end

@implementation SWLoginViewController
- (void)doReturn{
    if (self.isquitLogin) {
        [self loginSucess];
    } else {
        [super doReturn];
    }
}

- (void)viewWillAppear:(BOOL)animated{
}

- (void)rightBtnClick{
    SWRegisterAndForgetViewController *vc = [[SWRegisterAndForgetViewController alloc] init];
    vc.isregister = YES;
    vc.block = ^(NSString * _Nonnull phone, NSString * _Nonnull code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.codeLoginView.nameT.text = phone;
            self.codeLoginView.pwdT.text = code;
            [self.codeLoginView ChangeBtnBackground];
        });
    };
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)itemBtnClick:(UIButton *)sender{
    sender.titleLabel.font = [UIFont boldSystemFontOfSize:24];

    if (sender == self.codeButton) {
        self.codeButton.selected = YES;
        self.phoneButton.selected = NO;
        self.phoneButton.titleLabel.font = SYS_Font(15);
        self.codeLoginView.hidden = NO;
        self.passwordLoginView.hidden = YES;
    } else {
        self.codeButton.selected = NO;
        self.codeButton.titleLabel.font = SYS_Font(15);
        self.phoneButton.selected = YES;
        self.codeLoginView.hidden = YES;
        self.passwordLoginView.hidden = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.returnBtn setImage:[UIImage imageNamed:@"login_exit"] forState:0];
    [self.rightBtn setTitle:@"注册" forState:0];
    [self.rightBtn setTitleColor:color64 forState:0];
    self.returnBtn.hidden = YES;
    self.rightBtn.hidden = NO;
    self.lineView.hidden = YES;
    self.naviView.backgroundColor = [UIColor clearColor];

    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    backImageView.image = [UIImage imageNamed:@"login_back"];
    backImageView.contentMode = UIViewContentModeScaleAspectFill;
    backImageView.clipsToBounds = YES;
    [self.view addSubview:backImageView];
    [self.view sendSubviewToBack:backImageView];

    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, IS_IPHONE_5 ? 48 : (98 + statusbarHeight), 60, 60)];
    logoImageView.image = [UIImage imageNamed:@"login_logo"];
    [self.view addSubview:logoImageView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"欢迎体验播播乐";
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(logoImageView);
        make.top.equalTo(logoImageView.mas_bottom).offset(20);
    }];

    WeakSelf;
    self.codeLoginView = [[SWLogInCodePutView alloc] initWithFrame:CGRectMake(0, logoImageView.bottom + 65, _window_width, 200)];
    self.codeLoginView.block = ^{
        [weakSelf loginSucess];
    };
    [self.view addSubview:self.codeLoginView];

    UIButton *agreementButton = [UIButton buttonWithType:0];
    agreementButton.titleLabel.font = SYS_Font(10);
    [agreementButton setTitleColor:color64 forState:0];
    NSString *agreementString = @"登录即代表你已同意《用户协议》";
    NSRange range = NSMakeRange(9, 6);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:agreementString];
    [attributedString addAttribute:NSForegroundColorAttributeName value:normalColors range:range];
    [agreementButton setAttributedTitle:attributedString forState:0];
    [agreementButton addTarget:self action:@selector(doXieyi) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agreementButton];
    [agreementButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(25 + ShowDiff));
        make.height.mas_equalTo(20);
    }];

    AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
    [netManager startMonitoring];
    [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        if (status == AFNetworkReachabilityStatusNotReachable) {
        } else if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"nonetwork-------");
        } else if ((status == AFNetworkReachabilityStatusReachableViaWWAN) || (status == AFNetworkReachabilityStatusReachableViaWiFi)) {
            NSLog(@"wifi-------");
        }
    }];
    self.platformsArray = @[@"wx"];
    [self creatThirdLog];
}

- (void)creatThirdLog{
    if (self.platformsArray.count == 0) {
        return;
    }
    CGFloat jianju = (_window_width - 30 - self.platformsArray.count * 60) / (self.platformsArray.count + 1);
    for (NSInteger i = 0; i < self.platformsArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:0];
        [button setTitle:self.platformsArray[i] forState:0];
        [button setTitleColor:[UIColor clearColor] forState:0];
        [button addTarget:self action:@selector(thirdLogTypeClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-(75 + ShowDiff));
            make.height.width.mas_equalTo(60);
            make.left.equalTo(self.view).offset(15 + jianju + i * (60 + jianju));
        }];

        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"login_%@", self.platformsArray[i]]];
        [button addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.equalTo(button);
            make.width.height.mas_equalTo(40);
            make.right.lessThanOrEqualTo(button.mas_right);
            make.left.greaterThanOrEqualTo(button.mas_left);
        }];

        UILabel *label = [[UILabel alloc] init];
        label.font = SYS_Font(10);
        label.textColor = color64;
        [button addSubview:label];
        if ([self.platformsArray[i] isEqual:@"wx"]) {
            label.text = @"微信登录";
        } else if ([self.platformsArray[i] isEqual:@"QQ"]) {
            label.text = @"QQ登录";
        } else if ([self.platformsArray[i] isEqual:@"apple"]) {
            label.text = @"Apple登录";
        }
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.lessThanOrEqualTo(button.mas_right);
            make.left.greaterThanOrEqualTo(button.mas_left);
            make.bottom.centerX.equalTo(button);
        }];
    }
}

- (void)thirdLogTypeClick:(UIButton *)sender{
    if ([sender.titleLabel.text isEqual:@"Facebook"]) {
        [self login:@"4" platforms:SSDKPlatformTypeFacebook];
    } else if ([sender.titleLabel.text isEqual:@"Twitter"]) {
        [self login:@"5" platforms:SSDKPlatformTypeTwitter];
    } else if ([sender.titleLabel.text isEqual:@"QQ"]) {
        [ShareSDK cancelAuthorize:SSDKPlatformTypeQQ result:^(NSError *error) {
        }];
        [self login:@"1" platforms:SSDKPlatformTypeQQ];
    } else if ([sender.titleLabel.text isEqual:@"wx"]) {
        [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat result:^(NSError *error) {
        }];
        [self login:@"wx" platforms:SSDKPlatformTypeWechat];
    } else if ([sender.titleLabel.text isEqual:@"weibo"]) {
        [self login:@"3" platforms:SSDKPlatformTypeSinaWeibo];
    } else if ([sender.titleLabel.text isEqual:@"apple"]) {
        [self login:@"apple" platforms:SSDKPlatformTypeAppleAccount];
    }
}

- (void)login:(NSString *)types platforms:(SSDKPlatformType)platform{
    [ShareSDK getUserInfo:platform onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess) {
            NSLog(@"uid=%@", user.uid);
            NSLog(@"%@", user.credential);
            NSLog(@"token=%@", user.credential.token);
            NSLog(@"nickname=%@", user.nickname);
            [self RequestLogin:user LoginType:types];
        } else if (state == 2 || state == 3) {
            if ([types isEqual:@"apple"]) {
                if ([UIDevice currentDevice].systemVersion.floatValue < 13) {
                    [MBProgressHUD showError:@"ios13以下系统暂不支持苹果登录"];
                }
            }
        }
    }];
}

- (void)RequestLogin:(SSDKUser *)user LoginType:(NSString *)LoginType{
    [MBProgressHUD showMessage:@""];
    NSString *icon = nil;
    if ([LoginType isEqualToString:@"1"]) {
        icon = [user.rawData valueForKey:@"figureurl_qq_2"];
    } else {
        icon = user.icon;
    }

    NSString *unionID = [NSString string];
    if ([LoginType isEqualToString:@"1"]) {
        NSString *url1 = [NSString stringWithFormat:@"https://graph.qq.com/oauth2.0/me?access_token=%@&unionid=1", user.credential.token];
        url1 = [url1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url1] encoding:NSUTF8StringEncoding error:nil];
        NSRange rang1 = [str rangeOfString:@"{"];
        NSString *str2 = [str substringFromIndex:rang1.location];
        NSRange rang2 = [str2 rangeOfString:@")"];
        NSString *str3 = [str2 substringToIndex:rang2.location];
        NSString *str4 = [str3 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSData *data = [str4 dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [data JSONValue];
        unionID = [dic valueForKey:@"unionid"];
    } else if ([LoginType isEqualToString:@"wx"]) {
        unionID = [user.rawData valueForKey:@"unionid"];
    } else {
        unionID = user.uid;
    }
    if (!icon || !unionID) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"未获取到授权，请重试"];
        return;
    }
    NSDictionary *signDic = @{
        @"openid": minstr([user.rawData valueForKey:@"openid"]),
        @"type": [NSString stringWithFormat:@"%@", [self encodeString:LoginType]],
    };
    NSString *signStr = [SWToolClass sortString:signDic];
    NSString *pushid = @"";

    NSDictionary *parameterDictionary = @{
        @"openid": minstr([user.rawData valueForKey:@"openid"]),
        @"unionid": [NSString stringWithFormat:@"%@", unionID],
        @"type": [NSString stringWithFormat:@"%@", [self encodeString:LoginType]],
        @"nickname": [NSString stringWithFormat:@"%@", [self encodeString:user.nickname]],
        @"avatar": [NSString stringWithFormat:@"%@", [self encodeString:icon]],
        @"gender": [NSString stringWithFormat:@"%ld", user.gender],
        @"sign": signStr,
        @"source": @"2",
        @"pushid": pushid
    };
    [SWToolClass postNetworkWithUrl:@"thirdlogin" andParameter:parameterDictionary success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            NSString *token = minstr([info valueForKey:@"token"]);
            [SWConfig saveOwnToken:token];
            NSString *usersig = minstr([info valueForKey:@"usersig"]);
            [SWConfig saveOwnUserTXIMSign:usersig];
            [self getUserInfo:token];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
}

- (void)getUserInfo:(NSString *)token{
    [SWToolClass getQCloudWithUrl:@"userinfo" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            SWLiveUser *userInfo = [[SWLiveUser alloc] initWithDic:info];
            [SWConfig saveProfile:userInfo];
            [self loginSucess];
        }
    } Fail:^{

    }];
}

- (NSString *)encodeString:(NSString *)unencodedString{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                   (CFStringRef)unencodedString,
                                                                                                   NULL,
                                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                   kCFStringEncodingUTF8));
    return encodedString;
}

- (void)loginSucess{
    UIApplication *app = [UIApplication sharedApplication];
    SWAppDelegate *app2 = (SWAppDelegate *)app.delegate;
    app2.window.rootViewController = nil;
    SWTabBarController *tabbarV = [[SWTabBarController alloc] init];
    app2.window.rootViewController = tabbarV;
}

- (void)IMLogin{
    [[TUIKit sharedInstance] login:[SWConfig getOwnID] userSig:[SWConfig getOwnUserTXIMSign] succ:^{
        NSLog(@"IM登录成功");
    } fail:^(int code, NSString *msg) {
        NSLog(@"IM登录失败 \n code=%d \n msg=%@", code, msg);
    }];
}

- (void)doXieyi{
    SWWebViewController *web = [[SWWebViewController alloc] init];
    web.urls = [NSString stringWithFormat:@"%@/appapi/page/detail?id=2", h5url];
    [[SWMXBADelegate sharedAppDelegate] pushViewController:web animated:YES];
}

- (void)configUI{
}

- (void)appleClick API_AVAILABLE(ios(13.0)){
    ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
    ASAuthorizationAppleIDRequest *request = [appleIDProvider createRequest];
    request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
    ASAuthorizationController *auth = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
    auth.delegate = self;
    auth.presentationContextProvider = self;
    [auth performRequests];
}

- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller API_AVAILABLE(ios(13.0)){
    return self.view.window;
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)){
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        ASAuthorizationAppleIDCredential *apple = authorization.credential;
        NSString *userIdentifier = apple.user;
        NSPersonNameComponents *fullName = apple.fullName;
        NSString *email = apple.email;
        NSData *identityToken = apple.identityToken;
        NSLog(@"%@%@%@%@", userIdentifier, fullName, email, identityToken);
    } else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
        ASPasswordCredential *pass = authorization.credential;
        NSString *username = pass.user;
        NSString *passw = pass.password;
        (void)username;
        (void)passw;
    }
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)){
    NSLog(@"%@", error);
}

@end
