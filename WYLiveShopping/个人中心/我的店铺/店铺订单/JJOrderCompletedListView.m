#import "JJOrderCompletedListView.h"
#import "SWOrderCell.h"
#import "MJRefresh.h"
#import "JJNoDataNormalView.h"

@interface JJOrderCompletedListView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JJNoDataNormalView *noDataView;

@end

@implementation JJOrderCompletedListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.dataArray = NSMutableArray.new;
        self.page = 1;
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
            self.page = 1;
            [self requestData];
        }];
        tableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            self.page++;
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
    self.page = 1;
    [self requestData];
}

- (void)requestData {
    NSString *url = [NSString stringWithFormat:@"order/list?type=4&status=%@&page=%d", self.statusType, self.page];
    __weak typeof(self) weakSelf = self;
    [SWToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        [strongSelf.tableView.mj_header endRefreshing];
        [strongSelf.tableView.mj_footer endRefreshing];

        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
                [strongSelf.tableView.mj_footer resetNoMoreData];
            }
            for (NSDictionary *dic in info) {
                SWOrderModel *model = [[SWOrderModel alloc] initWithDic:dic];
                [self.dataArray addObject:model];
            }
            if ([info count] < 20) {
                [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [strongSelf.tableView reloadData];
            [strongSelf updateNoDataViewHidden];

            if (strongSelf.page == 1 && strongSelf.refreshBlock) {
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
    self.noDataView.hidden = self.dataArray.count > 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWOrderCell" owner:nil options:nil] lastObject];
        cell.store_nameL.hidden = YES;
        cell.storeImgView.hidden = YES;
        cell.leftBtn.hidden = YES;
        [cell.rightBtn setTitle:@"查看详情" forState:0];
        cell.rightBtn.userInteractionEnabled = NO;
    }

    SWOrderModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    cell.timeL.text = model.add_time;
    cell.allPriceL.text = [NSString stringWithFormat:@"¥ %@", model.total_price];

    if ([self.statusType isEqual:@"1"]) {
        cell.profitLabel.text = [NSString stringWithFormat:@"代销收益 ¥ %@", model.bring_price];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWOrderModel *model = self.dataArray[indexPath.row];
    return model.rowH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectBlock && indexPath.row < self.dataArray.count) {
        self.selectBlock(self.dataArray[indexPath.row]);
    }
}

@end
