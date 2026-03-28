//
//  SWStoreCouponView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWStoreCouponView.h"
#import "SWCouponTableViewCell.h"

@interface SWStoreCouponView()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *couponTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int page;
@property (nonatomic, copy) NSString *storeID;
@end

@implementation SWStoreCouponView

- (instancetype)initWithFrame:(CGRect)frame andStoreID:(NSString *)sid {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGB_COLOR(@"#fafafa", 1);
        self.storeID = sid;
        self.dataArray = [NSMutableArray array];
        self.page = 1;

        self.couponTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:0];
        self.couponTableView.delegate = self;
        self.couponTableView.dataSource = self;
        self.couponTableView.separatorStyle = 0;
        self.couponTableView.backgroundColor = RGB_COLOR(@"#fafafa", 1);
        if (@available(iOS 11.0, *)) {
            self.couponTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:self.couponTableView];

        self.couponTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.page = 1;
            [self requeestData];
        }];
        self.couponTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
            self.page++;
            [self requeestData];
        }];
        [self requeestData];
    }
    return self;
}

- (void)requeestData {
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"coupons?type=0&mer_id=%@&page=%d", self.storeID, self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.couponTableView.mj_header endRefreshing];
        [self.couponTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            for (NSDictionary *dictionary in info) {
                SWCouponModel *model = [[SWCouponModel alloc] initWithDic:dictionary];
                model.isDraw = YES;
                [self.dataArray addObject:model];
            }
            [self.couponTableView reloadData];
        }
    } Fail:^{
        [self.couponTableView.mj_header endRefreshing];
        [self.couponTableView.mj_footer endRefreshing];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WYCouponTableViewCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWCouponTableViewCell" owner:nil options:nil] lastObject];
        cell.rightImgView.hidden = YES;
        cell.homeBtn.hidden = YES;
        [cell.controlBtn setBackgroundImage:[SWToolClass getImgWithColor:[UIColor whiteColor]] forState:0];
        [cell.controlBtn setTitle:@"已领取" forState:UIControlStateSelected];
        [cell.controlBtn setBackgroundImage:[SWToolClass getImgWithColor:[UIColor clearColor]] forState:UIControlStateSelected];
        [cell.controlBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        cell.isHome = NO;
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
