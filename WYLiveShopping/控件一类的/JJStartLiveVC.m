#import "JJStartLiveVC.h"
#import "SWLivebroadViewController.h"
#import "SWApplyShopVC.h"

@interface JJStartLiveVC ()

@property (nonatomic, strong) UIButton *startLiveButton;

@end

@implementation JJStartLiveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"开始直播";
    self.returnBtn.hidden = YES;
    [self buildUI];
    [self updateButtonTitle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self updateButtonTitle];
}

- (void)buildUI {
    self.view.backgroundColor = RGB_COLOR(@"#F7F8FA", 1);

    self.startLiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startLiveButton.backgroundColor = JJAPPTHEMECOLOR;
    self.startLiveButton.layer.cornerRadius = 80;
    self.startLiveButton.layer.masksToBounds = YES;
    self.startLiveButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.startLiveButton.titleLabel.numberOfLines = 2;
    self.startLiveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.startLiveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startLiveButton addTarget:self action:@selector(handleStartLiveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startLiveButton];

    [self.startLiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.mas_equalTo(160);
    }];
}

- (void)updateButtonTitle {
    NSString *buttonTitle = [[SWConfig getIsShop] isEqualToString:@"1"] ? @"开始直播" : @"开通店铺";
    [self.startLiveButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)handleStartLiveAction {
    if (![self ensureLogin]) {
        return;
    }

    if ([[SWConfig getIsShop] isEqualToString:@"1"]) {
        [[SWToolClass sharedInstance] removeSusPlayer];
        SWLivebroadViewController *vc = [[SWLivebroadViewController alloc] init];
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
        return;
    }

    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:@"提示" message:@"你未认证开通店铺，无法进行直播" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [cancleAction setValue:color96 forKey:@"_titleTextColor"];
    [alertContro addAction:cancleAction];

    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"前往认证" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SWApplyShopVC *vc = [[SWApplyShopVC alloc] init];
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }];
    [sureAction setValue:JJAPPTHEMECOLOR forKey:@"_titleTextColor"];
    [alertContro addAction:sureAction];
    [self presentViewController:alertContro animated:YES completion:nil];
}

- (BOOL)ensureLogin {
    if (![SWConfig getOwnID] || [[SWConfig getOwnID] intValue] == 0) {
        [[SWToolClass sharedInstance] showLoginView];
        return NO;
    }
    return YES;
}

@end
