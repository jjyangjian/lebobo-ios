#import "JJMerchantHomeVC.h"
#import "StoreOrderListViewController.h"
#import "mineProfitViewController.h"
#import "GoodsAdminViewController.h"
#import "JJHomeShopOrderModuleCell.h"
#import "JJHomeShopRevenueModuleCell.h"
#import "JJHomeGoodsManagerModuleCell.h"
#import "JJHomeMerchantBackendModuleCell.h"

static NSString * const JJHomeShopOrderModuleCellId = @"JJHomeShopOrderModuleCell";
static NSString * const JJHomeShopRevenueModuleCellId = @"JJHomeShopRevenueModuleCell";
static NSString * const JJHomeGoodsManagerModuleCellId = @"JJHomeGoodsManagerModuleCell";
static NSString * const JJHomeMerchantBackendModuleCellId = @"JJHomeMerchantBackendModuleCell";

typedef NS_ENUM(NSInteger, JJMerchantHomeModuleType) {
    JJMerchantHomeModuleTypeOrder = 0,
    JJMerchantHomeModuleTypeRevenue,
    JJMerchantHomeModuleTypeGoodsManager,
    JJMerchantHomeModuleTypeMerchantBackend,
};

@interface JJMerchantHomeVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *unshippedCount;
@property (nonatomic, copy) NSString *receivedCount;
@property (nonatomic, copy) NSString *evaluatedCount;
@property (nonatomic, copy) NSString *todayRevenue;
@property (nonatomic, copy) NSString *totalRevenue;
@property (nonatomic, copy) NSString *settledRevenue;
@property (nonatomic, copy) NSString *unsettledRevenue;
@property (nonatomic, copy) NSString *merchantURL;

@end

@implementation JJMerchantHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"首页";
    self.returnBtn.hidden = YES;
    [self setupDefaultData];
    [self buildUI];
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self requestData];
}

- (void)setupDefaultData {
    self.unshippedCount = @"0";
    self.receivedCount = @"0";
    self.evaluatedCount = @"0";
    self.todayRevenue = @"0.00";
    self.totalRevenue = @"0.00";
    self.settledRevenue = @"0.00";
    self.unsettledRevenue = @"0.00";
    self.merchantURL = [self currentShopURL];
}

- (void)buildUI {
    self.view.backgroundColor = RGB_COLOR(@"#F7F8FA", 1);

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = RGB_COLOR(@"#F7F8FA", 1);
    self.tableView.estimatedRowHeight = 180;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestData)];
    [self.tableView registerClass:[JJHomeShopOrderModuleCell class] forCellReuseIdentifier:JJHomeShopOrderModuleCellId];
    [self.tableView registerClass:[JJHomeShopRevenueModuleCell class] forCellReuseIdentifier:JJHomeShopRevenueModuleCellId];
    [self.tableView registerClass:[JJHomeGoodsManagerModuleCell class] forCellReuseIdentifier:JJHomeGoodsManagerModuleCellId];
    [self.tableView registerClass:[JJHomeMerchantBackendModuleCell class] forCellReuseIdentifier:JJHomeMerchantBackendModuleCellId];
    [self.view addSubview:self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.naviView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case JJMerchantHomeModuleTypeOrder:
            return [self orderCellForTableView:tableView];
        case JJMerchantHomeModuleTypeRevenue:
            return [self revenueCellForTableView:tableView];
        case JJMerchantHomeModuleTypeGoodsManager:
            return [self goodsManagerCellForTableView:tableView];
        case JJMerchantHomeModuleTypeMerchantBackend:
            return [self merchantBackendCellForTableView:tableView];
        default:
            return [UITableViewCell new];
    }
}

- (UITableViewCell *)orderCellForTableView:(UITableView *)tableView {
    JJHomeShopOrderModuleCell *cell = [tableView dequeueReusableCellWithIdentifier:JJHomeShopOrderModuleCellId];
    [cell updateWithUnshippedCount:self.unshippedCount receivedCount:self.receivedCount evaluatedCount:self.evaluatedCount];
    __weak typeof(self) weakSelf = self;
    cell.orderActionBlock = ^{
        [weakSelf openStoreOrderPage];
    };
    return cell;
}

- (UITableViewCell *)revenueCellForTableView:(UITableView *)tableView {
    JJHomeShopRevenueModuleCell *cell = [tableView dequeueReusableCellWithIdentifier:JJHomeShopRevenueModuleCellId];
    [cell updateWithTodayRevenue:self.todayRevenue totalRevenue:self.totalRevenue settledRevenue:self.settledRevenue unsettledRevenue:self.unsettledRevenue];
    __weak typeof(self) weakSelf = self;
    cell.revenueActionBlock = ^{
        [weakSelf openStoreRevenuePage];
    };
    return cell;
}

- (UITableViewCell *)goodsManagerCellForTableView:(UITableView *)tableView {
    JJHomeGoodsManagerModuleCell *cell = [tableView dequeueReusableCellWithIdentifier:JJHomeGoodsManagerModuleCellId];
    __weak typeof(self) weakSelf = self;
    cell.goodsManagerActionBlock = ^{
        [weakSelf openGoodsManagerPage];
    };
    return cell;
}

- (UITableViewCell *)merchantBackendCellForTableView:(UITableView *)tableView {
    JJHomeMerchantBackendModuleCell *cell = [tableView dequeueReusableCellWithIdentifier:JJHomeMerchantBackendModuleCellId];
    [cell updateWithMerchantURL:self.merchantURL];
    __weak typeof(self) weakSelf = self;
    cell.merchantBackendActionBlock = ^{
        [weakSelf copyMerchantURL];
    };
    return cell;
}

- (void)openStoreOrderPage {
    StoreOrderListViewController *vc = [[StoreOrderListViewController alloc] init];
    vc.statusType = @"2";
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)openStoreRevenuePage {
    mineProfitViewController *vc = [[mineProfitViewController alloc] init];
    vc.ptofitType = 1;
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)openGoodsManagerPage {
    GoodsAdminViewController *vc = [[GoodsAdminViewController alloc] init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)copyMerchantURL {
    if (self.merchantURL.length == 0) {
        [MBProgressHUD showError:@"商家后台地址为空"];
        return;
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.merchantURL;
    [MBProgressHUD showError:@"复制成功"];
}

- (void)requestData {
    self.merchantURL = [self currentShopURL];
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_enter(group);
    [self requestShopOrderData:^{
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [self requestShopRevenue:^{
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        self.merchantURL = [self currentShopURL];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    });
}

- (void)requestShopOrderData:(dispatch_block_t)completion {
    [WYToolClass getQCloudWithUrl:@"order/data?status=2" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.unshippedCount = minstr([info valueForKey:@"unshipped_count"]);
            self.receivedCount = minstr([info valueForKey:@"received_count"]);
            self.evaluatedCount = minstr([info valueForKey:@"evaluated_count"]);
        }
        if (completion) {
            completion();
        }
    } Fail:^{
        if (completion) {
            completion();
        }
    }];
}

- (void)requestShopRevenue:(dispatch_block_t)completion {
    [WYToolClass getQCloudWithUrl:@"shopcash" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.todayRevenue = minstr([info valueForKey:@"shop_t"]);
            self.totalRevenue = minstr([info valueForKey:@"shop_total"]);
            self.settledRevenue = minstr([info valueForKey:@"shop_ok"]);
            self.unsettledRevenue = minstr([info valueForKey:@"shop_no"]);
        }
        if (completion) {
            completion();
        }
    } Fail:^{
        if (completion) {
            completion();
        }
    }];
}

- (NSString *)currentShopURL {
    NSString *shopURL = [common shop_url];
    if (!shopURL || [shopURL isEqualToString:@"(null)"]) {
        return @"";
    }
    return shopURL;
}

@end
