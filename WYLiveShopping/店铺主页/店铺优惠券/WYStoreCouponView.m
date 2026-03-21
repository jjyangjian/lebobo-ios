//
//  WYStoreCouponView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYStoreCouponView.h"
#import "WYCouponTableViewCell.h"
@interface WYStoreCouponView()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *couponTableV;
    NSMutableArray *dataArray;
    int page;
    NSString *mer_id;
}
@end
@implementation WYStoreCouponView

-(instancetype)initWithFrame:(CGRect)frame andStoreID:(NSString *)sid{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGB_COLOR(@"#fafafa", 1);
        mer_id = sid;
        dataArray = [NSMutableArray array];
        page = 1;
        couponTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height) style:0];
        couponTableV.delegate = self;
        couponTableV.dataSource = self;
        couponTableV.separatorStyle = 0;
        couponTableV.backgroundColor = RGB_COLOR(@"#fafafa", 1);
        if (@available(iOS 11.0, *)) {
            couponTableV.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        [self addSubview:couponTableV];
        
        couponTableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            page = 1;
            [self requeestData];
        }];
        couponTableV.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
            page ++;
            [self requeestData];
        }];
        [self requeestData];
    }
    return self;
}
- (void)requeestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"coupons?type=0&mer_id=%@&page=%d",mer_id,page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [couponTableV.mj_header endRefreshing];
        [couponTableV.mj_footer endRefreshing];

        if (code == 200) {
            if (page == 1) {
                [dataArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                couponModel *model = [[couponModel alloc]initWithDic:dic];
                model.isDraw = YES;
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
        cell.rightImgView.hidden = YES;
        cell.homeBtn.hidden = YES;
        [cell.controlBtn setBackgroundImage:[WYToolClass getImgWithColor:[UIColor whiteColor]] forState:0];
        [cell.controlBtn setTitle:@"已领取" forState:UIControlStateSelected];
        [cell.controlBtn setBackgroundImage:[WYToolClass getImgWithColor:[UIColor clearColor]] forState:UIControlStateSelected];
        [cell.controlBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        cell.isHome = NO;
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

@end
