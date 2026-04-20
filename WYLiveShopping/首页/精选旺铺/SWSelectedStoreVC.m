//
//  SWSelectedStoreVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/3.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWSelectedStoreVC.h"
#import "SWSelectedStoreCell.h"
#import "SWStoreHomeTbabarViewController.h"
@interface SWSelectedStoreVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *storeTableView;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation SWSelectedStoreVC
- (void)requestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"business&page=%ld",(long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.storeTableView.mj_header endRefreshing];
        [self.storeTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            [self.dataArray addObjectsFromArray:info];
            [self.storeTableView reloadData];
        }
    } Fail:^{
        
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"精选旺铺";
    self.page = 1;
    self.dataArray = [NSMutableArray array];
    [self.view addSubview:self.storeTableView];
    [self requestData];
}
- (UITableView *)storeTableView{
    if (!_storeTableView) {
        _storeTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, _window_height-(self.naviView.bottom)) style:0];
        _storeTableView.delegate = self;
        _storeTableView.dataSource = self;
        _storeTableView.separatorStyle = 0;
        _storeTableView.backgroundColor = colorf0;
        _storeTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.page = 1;
            [self requestData];
        }];
        _storeTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            self.page ++;
            [self requestData];
        }];
    }
    return _storeTableView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWSelectedStoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectedStoreCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWSelectedStoreCell" owner:nil options:nil] lastObject];
        cell.imageArray = @[cell.goodsImgV1,cell.goodsImgV2,cell.goodsImgV3,cell.goodsImgV4];
    }
    cell.subDic = self.dataArray[indexPath.row];
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 97 + (_window_width-20)*0.17;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = self.dataArray[indexPath.row];
    SWStoreHomeTbabarViewController *vc = [[SWStoreHomeTbabarViewController alloc]initWithID:minstr([dic valueForKey:@"uid"])];
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
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
