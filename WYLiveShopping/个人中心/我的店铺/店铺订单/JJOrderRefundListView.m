#import "JJOrderRefundListView.h"
#import "ReturnOrderCell.h"
#import "orderModel.h"
#import "MJRefresh.h"
#import "JJNoDataNormalView.h"

@interface JJOrderRefundListView () <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *dataArray;
    int page;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JJNoDataNormalView *noDataView;

@end

@implementation JJOrderRefundListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        dataArray = [NSMutableArray array];
        page = 1;
        [self configUI];
    }
    return self;
}

- (void)configUI {
    self.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);

    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            page = 1;
            [self requestData];
        }];
        tableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            page++;
            [self requestData];
        }];
        if (@available(iOS 15.0, *)) {
            tableView.sectionHeaderTopPadding = 0;
        }
        [self addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.tableView = tableView;
    }

    {
        JJNoDataNormalView *noDataView = [[JJNoDataNormalView alloc] initWithFrame:CGRectZero];
        noDataView.hidden = YES;
        self.tableView.backgroundView = noDataView;
        self.noDataView = noDataView;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.noDataView.frame = self.tableView.bounds;
}

- (void)requestFirstPageData {
    page = 1;
    [self requestData];
}

- (void)requestData {
    NSString *url = [NSString stringWithFormat:@"order/list?type=-3&status=%@&page=%d", self.statusType, page];
    __weak typeof(self) weakSelf = self;
    [WYToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        [strongSelf.tableView.mj_header endRefreshing];
        [strongSelf.tableView.mj_footer endRefreshing];

        if (code == 200) {
            if (page == 1) {
                [dataArray removeAllObjects];
                [strongSelf.tableView.mj_footer resetNoMoreData];
            }
            for (NSDictionary *dic in info) {
                orderModel *model = [[orderModel alloc] initWithDic:dic];
                [dataArray addObject:model];
            }
            if ([info count] < 20) {
                [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [strongSelf.tableView reloadData];
            [strongSelf updateNoDataViewHidden];

            if (page == 1 && strongSelf.refreshBlock) {
                strongSelf.refreshBlock();
            }
        }
    } Fail:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        [strongSelf.tableView.mj_header endRefreshing];
        [strongSelf.tableView.mj_footer endRefreshing];
    }];
}

- (void)updateNoDataViewHidden {
    self.noDataView.hidden = dataArray.count > 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    orderModel *oModel = dataArray[section];
    return oModel.goodsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReturnOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReturnOrderCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReturnOrderCell" owner:nil options:nil] lastObject];
    }

    orderModel *oModel = dataArray[indexPath.section];
    cell.model = oModel.goodsArray[indexPath.row];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 43;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    view.clipsToBounds = NO;

    orderModel *model = dataArray[section];

    {
        UILabel *label = [[UILabel alloc] init];
        label.text = model.orderNums;
        label.font = SYS_Font(15);
        label.textColor = color32;
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(15);
            make.centerY.equalTo(view);
        }];
    }

    {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = RGB_COLOR(@"#eeeeee", 1);
        [view addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(view);
            make.bottom.equalTo(view);
            make.height.mas_equalTo(1);
        }];
    }

    {
        UIImageView *statusImgV = [[UIImageView alloc] init];
        if ([model.refund_status isEqual:@"2"]) {
            statusImgV.image = [UIImage imageNamed:@"已退款"];
        } else {
            statusImgV.image = [UIImage imageNamed:@"退款中"];
        }
        [view addSubview:statusImgV];
        [statusImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(view).offset(-15);
            make.centerY.equalTo(view);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(50);
        }];
    }

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];

    orderModel *model = dataArray[section];

    {
        UILabel *totalLabel = [[UILabel alloc] init];
        totalLabel.font = SYS_Font(15);
        totalLabel.textColor = color32;
        [view addSubview:totalLabel];
        [totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(view).offset(-15);
            make.centerY.equalTo(view).offset(-2.5);
        }];
        totalLabel.attributedText = [self getAttStrWithNums:model.total_num andTotalMoney:model.total_price];
    }

    if ([self.statusType isEqual:@"1"]) {
        {
            UILabel *label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"代销收益 ¥ %@", model.bring_price];
            label.font = SYS_Font(14);
            label.textColor = color32;
            [view addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(view).offset(15);
                make.centerY.equalTo(view);
            }];
        }
    }

    {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
        [view addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(view);
            make.bottom.equalTo(view);
            make.height.mas_equalTo(5);
        }];
    }

    return view;
}

- (NSAttributedString *)getAttStrWithNums:(NSString *)nums andTotalMoney:(NSString *)money {
    NSMutableAttributedString *mustr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"共%@件商品 总金额：¥%@", nums, money]];
    [mustr setAttributes:@{NSForegroundColorAttributeName: normalColors, NSFontAttributeName: [UIFont boldSystemFontOfSize:15]} range:NSMakeRange(mustr.length - money.length - 1, money.length + 1)];
    return mustr;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectBlock && indexPath.section < dataArray.count) {
        self.selectBlock(dataArray[indexPath.section]);
    }
}

@end
