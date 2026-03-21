//
//  WYLiveForGoodsMoreViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/26.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYLiveForGoodsMoreViewController.h"
#import "WYAnliCell.h"
#import "WYAnliDetailsViewController.h"
#import "LivePlayerViewController.h"

@interface WYLiveForGoodsMoreViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *classTableV;
    NSMutableArray *dataArray;
    int p;
}
@end

@implementation WYLiveForGoodsMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"商品关联直播";
    self.view.backgroundColor = colorf0;
    dataArray = [NSMutableArray array];
    p = 1;
    classTableV = [[UITableView alloc]initWithFrame:CGRectMake(10, 64+statusbarHeight, _window_width-20, _window_height- (64+statusbarHeight)) style:0];
    classTableV.delegate = self;
    classTableV.dataSource = self;
    classTableV.separatorStyle = 0;
    classTableV.backgroundColor = [UIColor clearColor];
    classTableV.estimatedRowHeight = 100;
    if (@available(iOS 11.0, *)) {
        classTableV.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self.view addSubview:classTableV];
    classTableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        p = 1;
        [self requeestData];
    }];
    classTableV.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        p ++;
        [self requeestData];
    }];
    [self requeestData];
}
- (void)requeestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"productlive?page=%d&productid=%@",p,_productid] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [classTableV.mj_header endRefreshing];
        [classTableV.mj_footer endRefreshing];
        if (code == 200) {
            if (p == 1) {
                [dataArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                HomeLiveModel *model = [[HomeLiveModel alloc]initWithDic:dic];
                [dataArray addObject:model];
            }
            [classTableV reloadData];
            if ([info count] < 20) {
                [classTableV.mj_footer endRefreshingWithNoMoreData];
            }
        }
        
    } Fail:^{
        [classTableV.mj_header endRefreshing];
        [classTableV.mj_footer endRefreshing];
    }];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WYAnliCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WYAnliCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WYAnliCell" owner:nil options:nil] lastObject];
        [cell.followBtn setBackgroundImage:[WYToolClass getImgWithColor:normalColors] forState:0];
        [cell.followBtn setBackgroundImage:[WYToolClass getImgWithColor:color96] forState:UIControlStateSelected];
        cell.likeBtn.hidden = YES;
    }
    HomeLiveModel *model = dataArray[indexPath.section];
    cell.livemodel = model;
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeLiveModel *model = dataArray[indexPath.section];
    return model.rowH;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HomeLiveModel *model = dataArray[indexPath.row];
    [MBProgressHUD showMessage:@""];
    [[WYToolClass sharedInstance] removeSusPlayer];
    [self checkLive:model];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}
- (void)checkLive:(HomeLiveModel *)model{
    [WYToolClass postNetworkWithUrl:@"live/check" andParameter:@{@"stream":model.stream} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            LivePlayerViewController *player = [[LivePlayerViewController alloc]init];
            player.roomDic = [model.originDic mutableCopy];
            [[MXBADelegate sharedAppDelegate] pushViewController:player animated:YES];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
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
