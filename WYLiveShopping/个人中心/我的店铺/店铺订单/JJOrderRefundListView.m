//
//  JJOrderRefundListView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2026/3/27.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import "JJOrderRefundListView.h"
#import "ReturnOrderCell.h"
#import "orderModel.h"

@interface JJOrderRefundListView ()

@end

@implementation JJOrderRefundListView

- (void)configUI {
    [super configUI];
}

- (void)requestData {
    NSString *url = [NSString stringWithFormat:@"order/list?type=-3&status=%@&page=%d", self.statusType, self.page];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    orderModel *oModel = self.dataArray[section];
    return oModel.goodsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReturnOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReturnOrderCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReturnOrderCell" owner:nil options:nil] lastObject];
    }
    
    orderModel *oModel = self.dataArray[indexPath.section];
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
    
    orderModel *model = self.dataArray[section];
    
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
    
    orderModel *model = self.dataArray[section];
    
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

@end
