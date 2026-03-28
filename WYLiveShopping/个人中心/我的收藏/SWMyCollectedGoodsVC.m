//
//  SWMyCollectedGoodsVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/9.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWMyCollectedGoodsVC.h"
#import "SWRecommendView.h"
#import "SWCollectGoodsCell.h"
#import "SWGoodsDetailsViewController.h"

@interface SWMyCollectedGoodsVC ()<UITableViewDelegate,UITableViewDataSource,SWCollectGoodsCellDelegate>
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) SWRecommendView *recommendV;
@property (nonatomic, strong) UITableView *collectTableView;

@end

@implementation SWMyCollectedGoodsVC
- (SWRecommendView *)recommendV{
    if (!_recommendV) {
        _recommendV = [[SWRecommendView alloc]initWithFrame:CGRectMake(0, 0, _window_width, self.collectTableView.height) andNothingImage:[UIImage imageNamed:@"noCollection"]];
        _recommendV.hidden = YES;
    }
    return _recommendV;
}

- (UITableView *)collectTableView{
    if (!_collectTableView) {
        _collectTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, _window_height- (self.naviView.bottom + ShowDiff)) style:0];
        _collectTableView.delegate = self;
        _collectTableView.dataSource = self;
        _collectTableView.separatorStyle = 0;
        _collectTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.page = 1;
            [self requestData];
        }];
        _collectTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            self.page ++;
            [self requestData];
        }];
    }
    return _collectTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"收藏商品";
    self.page = 1;
    self.dataArray = [NSMutableArray array];
    [self.view addSubview:self.collectTableView];
    [self requestData];
}

- (void)requestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"collect/user?page=%ld&limit=20", (long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.collectTableView.mj_header endRefreshing];
        [self.collectTableView.mj_footer endRefreshing];

        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                SWCollectGoodsModel *model = [[SWCollectGoodsModel alloc]initWithDic:dic];
                [self.dataArray addObject:model];
            }
            [self.collectTableView reloadData];
            if (self.dataArray.count == 0) {
                if (!self.recommendV.superview) {
                    [self.collectTableView addSubview:self.recommendV];
                }
                self.recommendV.hidden = NO;
            }else{
                self.recommendV.hidden = YES;
                if ([info count] < 20) {
                    [self.collectTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
        }
    } Fail:^{
        [self.collectTableView.mj_header endRefreshing];
        [self.collectTableView.mj_footer endRefreshing];

    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWCollectGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collectGoodsCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWCollectGoodsCell" owner:nil options:nil] lastObject];
        cell.delegate = self;
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SWGoodsDetailsViewController *vc = [[SWGoodsDetailsViewController alloc]init];
    SWCollectGoodsModel *model = self.dataArray[indexPath.row];
    vc.goodsID = model.pid;
    vc.liveUid = @"";
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)removeCollected:(SWCollectGoodsModel *)model{
    [MBProgressHUD showMessage:@""];
    [SWToolClass postNetworkWithUrl:@"collect/del" andParameter:@{@"id":model.pid,@"category":model.category} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            [MBProgressHUD showSuccess:@"取消收藏成功"];
            [self.dataArray removeObject:model];
            [self.collectTableView reloadData];
            if (self.dataArray.count == 0) {
                if (!self.recommendV.superview) {
                    [self.collectTableView addSubview:self.recommendV];
                }
                self.recommendV.hidden = NO;
            }
        }
    } fail:^{

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
