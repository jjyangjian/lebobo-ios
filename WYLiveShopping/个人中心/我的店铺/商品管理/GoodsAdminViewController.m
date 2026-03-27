//
//  GoodsAdminViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/22.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "GoodsAdminViewController.h"
#import "adminAddViewController.h"
#import "adminGoodsCell.h"
#import "JJGoodsOnSaleView.h"
#import "JJGoodsOffShelfView.h"
#import "../../../JJNoDataNormalView.h"

@interface JJGoodsOnSaleView ()<UITableViewDelegate, UITableViewDataSource, adminGoodsCellDelegate> {
    NSMutableArray *dataArray;
    int page;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JJNoDataNormalView *noDataView;

@end

@implementation JJGoodsOnSaleView

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
    self.backgroundColor = colorf0;

    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = colorf0;
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            page = 1;
            [self requestData];
        }];
        tableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            page ++;
            [self requestData];
        }];
        if (@available(iOS 13.0, *)) {
            tableView.automaticallyAdjustsScrollIndicatorInsets = NO;
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
        noDataView.label.text = @"暂无商品信息";
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
    NSString *url = [NSString stringWithFormat:@"shoplist?page=%d&liveuid=%@", page, [Config getOwnID]];
    [WYToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (code == 200) {
            if (page == 1) {
                [dataArray removeAllObjects];
                [self.tableView.mj_footer resetNoMoreData];
                if (self.refreshBlock) {
                    self.refreshBlock();
                }
            }
            for (NSDictionary *dic in info) {
                liveGoodsModel *model = [[liveGoodsModel alloc] initWithDic:dic];
                [dataArray addObject:model];
            }
            if ([info count] < 20) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.tableView reloadData];
            [self updateNoDataViewHidden];
        }
    } Fail:^{
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)updateNoDataViewHidden {
    self.noDataView.hidden = dataArray.count > 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    adminGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"adminGoodsCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"adminGoodsCell" owner:nil options:nil] lastObject];
    }
    cell.delegate = self;
    cell.delateBtn.hidden = YES;
    [cell.rightBtn setTitle:@"下架" forState:UIControlStateNormal];
    [cell.rightBtn setTitleColor:color32 forState:UIControlStateNormal];
    cell.rightBtn.layer.borderColor = RGB_COLOR(@"#E0E0E0", 1).CGColor;
    cell.model = dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectBlock) {
        self.selectBlock(dataArray[indexPath.row]);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 165;
}

- (void)shangjiaGoods:(liveGoodsModel *)model {
}

- (void)xiajiaGoods:(liveGoodsModel *)model {
    [MBProgressHUD showMessage:@""];
    [WYToolClass postNetworkWithUrl:@"shopedit" andParameter:@{@"productid" : model.goodsID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            [dataArray removeObject:model];
            [self.tableView reloadData];
            [self updateNoDataViewHidden];
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            if (self.actionBlock) {
                self.actionBlock(model, @"xiajia");
            }
            [MBProgressHUD showError:msg];
        }
    } fail:^{
    }];
}

- (void)delateGoods:(liveGoodsModel *)model {
}

@end

@interface JJGoodsOffShelfView ()<UITableViewDelegate, UITableViewDataSource, adminGoodsCellDelegate> {
    NSMutableArray *dataArray;
    int page;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JJNoDataNormalView *noDataView;

@end

@implementation JJGoodsOffShelfView

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
    self.backgroundColor = colorf0;

    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = colorf0;
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            page = 1;
            [self requestData];
        }];
        tableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            page ++;
            [self requestData];
        }];
        if (@available(iOS 13.0, *)) {
            tableView.automaticallyAdjustsScrollIndicatorInsets = NO;
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
        noDataView.label.text = @"暂无商品信息";
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
    NSString *url = [NSString stringWithFormat:@"shoplistno?page=%d", page];
    [WYToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (code == 200) {
            if (page == 1) {
                [dataArray removeAllObjects];
                [self.tableView.mj_footer resetNoMoreData];
                if (self.refreshBlock) {
                    self.refreshBlock();
                }
            }
            for (NSDictionary *dic in info) {
                liveGoodsModel *model = [[liveGoodsModel alloc] initWithDic:dic];
                [dataArray addObject:model];
            }
            if ([info count] < 20) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.tableView reloadData];
            [self updateNoDataViewHidden];
        }
    } Fail:^{
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)updateNoDataViewHidden {
    self.noDataView.hidden = dataArray.count > 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    adminGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"adminGoodsCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"adminGoodsCell" owner:nil options:nil] lastObject];
    }
    cell.delegate = self;
    cell.delateBtn.hidden = NO;
    [cell.rightBtn setTitle:@"上架" forState:UIControlStateNormal];
    [cell.rightBtn setTitleColor:normalColors forState:UIControlStateNormal];
    cell.rightBtn.layer.borderColor = normalColors.CGColor;
    cell.model = dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectBlock) {
        self.selectBlock(dataArray[indexPath.row]);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 165;
}

- (void)shangjiaGoods:(liveGoodsModel *)model {
    [MBProgressHUD showMessage:@""];
    [WYToolClass postNetworkWithUrl:@"shopadd" andParameter:@{@"productid" : model.goodsID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            [dataArray removeObject:model];
            [self.tableView reloadData];
            [self updateNoDataViewHidden];
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            if (self.actionBlock) {
                self.actionBlock(model, @"shangjia");
            }
            [MBProgressHUD showError:msg];
        }
    } fail:^{
    }];
}

- (void)xiajiaGoods:(liveGoodsModel *)model {
}

- (void)delateGoods:(liveGoodsModel *)model {
    [MBProgressHUD showMessage:@""];
    [WYToolClass postNetworkWithUrl:@"shopdel" andParameter:@{@"productid" : model.goodsID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            [dataArray removeObject:model];
            [self.tableView reloadData];
            [self updateNoDataViewHidden];
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            if (self.actionBlock) {
                self.actionBlock(model, @"delate");
            }
            [MBProgressHUD showError:msg];
        }
    } fail:^{
    }];
}

@end

@interface GoodsAdminViewController () {
    NSString *shopsalenums;
    NSString *shopnumsno;
}
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, weak) UIStackView *headerStackView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *btnArray;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) JJGoodsOnSaleView *onSaleView;
@property (nonatomic, weak) JJGoodsOffShelfView *offShelfView;

@end

@implementation GoodsAdminViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"商品管理";
    shopsalenums = @"0";
    shopnumsno = @"0";
    self.datas = [NSMutableArray array];
    self.btnArray = [NSMutableArray array];
    self.selectedIndex = 0;
    [self configUI];
    [self loadData];
    [self addBottomView];
    [self getSellerGoodsNum];
    [self getShopnumsno];
    [self showGoodsViewAtIndex:0 shouldRequest:YES];
}

- (void)configUI {
    {
        UIView *headerView = [[UIView alloc] init];
        headerView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:headerView];
        [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.naviView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(50);
        }];
        self.headerView = headerView;
    }

    {
        UIStackView *stackView = [[UIStackView alloc] init];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.alignment = UIStackViewAlignmentFill;
        stackView.distribution = UIStackViewDistributionFillEqually;
        stackView.spacing = 0;
        [self.headerView addSubview:stackView];
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.headerView);
        }];
        self.headerStackView = stackView;
    }

    for (NSInteger index = 0; index < 2; index++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index;
        [button setTitleColor:color96 forState:UIControlStateNormal];
        [button setTitleColor:JJAPPTHEMECOLOR forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button addTarget:self action:@selector(typeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerStackView addArrangedSubview:button];
        [self.btnArray addObject:button];
    }

    {
        UIView *contentView = [[UIView alloc] init];
        contentView.backgroundColor = colorf0;
        [self.view addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headerView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(60 + ShowDiff));
        }];
        self.contentView = contentView;
    }

    {
        JJGoodsOnSaleView *onSaleView = [[JJGoodsOnSaleView alloc] init];
        [self.contentView addSubview:onSaleView];
        [onSaleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        self.onSaleView = onSaleView;
    }

    {
        JJGoodsOffShelfView *offShelfView = [[JJGoodsOffShelfView alloc] init];
        offShelfView.hidden = YES;
        [self.contentView addSubview:offShelfView];
        [offShelfView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        self.offShelfView = offShelfView;
    }

    __weak typeof(self) weakSelf = self;
    self.onSaleView.refreshBlock = ^{
        [weakSelf getSellerGoodsNum];
        [weakSelf getShopnumsno];
    };
    self.offShelfView.refreshBlock = ^{
        [weakSelf getSellerGoodsNum];
        [weakSelf getShopnumsno];
    };
}

- (void)addBottomView {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _window_height - 60 - ShowDiff, _window_width, 60 + ShowDiff)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];

    UIButton *addBtn = [UIButton buttonWithType:0];
    addBtn.frame = CGRectMake(15, 12, _window_width - 30, 36);
    [addBtn setTitle:@"添加商品" forState:0];
    [addBtn setBackgroundColor:JJAPPTHEMECOLOR];
    addBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    addBtn.layer.cornerRadius = 18;
    addBtn.layer.masksToBounds = YES;
    addBtn.layer.borderColor = JJAPPTHEMECOLOR.CGColor;
    addBtn.layer.borderWidth = 0.5;
    [addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:addBtn];
}

- (void)addBtnClick:(UIButton *)sender {
    adminAddViewController *vc = [[adminAddViewController alloc] init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)loadData {
    self.datas = @[
        [NSString stringWithFormat:@"在售 %@", shopsalenums],
        [NSString stringWithFormat:@"已下架 %@", shopnumsno]
    ].mutableCopy;
    [self updateButtonTitles];
}

- (void)typeBtnClick:(UIButton *)sender {
    [self showGoodsViewAtIndex:sender.tag shouldRequest:YES];
}

- (void)showGoodsViewAtIndex:(NSInteger)index shouldRequest:(BOOL)shouldRequest {
    if (index >= self.btnArray.count) {
        return;
    }
    self.selectedIndex = index;
    [self updateSelectedButtonAtIndex:index];
    self.onSaleView.hidden = index != 0;
    self.offShelfView.hidden = index != 1;
    if (shouldRequest) {
        if (index == 0) {
            [self.onSaleView requestFirstPageData];
        } else {
            [self.offShelfView requestFirstPageData];
        }
    }
}

- (void)updateSelectedButtonAtIndex:(NSInteger)index {
    [self.btnArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isSelected = idx == index;
        obj.selected = isSelected;
        obj.titleLabel.font = isSelected ? [UIFont systemFontOfSize:16] : [UIFont systemFontOfSize:15];
    }];
}

- (void)updateButtonTitles {
    [self.btnArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *title = idx < self.datas.count ? self.datas[idx] : @"";
        [obj setTitle:title forState:UIControlStateNormal];
        [obj setTitle:title forState:UIControlStateSelected];
    }];
    [self updateSelectedButtonAtIndex:self.selectedIndex];
}

- (void)getSellerGoodsNum {
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"shopnums?liveuid=%@", [Config getOwnID]] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            shopsalenums = minstr([info valueForKey:@"nums"]);
            self.datas = @[
                [NSString stringWithFormat:@"在售 %@", shopsalenums],
                [NSString stringWithFormat:@"已下架 %@", shopnumsno]
            ].mutableCopy;
            [self updateButtonTitles];
        }
    } Fail:^{
    }];
}

- (void)getShopnumsno {
    [WYToolClass getQCloudWithUrl:@"shopnumsno" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            shopnumsno = minstr([info valueForKey:@"nums"]);
            self.datas = @[
                [NSString stringWithFormat:@"在售 %@", shopsalenums],
                [NSString stringWithFormat:@"已下架 %@", shopnumsno]
            ].mutableCopy;
            [self updateButtonTitles];
        }
    } Fail:^{
    }];
}

@end
