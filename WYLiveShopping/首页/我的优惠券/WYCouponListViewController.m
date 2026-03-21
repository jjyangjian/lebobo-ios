//
//  WYCouponListViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYCouponListViewController.h"
#import "WYCouponTableViewCell.h"

@interface WYCouponListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *couponTableV;
    NSMutableArray *dataArray;
    int p;
}

@end

@implementation WYCouponListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor clearColor];

    dataArray = [NSMutableArray array];
    p = 1;
    couponTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height- (64+statusbarHeight)) style:0];
    couponTableV.delegate = self;
    couponTableV.dataSource = self;
    couponTableV.separatorStyle = 0;
    couponTableV.backgroundColor = RGB_COLOR(@"#fafafa", 1);
    if (@available(iOS 11.0, *)) {
        couponTableV.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self.view addSubview:couponTableV];
    
    couponTableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        p = 1;
        [self requeestData];
    }];
    couponTableV.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        p ++;
        [self requeestData];
    }];
    [self requeestData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [couponTableV.mj_header endRefreshing];
    [couponTableV.mj_footer endRefreshing];
}
- (void)requeestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"coupons/user/%@?page=%d",_types,p] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [couponTableV.mj_header endRefreshing];
        [couponTableV.mj_footer endRefreshing];

        if (code == 200) {
            if (p == 1) {
                [dataArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                couponModel *model = [[couponModel alloc]initWithDic:dic];
                model.is_use = @"1";
                [dataArray addObject:model];
            }
            
            [couponTableV reloadData];
            if (dataArray.count == 0) {
//                _nothingImgView.hidden = NO;
            }
        }
    } Fail:^{
        [couponTableV.mj_header endRefreshing];
        [couponTableV.mj_footer endRefreshing];
    }];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WYCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WYCouponTableViewCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WYCouponTableViewCell" owner:nil options:nil] lastObject];
        [cell.controlBtn setBackgroundImage:[WYToolClass getImgWithColor:[UIColor whiteColor]] forState:0];

        cell.isHome = YES;
        if ([_types isEqual:@"3"]) {
            cell.couponImgView.image = [UIImage imageNamed:@"coupon-enable"];
            [cell.controlBtn setTitle:@"删除" forState:UIControlStateSelected];
            [cell.controlBtn setTitle:@"删除" forState:0];
            [cell.controlBtn setTitleColor:color96 forState:UIControlStateSelected];
            cell.controlBtn.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }
    cell.model = dataArray[indexPath.row];
    cell.block = ^(couponModel * _Nonnull mod) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [dataArray removeObject:mod];
            [couponTableV reloadData];
        });
    };
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
