//
//  JJOrderPendingShipmentListView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2026/3/27.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import "JJOrderPendingShipmentListView.h"
#import "OrderCell.h"
#import "orderModel.h"

@interface JJOrderPendingShipmentListView ()

@end

@implementation JJOrderPendingShipmentListView

- (void)configUI {
    [super configUI];
}

- (void)requestData {
    NSString *url = [NSString stringWithFormat:@"order/list?type=1&status=%@&page=%d", self.statusType, self.page];
    __weak typeof(self) weakSelf = self;
    [WYToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [strongSelf.tableView.mj_header endRefreshing];
        [strongSelf.tableView.mj_footer endRefreshing];
        
        if (code == 200) {
            if (strongSelf.page == 1) {
                [strongSelf.dataArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                orderModel *model = [[orderModel alloc] initWithDic:dic];
                [strongSelf.dataArray addObject:model];
            }
            if ([info count] < 20) {
                [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [strongSelf.tableView reloadData];
            [strongSelf updateNoDataViewHidden];
            
            if (strongSelf.refreshBlock) {
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

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OrderCell" owner:nil options:nil] lastObject];
        cell.store_nameL.hidden = YES;
        cell.storeImgView.hidden = YES;
        cell.leftBtn.hidden = YES;
        [cell.rightBtn setTitle:@"查看详情" forState:0];
        cell.rightBtn.userInteractionEnabled = NO;
    }
    
    orderModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    cell.timeL.text = model.add_time;
    cell.allPriceL.text = [NSString stringWithFormat:@"¥ %@", model.total_price];
    
    if ([self.statusType isEqual:@"1"]) {
        cell.profitLabel.text = [NSString stringWithFormat:@"代销收益 ¥ %@", model.bring_price];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    orderModel *model = self.dataArray[indexPath.row];
    return model.rowH;
}

@end