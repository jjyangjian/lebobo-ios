//
//  SWReturnOrderListVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWReturnOrderListVC.h"
#import "SWReturnOrderCell.h"
#import "SWOrderModel.h"
#import "SWReturnOrderDetailsVC.h"
#import "../../../JJNoDataNormalView.h"
@interface SWReturnOrderListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) UITableView *orderTableView;
@property (nonatomic, strong) JJNoDataNormalView *noDataView;

@end

@implementation SWReturnOrderListVC
- (UITableView *)orderTableView{
    if (!_orderTableView) {
        _orderTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, _window_height-(64 +statusbarHeight)) style:1];
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
        if (@available(iOS 15.0, *)) {
            _orderTableView.sectionHeaderTopPadding = 0;
        } else {
            // Fallback on earlier versions
        }
    }
    return _orderTableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SWOrderModel *oModel = self.dataArray[section];
    return oModel.goodsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWReturnOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReturnOrderCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWReturnOrderCell" owner:nil options:nil] lastObject];
    }
    SWOrderModel *oModel = self.dataArray[indexPath.section];
    cell.model = oModel.goodsArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 43;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 43)];
    view.backgroundColor = [UIColor whiteColor];
    view.clipsToBounds = NO;
    UIImageView *imgV = [[UIImageView alloc]init];
    imgV.image = [UIImage imageNamed:@"小店"];
    [view addSubview:imgV];
    [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.centerY.equalTo(view);
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(16);
    }];
    SWOrderModel *model = self.dataArray[section];
    UILabel *label = [[UILabel alloc]init];
    label.text = model.store_name;
    label.font = SYS_Font(14);
    label.textColor = color32;
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgV.mas_right).offset(8);
        make.centerY.equalTo(view);
    }];
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 42, _window_width, 1) andColor:RGB_COLOR(@"#eeeeee", 1) andView:view];

    UIImageView *statusImgV = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width-65, 8, 50, 50)];
    if ([model.refund_status isEqual:@"2"]) {
        statusImgV.image = [UIImage imageNamed:@"已退款"];
    }else{
        statusImgV.image = [UIImage imageNamed:@"退款中"];
    }
    [view addSubview:statusImgV];

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 43)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *totalLabel = [[UILabel alloc]init];
    totalLabel.font = SYS_Font(14);
    totalLabel.textColor = color32;
    [view addSubview:totalLabel];
    [totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).offset(-15);
        make.centerY.equalTo(view).offset(-2.5);
    }];
    SWOrderModel *model = self.dataArray[section];
    totalLabel.attributedText = [self getAttStrWithNums:model.total_num andTotalMoney:model.total_price];
    [[SWToolClass sharedInstance]lineViewWithFrame:CGRectMake(0, 43, _window_width, 5) andColor:colorf0 andView:view];
    return view;
}

- (NSAttributedString *)getAttStrWithNums:(NSString *)nums andTotalMoney:(NSString *)money{
    NSMutableAttributedString *mustr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"共%@件商品 总金额：¥%@",nums,money]];
    [mustr setAttributes:@{NSForegroundColorAttributeName:normalColors,NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} range:NSMakeRange(mustr.length-money.length-1, money.length+1)];
    return mustr;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [MBProgressHUD showMessage:@""];
    SWOrderModel *model = self.dataArray[indexPath.section];
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"order/detail/%@?status=0",model.orderNums] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            SWReturnOrderDetailsVC *vc = [[SWReturnOrderDetailsVC alloc]init];
            vc.orderMessage = info;
            [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
        }
    } Fail:^{

    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"退货列表";
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

- (void)requestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"order/list?type=-3&status=0&page=%ld", (long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.orderTableView.mj_header endRefreshing];
        [self.orderTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
