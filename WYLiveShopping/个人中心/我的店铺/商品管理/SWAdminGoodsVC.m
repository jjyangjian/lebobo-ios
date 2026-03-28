//
//  SWAdminGoodsVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/22.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWAdminGoodsVC.h"
#import "SWAddGoodsCell.h"
#import "SWGoodsDetailsViewController.h"
#import "../../../JJNoDataNormalView.h"

@interface SWAdminGoodsVC ()<UITableViewDelegate,UITableViewDataSource,AddGoodsCellDelegate>
@property (nonatomic, strong) UITableView *goodsTableView;
@property (nonatomic, strong) JJNoDataNormalView *noDataView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int page;
@property (nonatomic, copy) NSString *keywords;

@end

@implementation SWAdminGoodsVC

- (void)doSearchGoods {
    self.page = 1;
    [self requestData];
}

- (UITableView *)goodsTableView {
    if (!_goodsTableView) {
        _goodsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height - (110 + statusbarHeight + 50) - ShowDiff) style:0];
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
    self.keywordStr = @"";
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
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"shopaddlist?page=%d&cid=%@sid=&keyword=%@", self.page, self.cid, self.keywordStr] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.goodsTableView.mj_header endRefreshing];
        [self.goodsTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                SWLiveGoodsModel *model = [[SWLiveGoodsModel alloc] initWithDic:dic];
                model.isAdmin = YES;
                model.is_sale = @"0";
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
    SWAddGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddGoodsCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWAddGoodsCell" owner:nil options:nil] lastObject];
        [cell.addBtn setTitle:@"一键添加" forState:0];
        cell.delegate = self;
        cell.btnWidth.constant = 70;
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SWGoodsDetailsViewController *vc = [[SWGoodsDetailsViewController alloc] init];
    SWLiveGoodsModel *model = self.dataArray[indexPath.row];
    vc.goodsID = model.goodsID;
    vc.isAdd = YES;
    vc.liveUid = @"";
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (void)addGoodsChange:(SWLiveGoodsModel *)model {
    [self.dataArray removeObject:model];
    [self.goodsTableView reloadData];
}

@end
