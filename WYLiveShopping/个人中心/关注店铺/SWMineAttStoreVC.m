//
//  SWMineAttStoreVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/3.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWMineAttStoreVC.h"
#import "SWStoreCell.h"
#import "SWStoreHomeTbabarViewController.h"

@interface SWMineAttStoreVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *storeTableView;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation SWMineAttStoreVC
- (void)requestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"shopattent&page=%ld",(long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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
        [self.storeTableView.mj_header endRefreshing];
        [self.storeTableView.mj_footer endRefreshing];
    }];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"关注店铺";
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
        _storeTableView.backgroundColor = [UIColor whiteColor];
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
    SWStoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WYStoreCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWStoreCell" owner:nil options:nil] lastObject];
    }
    NSDictionary *dic = self.dataArray[indexPath.row];
    [cell.thumbImgV sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"avatar"])]];
    cell.nameL.text = minstr([dic valueForKey:@"nickname"]);
    cell.fansNumsL.text = [NSString stringWithFormat:@"粉丝 %@",minstr([dic valueForKey:@"fans"])];
    cell.adressL.text = minstr([dic valueForKey:@"addr"]);
    if ([minstr([dic valueForKey:@"shoptype"]) isEqual:@"2"]) {
        cell.typeView.hidden = NO;
    }else{
        cell.typeView.hidden = YES;
    }

    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
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
