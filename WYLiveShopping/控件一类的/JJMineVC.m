#import "JJMineVC.h"
#import "SWMineSettingVC.h"
#import "SWEditMsgVC.h"

static NSString * const JJMineProfileCellId = @"JJMineProfileCell";
static NSString * const JJMineMenuCellId = @"JJMineMenuCell";

typedef NS_ENUM(NSInteger, JJMineMenuType) {
    JJMineMenuTypeAbout = 0,
    JJMineMenuTypeSetting,
    JJMineMenuTypeService,
};

@interface JJMineVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *userIdLabel;
@property (nonatomic, strong) NSArray<NSString *> *menuList;
@property (nonatomic, copy) NSString *serviceURL;

@end

@implementation JJMineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"我的";
    self.returnBtn.hidden = YES;
    self.menuList = @[@"关于乐播播", @"设置", @"联系客服"];
    [self buildUI];
    [self setupDefaultUserInfo];
    [self requestUserInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self refreshUserInfoIfNeeded];
}

- (void)buildUI {
    self.view.backgroundColor = RGB_COLOR(@"#ECECEC", 1);

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = RGB_COLOR(@"#ECECEC", 1);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.alwaysBounceVertical = YES;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.sectionFooterHeight = 0.001;
    self.tableView.sectionHeaderHeight = 0.001;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:JJMineProfileCellId];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:JJMineMenuCellId];
    [self.view addSubview:self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.naviView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)setupDefaultUserInfo {
    self.avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.avatarButton.layer.cornerRadius = 32;
    self.avatarButton.layer.masksToBounds = YES;
    self.avatarButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.avatarButton addTarget:self action:@selector(openEditProfile) forControlEvents:UIControlEventTouchUpInside];
    [self.avatarButton sd_setImageWithURL:[NSURL URLWithString:[SWConfig getavatar]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"mine_默认头像"]];

    self.nicknameLabel = [[UILabel alloc] init];
    self.nicknameLabel.font = [UIFont boldSystemFontOfSize:18];
    self.nicknameLabel.textColor = color32;
    self.nicknameLabel.text = [SWConfig getOwnNicename];

    self.userIdLabel = [[UILabel alloc] init];
    self.userIdLabel.font = SYS_Font(13);
    self.userIdLabel.textColor = color64;
    self.userIdLabel.text = [self displayUserIdText:[SWConfig getOwnID]];

    self.serviceURL = @"";
}

- (void)refreshUserInfoIfNeeded {
    if (![SWConfig getOwnID] || [[SWConfig getOwnID] intValue] == 0) {
        [self.avatarButton setImage:[UIImage imageNamed:@"mine_默认头像"] forState:UIControlStateNormal];
        self.nicknameLabel.text = @"";
        self.userIdLabel.text = @"ID:";
        self.serviceURL = @"";
        [self.tableView reloadData];
        return;
    }
    [self requestUserInfo];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : self.menuList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? 96 : 62;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0.001 : 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = RGB_COLOR(@"#ECECEC", 1);
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JJMineProfileCellId forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryView = nil;

        if (!self.avatarButton.superview) {
            [cell.contentView addSubview:self.avatarButton];
            [cell.contentView addSubview:self.nicknameLabel];
            [cell.contentView addSubview:self.userIdLabel];

            [self.avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(cell.contentView).offset(15);
                make.centerY.equalTo(cell.contentView);
                make.width.height.mas_equalTo(64);
            }];

            [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.avatarButton.mas_right).offset(15);
                make.right.lessThanOrEqualTo(cell.contentView).offset(-15);
                make.bottom.equalTo(self.avatarButton.mas_centerY).offset(-4);
            }];

            [self.userIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.nicknameLabel);
                make.top.equalTo(self.nicknameLabel.mas_bottom).offset(8);
                make.right.lessThanOrEqualTo(cell.contentView).offset(-15);
            }];
        }
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JJMineMenuCellId forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    cell.textLabel.text = self.menuList[indexPath.row];
    cell.textLabel.font = SYS_Font(16);
    cell.textLabel.textColor = color32;
    cell.detailTextLabel.text = @"";
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryImage"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self openEditProfile];
        return;
    }

    switch (indexPath.row) {
        case JJMineMenuTypeAbout:
            [self openAboutPage];
            break;
        case JJMineMenuTypeSetting:
            [self openSettingPage];
            break;
        case JJMineMenuTypeService:
            [self openServicePage];
            break;
        default:
            break;
    }
}

- (void)openEditProfile {
    if (![self ensureLogin]) {
        return;
    }
    SWEditMsgVC *vc = [[SWEditMsgVC alloc] init];
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)openAboutPage {
    SWWebViewController *web = [[SWWebViewController alloc] init];
    web.urls = [NSString stringWithFormat:@"%@//appapi/page/detail?id=1", h5url];
    [[SWMXBADelegate sharedAppDelegate] pushViewController:web animated:YES];
}

- (void)openSettingPage {
    if (![self ensureLogin]) {
        return;
    }
    SWMineSettingVC *vc = [[SWMineSettingVC alloc] init];
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)openServicePage {
    if (![self ensureLogin]) {
        return;
    }
    if (self.serviceURL.length > 6) {
        SWWebViewController *web = [[SWWebViewController alloc] init];
        web.urls = self.serviceURL;
        [[SWMXBADelegate sharedAppDelegate] pushViewController:web animated:YES];
    } else {
        [MBProgressHUD showError:@"客服暂未上线"];
    }
}

- (void)requestUserInfo {
    [SWToolClass getQCloudWithUrl:@"user" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            SWLiveUser *user = [[SWLiveUser alloc] initWithDic:info];
            [SWConfig saveProfile:user];
            [self.avatarButton sd_setImageWithURL:[NSURL URLWithString:minstr([info valueForKey:@"avatar"])] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"mine_默认头像"]];
            self.nicknameLabel.text = minstr([info valueForKey:@"nickname"]);
            self.userIdLabel.text = [self displayUserIdText:minstr([info valueForKey:@"uid"])];
            self.serviceURL = minstr([info valueForKey:@"service_url"]);
            [self.tableView reloadData];
        }
    } Fail:^{
    }];
}

- (NSString *)displayUserIdText:(NSString *)userId {
    NSString *validUserId = userId;
    if (!validUserId || [validUserId isEqualToString:@"(null)"] || [validUserId isEqualToString:@"<null>"]) {
        validUserId = @"";
    }
    return [NSString stringWithFormat:@"ID:%@", validUserId];
}

- (BOOL)ensureLogin {
    if (![SWConfig getOwnID] || [[SWConfig getOwnID] intValue] == 0) {
        [[SWToolClass sharedInstance] showLoginView];
        return NO;
    }
    return YES;
}

@end
