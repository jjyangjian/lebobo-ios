//
//  WYGetCouponViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/3.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYGetCouponViewController.h"
#import "WYCouponTableViewCell.h"

@interface WYGetCouponViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *couponTableV;
    NSMutableArray *dataArray;
    int p;
}

@end

@implementation WYGetCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"领券中心";

    self.view.backgroundColor = [UIColor clearColor];

    dataArray = [NSMutableArray array];
    p = 1;
    couponTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, _window_height- (64+statusbarHeight)) style:0];
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
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"coupons?type=0&page=%d",p] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [couponTableV.mj_header endRefreshing];
        [couponTableV.mj_footer endRefreshing];

        if (code == 200) {
            if (p == 1) {
                [dataArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                couponModel *model = [[couponModel alloc]initWithDic:dic];
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
        cell.isHome = YES;
        [cell.controlBtn setTitle:@"已领取" forState:UIControlStateSelected];
        [cell.controlBtn setBackgroundImage:[WYToolClass getImgWithColor:[UIColor clearColor]] forState:UIControlStateSelected];
        [cell.controlBtn setBackgroundImage:[WYToolClass getImgWithColor:[UIColor whiteColor]] forState:0];
        [cell.controlBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

    }
    cell.model = dataArray[indexPath.row];
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
