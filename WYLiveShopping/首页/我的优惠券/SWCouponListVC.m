//
//  SWCouponListVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWCouponListVC.h"
#import "SWCouponTableViewCell.h"

@interface SWCouponListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *couponTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) NSInteger page;

@end

@implementation SWCouponListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor clearColor];

    self.dataArray = [NSMutableArray array];
    self.page = 1;
    self.couponTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height- (64+statusbarHeight)) style:0];
    self.couponTableView.delegate = self;
    self.couponTableView.dataSource = self;
    self.couponTableView.separatorStyle = 0;
    self.couponTableView.backgroundColor = RGB_COLOR(@"#fafafa", 1);
    if (@available(iOS 11.0, *)) {
        self.couponTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self.view addSubview:self.couponTableView];
    
    self.couponTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        [self requeestData];
    }];
    self.couponTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        self.page ++;
        [self requeestData];
    }];
    [self requeestData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.couponTableView.mj_header endRefreshing];
    [self.couponTableView.mj_footer endRefreshing];
}
- (void)requeestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"coupons/user/%@?page=%ld",_types,(long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.couponTableView.mj_header endRefreshing];
        [self.couponTableView.mj_footer endRefreshing];

        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                SWCouponModel *model = [[SWCouponModel alloc]initWithDic:dic];
                model.is_use = @"1";
                [self.dataArray addObject:model];
            }
            
            [self.couponTableView reloadData];
            if (self.dataArray.count == 0) {
//                _nothingImgView.hidden = NO;
            }
        }
    } Fail:^{
        [self.couponTableView.mj_header endRefreshing];
        [self.couponTableView.mj_footer endRefreshing];
    }];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WYCouponTableViewCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWCouponTableViewCell" owner:nil options:nil] lastObject];
        [cell.controlBtn setBackgroundImage:[SWToolClass getImgWithColor:[UIColor whiteColor]] forState:0];

        cell.isHome = YES;
        if ([_types isEqual:@"3"]) {
            cell.couponImgView.image = [UIImage imageNamed:@"coupon-enable"];
            [cell.controlBtn setTitle:@"删除" forState:UIControlStateSelected];
            [cell.controlBtn setTitle:@"删除" forState:0];
            [cell.controlBtn setTitleColor:color96 forState:UIControlStateSelected];
            cell.controlBtn.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }
    cell.model = self.dataArray[indexPath.row];
    cell.block = ^(SWCouponModel * _Nonnull mod) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dataArray removeObject:mod];
            [self.couponTableView reloadData];
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
