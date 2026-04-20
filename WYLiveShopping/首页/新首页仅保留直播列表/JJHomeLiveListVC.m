//
//  JJHomeLiveListVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/31.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "JJHomeLiveListVC.h"
#import "JJHomeLiveListCell.h"
#import "JJHomeLiveListHeader.h"
#import "SWScanCodeVC.h"
#import "SWAllLiveVC.h"
#import "SWHomeLiveModel.h"
#import "SWLivePlayerViewController.h"

@interface JJHomeLiveListVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *scanBtn;
@property (nonatomic, copy) NSArray *liveItems;
@property (nonatomic, strong) UITableView *tableview;

@end

@implementation JJHomeLiveListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self addHeaderView];
    [self configUI];
    [self requestData];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(videoDelete:) name:@"videoDelete" object:nil];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)configUI {
    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[JJHomeLiveListCell class] forCellReuseIdentifier:NSStringFromClass([JJHomeLiveListCell class])];
        [tableView registerClass:[JJHomeLiveListHeader class] forHeaderFooterViewReuseIdentifier:@"JJHomeLiveListHeader"];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(64 + statusbarHeight, 0, 80, 0));
        }];
        self.tableview = tableView;
    }

    self.tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestData];
    }];
}

- (void)addHeaderView {
    UIView *navi = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navi.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navi];

    {
        UIButton *iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [iconBtn setImage:[SWToolClass getAppIcon] forState:UIControlStateNormal];
        [iconBtn setCornerRadius:15];
        iconBtn.frame = CGRectMake(15, statusbarHeight + 27, 30, 30);
        [navi addSubview:iconBtn];
    }

    {
        UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        scanBtn.frame = CGRectMake(_window_width - 85, 26.5 + statusbarHeight, 70, 70);
        [scanBtn setImage:[UIImage imageNamed:@"home_scan"] forState:UIControlStateNormal];
        [scanBtn setTitle:@"扫一扫" forState:UIControlStateNormal];
        [scanBtn setTitleColor:color32 forState:UIControlStateNormal];
        scanBtn.titleLabel.font = SYS_Font(9);
        [scanBtn addTarget:self action:@selector(doScan) forControlEvents:UIControlEventTouchUpInside];
        [navi addSubview:scanBtn];
        scanBtn = [SWToolClass setUpImgDownText:scanBtn];
        scanBtn.size = CGSizeMake(35, 35);
        self.scanBtn = scanBtn;
    }
}

- (void)requestData {
    [MBProgressHUD showMessage:@""];
    [SWToolClass getQCloudWithUrl:@"homeindex" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.tableview.mj_header endRefreshing];
        [MBProgressHUD hideHUD];
        if (code == 200) {
            self.liveItems = [info valueForKey:@"live"];
            [self.tableview reloadData];
        }
    } Fail:^{
        [self.tableview.mj_header endRefreshing];
        [MBProgressHUD hideHUD];
    }];
}

- (void)videoDelete:(NSNotification *)not {
    [self.tableview.mj_header beginRefreshing];
}

- (void)doScan {
    SWScanCodeVC *vc = [[SWScanCodeVC alloc] init];
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)allLivesVC {
    SWAllLiveVC *vc = [[SWAllLiveVC alloc] init];
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)checkLive:(SWHomeLiveModel *)model {
    [SWToolClass postNetworkWithUrl:@"live/check" andParameter:@{@"stream" : model.stream} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            SWLivePlayerViewController *player = [[SWLivePlayerViewController alloc] init];
            player.roomMap = [model.originDic mutableCopy];
            [[SWMXBADelegate sharedAppDelegate] pushViewController:player animated:YES];
        } else {
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.liveItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 250;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JJHomeLiveListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JJHomeLiveListCell class])];
    [cell bindFromModel:self.liveItems[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SWHomeLiveModel *model = [[SWHomeLiveModel alloc] initWithDic:self.liveItems[indexPath.row]];
    [self checkLive:model];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    JJHomeLiveListHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"JJHomeLiveListHeader"];
    __weak typeof(self) weakSelf = self;
    header.doMoreAction = ^{
        [weakSelf allLivesVC];
    };
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

@end
