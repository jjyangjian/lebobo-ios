//
//  SWOrderListVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/19.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWOrderListVC.h"
#import "SWOrderCell.h"
#import "SWOrderDetailsVC.h"
#import "SWPayTypeSelectView.h"
#import <WXApi.h>
#import "../../JJNoDataNormalView.h"

@interface SWOrderListVC ()<UITableViewDelegate,UITableViewDataSource,OrderCellControlDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) SWPayTypeSelectView *payTypeView;
@property (nonatomic, strong) SWOrderModel *payModel;
@property (nonatomic, strong) UITableView *orderTableView;
@property (nonatomic, strong) JJNoDataNormalView *noDataView;

@end

@implementation SWOrderListVC
- (UITableView *)orderTableView{
    if (!_orderTableView) {
        _orderTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height-(64 +statusbarHeight + 153) -ShowDiff) style:0];
        _orderTableView.delegate = self;
        _orderTableView.dataSource = self;
        _orderTableView.separatorStyle = 0;
        _orderTableView.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
        _orderTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.page = 1;
            [self requestData];
        }];
        _orderTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            self.page ++;
            [self requestData];
        }];
    }
    return _orderTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWOrderCell" owner:nil options:nil] lastObject];
        if ([self.orderType isEqual:@"1"] || [self.orderType isEqual:@"2"]) {
            cell.leftBtn.hidden = YES;
            [cell.rightBtn setTitle:@"查看详情" forState:0];
            cell.rightBtn.userInteractionEnabled = NO;
        }
        if ([self.orderType isEqual:@"3"]) {
            cell.leftBtn.hidden = YES;
            [cell.rightBtn setTitle:@"去评价" forState:0];
            cell.rightBtn.userInteractionEnabled = NO;
        }
        if ([self.orderType isEqual:@"4"]) {
            [cell.leftBtn setTitle:@"再次购买" forState:0];
            [cell.leftBtn setBackgroundColor:normalColors];
            [cell.leftBtn setTitleColor:[UIColor whiteColor] forState:0];
            [cell.leftBtn setBorderColor:[UIColor clearColor]];
            [cell.rightBtn setTitle:@"删除订单" forState:0];
            [cell.rightBtn setBackgroundColor:[UIColor whiteColor]];
            [cell.rightBtn setTitleColor:RGB_COLOR(@"#A9A9A9", 1) forState:0];
            [cell.rightBtn setBorderColor:RGB_COLOR(@"#dddddd", 1)];
            [cell.rightBtn setBorderWidth:1];
        }
    }
    cell.delegate = self;
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWOrderModel *model = self.dataArray[indexPath.row];
    return model.rowH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [MBProgressHUD showMessage:@""];
    SWOrderModel *model = self.dataArray[indexPath.row];
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"order/detail/%@?status=0",model.orderNums] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            SWOrderDetailsVC *vc = [[SWOrderDetailsVC alloc]init];
            vc.orderMessage = info;
            vc.isCart = NO;
            vc.orderType = 0;
            WeakSelf;
            vc.block = ^{
                [self.dataArray removeObject:model];
                [weakSelf.orderTableView reloadData];
                if (weakSelf.block) {
                    weakSelf.block();
                }
            };
            [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
        }
    } Fail:^{

    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
    self.dataArray = [NSMutableArray array];
    self.page = 1;
    [self.view addSubview:self.orderTableView];
    {
        JJNoDataNormalView *noDataView = [[JJNoDataNormalView alloc] initWithFrame:self.orderTableView.bounds];
        noDataView.hidden = YES;
        noDataView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.orderTableView.backgroundView = noDataView;
        self.noDataView = noDataView;
    }
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated{
    if ([self.orderType isEqual:@"0"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxPayResult:) name:WYWXApiPaySuccess object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    if ([self.orderType isEqual:@"0"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)requestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"order/list?type=%@&status=0&page=%ld", self.orderType, (long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.orderTableView.mj_header endRefreshing];
        [self.orderTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
                if (self.block) {
                    self.block();
                }
            }
            for (NSDictionary *dic in info) {
                SWOrderModel *modle = [[SWOrderModel alloc]initWithDic:dic];
                [self.dataArray addObject:modle];
            }
            if ([info count] < 20) {
                [self.orderTableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.orderTableView reloadData];
            self.noDataView.hidden = (self.dataArray.count != 0);
        }
    } Fail:^{
        [self.orderTableView.mj_header endRefreshing];
        [self.orderTableView.mj_footer endRefreshing];
    }];
}

- (void)doRemoveCurrentOrder:(SWOrderModel *)model{
    [self.dataArray removeObject:model];
    [self.orderTableView reloadData];
    self.noDataView.hidden = (self.dataArray.count != 0);
    if (self.block) {
        self.block();
    }
}

- (void)doPayOrder:(SWOrderModel *)model{
    self.payModel = model;
    if (!self.payTypeView) {
        self.payTypeView = [[SWPayTypeSelectView alloc] init];
        WeakSelf;
        self.payTypeView.block = ^(NSString * _Nonnull type) {
            [weakSelf payOrderWithType:type andSWOrderModel:model];
        };
        [[UIApplication sharedApplication].keyWindow addSubview:self.payTypeView];
    }else{
        [self.payTypeView show];
    }
}

- (void)payOrderWithType:(NSString *)type andSWOrderModel:(SWOrderModel *)model{
    [MBProgressHUD showMessage:@"订单支付中"];
    [SWToolClass postNetworkWithUrl:@"order/pay" andParameter:@{@"uni":model.orderNums,@"paytype":type,@"from":@"ios"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            if ([type isEqual:@"yue"]) {
                [self doRemoveCurrentOrder:model];
                [MBProgressHUD showError:msg];
            }else{
                NSDictionary *result = [info valueForKey:@"result"];
                NSDictionary *jsConfig = [result valueForKey:@"jsConfig"];
                [WXApi registerApp:minstr([jsConfig valueForKey:@"appid"]) universalLink:WechatUniversalLink];
                NSString *times = [jsConfig objectForKey:@"timestamp"];
                PayReq* req = [[PayReq alloc] init];
                req.partnerId = [jsConfig objectForKey:@"partnerid"];
                NSString *pid = [NSString stringWithFormat:@"%@", [jsConfig objectForKey:@"prepayid"]];
                if ([pid isEqual:[NSNull null]] || pid == NULL || [pid isEqual:@"null"]) {
                    pid = @"123";
                }
                req.prepayId = pid;
                req.nonceStr = [jsConfig objectForKey:@"noncestr"];
                req.timeStamp = times.intValue;
                req.package = [jsConfig objectForKey:@"package"];
                req.sign = [jsConfig objectForKey:@"sign"];
                [WXApi sendReq:req completion:^(BOOL success) {

                }];
            }
        }
    } fail:^{

    }];
}

- (void)wxPayResult:(NSNotification *)not{
    [MBProgressHUD hideHUD];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    PayResp *response = not.object;
    switch (response.errCode)
    {
        case WXSuccess:
            NSLog(@"支付成功");
            [self doRemoveCurrentOrder:self.payModel];
            [MBProgressHUD showError:@"支付成功"];
            break;
        case WXErrCodeUserCancel:
            [MBProgressHUD showError:@"已取消支付"];
            break;
        default:
            [MBProgressHUD showError:@"支付失败"];
            break;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
