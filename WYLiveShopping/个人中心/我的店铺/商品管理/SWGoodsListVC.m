//
//  SWGoodsListVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/22.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWGoodsListVC.h"
#import "SWAdminGoodsCell.h"
#import "../../../JJNoDataNormalView.h"

@interface SWGoodsListVC ()<UITableViewDelegate,UITableViewDataSource,SWAdminGoodsCellDelegate>
@property (nonatomic, strong) UITableView *goodsTableView;
@property (nonatomic, strong) JJNoDataNormalView *noDataView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int page;

@end

@implementation SWGoodsListVC

- (UITableView *)goodsTableView {
    if (!_goodsTableView) {
        _goodsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height - (64 + statusbarHeight + 50) - ShowDiff - 60) style:0];
        _goodsTableView.delegate = self;
        _goodsTableView.dataSource = self;
        _goodsTableView.separatorStyle = 0;
        _goodsTableView.backgroundColor = colorf0;
        _goodsTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.page = 1;
            [self requestData];
        }];
        _goodsTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            self.page++;
            [self requestData];
        }];
        if (@available(iOS 13.0, *)) {
            _goodsTableView.automaticallyAdjustsScrollIndicatorInsets = NO;
        }
    }
    return _goodsTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    self.page = 1;
    [self.view addSubview:self.goodsTableView];
    JJNoDataNormalView *noDataView = [[JJNoDataNormalView alloc] initWithFrame:self.goodsTableView.bounds];
    noDataView.hidden = YES;
    noDataView.label.text = @"暂无商品信息";
    noDataView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.goodsTableView.backgroundView = noDataView;
    self.noDataView = noDataView;
    [self requestData];
}

- (void)requestData {
    NSString *url;
    if (self.index == 0) {
        url = [NSString stringWithFormat:@"shoplist?page=%d&liveuid=%@", self.page, [SWConfig getOwnID]];
    } else {
        url = [NSString stringWithFormat:@"shoplistno?page=%d", self.page];
    }
    [SWToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.goodsTableView.mj_header endRefreshing];
        [self.goodsTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
                if (self.block) {
                    self.block();
                }
            }
            for (NSDictionary *dic in info) {
                SWLiveGoodsModel *model = [[SWLiveGoodsModel alloc] initWithDic:dic];
                [self.dataArray addObject:model];
            }
            [self.goodsTableView reloadData];
            self.noDataView.hidden = self.dataArray.count != 0;
        }
    } Fail:^{
        [self.goodsTableView.mj_header endRefreshing];
        [self.goodsTableView.mj_footer endRefreshing];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWAdminGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"adminGoodsCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWAdminGoodsCell" owner:nil options:nil] lastObject];
        cell.delegate = self;
        if (self.index == 0) {
            cell.delateBtn.hidden = YES;
            [cell.rightBtn setTitle:@"下架" forState:0];
            [cell.rightBtn setTitleColor:color32 forState:0];
            cell.rightBtn.layer.borderColor = RGB_COLOR(@"#E0E0E0", 1).CGColor;
        } else {
            [cell.rightBtn setTitle:@"上架" forState:0];
            [cell.rightBtn setTitleColor:normalColors forState:0];
            cell.rightBtn.layer.borderColor = normalColors.CGColor;
        }
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 165;
}

- (void)shangjiaGoods:(SWLiveGoodsModel *)model {
    [MBProgressHUD showMessage:@""];
    [SWToolClass postNetworkWithUrl:@"shopadd" andParameter:@{@"productid": model.goodsID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            [self.dataArray removeObject:model];
            [self.goodsTableView reloadData];
            if (self.block) {
                self.block();
            }
            [MBProgressHUD showError:msg];
        }
    } fail:^{
    }];
}

- (void)xiajiaGoods:(SWLiveGoodsModel *)model {
    [MBProgressHUD showMessage:@""];
    [SWToolClass postNetworkWithUrl:@"shopedit" andParameter:@{@"productid": model.goodsID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            [self.dataArray removeObject:model];
            [self.goodsTableView reloadData];
            if (self.block) {
                self.block();
            }
            [MBProgressHUD showError:msg];
        }
    } fail:^{
    }];
}

- (void)delateGoods:(SWLiveGoodsModel *)model {
    [MBProgressHUD showMessage:@""];
    [SWToolClass postNetworkWithUrl:@"shopdel" andParameter:@{@"productid": model.goodsID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            [self.dataArray removeObject:model];
            [self.goodsTableView reloadData];
            if (self.block) {
                self.block();
            }
            [MBProgressHUD showError:msg];
        }
    } fail:^{
    }];
}

@end
