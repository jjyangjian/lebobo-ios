//
//  MineSettingViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/9.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "MineSettingViewController.h"
#import <SDWebImage/SDImageCache.h>
#import "WYRoomManagerVC.h"

static NSString * const JJSettingCellId = @"JJSettingCell";

@interface MineSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *setTable;
@property (nonatomic, strong) UIButton *deleteAccountButton;
@property (nonatomic, strong) NSArray<NSString *> *firstSectionItems;
@property (nonatomic, strong) NSArray<NSString *> *secondSectionItems;
@property (nonatomic, assign) float cacheSize;

@end

@implementation MineSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"设置";
    self.view.backgroundColor = RGB_COLOR(@"#ECECEC", 1);

    self.firstSectionItems = @[@"房间管理", @"联系我们", @"版本更新", @"清除缓存"];
    self.secondSectionItems = @[@"退出登录"];

    NSUInteger bytesCache = [[SDImageCache sharedImageCache] totalDiskSize];
    self.cacheSize = bytesCache / 1000.0 / 1000.0;

    [self buildUI];
}

- (void)buildUI {
    self.setTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.setTable.delegate = self;
    self.setTable.dataSource = self;
    self.setTable.backgroundColor = RGB_COLOR(@"#ECECEC", 1);
    self.setTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.setTable.showsVerticalScrollIndicator = NO;
    self.setTable.alwaysBounceVertical = YES;
    self.setTable.tableFooterView = [UIView new];
    self.setTable.sectionHeaderHeight = 0.001;
    self.setTable.sectionFooterHeight = 0.001;
    if (@available(iOS 15.0, *)) {
        self.setTable.sectionHeaderTopPadding = 0;
    }
    [self.view addSubview:self.setTable];

    self.deleteAccountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteAccountButton setTitle:@"注销账号" forState:UIControlStateNormal];
    [self.deleteAccountButton setTitleColor:RGB_COLOR(@"#FD4A4A", 1) forState:UIControlStateNormal];
    self.deleteAccountButton.titleLabel.font = SYS_Font(14);
    [self.deleteAccountButton addTarget:self action:@selector(showDeleteAccountAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.deleteAccountButton];

    [self.setTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.naviView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.deleteAccountButton.mas_top).offset(-16);
    }];

    [self.deleteAccountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-(ShowDiff + 20));
        make.height.mas_equalTo(20);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.firstSectionItems.count : self.secondSectionItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JJSettingCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:JJSettingCellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = SYS_Font(16);
        cell.textLabel.textColor = color32;
        cell.detailTextLabel.font = SYS_Font(14);
        cell.detailTextLabel.textColor = color64;
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    cell.detailTextLabel.text = @"";

    if (indexPath.section == 0) {
        cell.textLabel.text = self.firstSectionItems[indexPath.row];
        if (indexPath.row == 0 || indexPath.row == 1) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryImage"]];
        } else if (indexPath.row == 2) {
            NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            cell.detailTextLabel.text = build ?: @"";
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fMB", self.cacheSize];
        }
    } else {
        cell.textLabel.text = self.secondSectionItems[indexPath.row];
        cell.detailTextLabel.text = @"";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        [self logOutBtnClick];
        return;
    }

    switch (indexPath.row) {
        case 0:
            [self roomManager];
            break;
        case 1:
            [self gunayuwomen];
            break;
        case 2:
            [self checkBuild];
            break;
        case 3:
            [self clearCrash];
            break;
        default:
            break;
    }
}

- (void)roomManager {
    WYRoomManagerVC *roomVC = [WYRoomManagerVC new];
    [self.navigationController pushViewController:roomVC animated:YES];
}

- (void)logOutBtnClick {
    [[WYToolClass sharedInstance] quitLogin];
}

- (void)gunayuwomen {
    WYWebViewController *web = [[WYWebViewController alloc] init];
    web.urls = [NSString stringWithFormat:@"%@//appapi/page/detail?id=1",h5url];
    [self.navigationController pushViewController:web animated:YES];
}

- (void)checkBuild {
    [MBProgressHUD showError:@"当前已是最新版本"];
}

- (void)clearCrash {
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    self.cacheSize = 0;
    [self.setTable reloadData];
    [MBProgressHUD showError:@"缓存已清除"];
}

- (void)showDeleteAccountAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"注销账号" message:@"如需注销账号请在输入框内输入\n“确定注销账号”" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"确定注销账号";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"注销" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *inputText = alertController.textFields.firstObject.text ?: @"";
        if (![inputText isEqualToString:@"确定注销账号"]) {
            [MBProgressHUD showError:@"输入内容不正确"];
            return;
        }
        [MBProgressHUD showError:@"注销功能暂未接入"];
    }];
    [confirmAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
