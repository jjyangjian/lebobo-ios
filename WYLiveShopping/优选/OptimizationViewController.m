//
//  OptimizationViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/15.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "OptimizationViewController.h"
#import "OptimizationCell.h"
#import "GoodsDetailsViewController.h"

@interface OptimizationViewController ()<UITableViewDelegate,UITableViewDataSource>{
    int page;
    NSMutableArray *dataArray;
    UILabel *timeLabel;
}
@property (nonatomic,strong) UITableView *optimizationTableView;

@end

@implementation OptimizationViewController
- (void)addHeaderView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, 44)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    UIImageView *imgV = [[UIImageView alloc]init];
    imgV.image = [UIImage imageNamed:@"今日优选"];
    [view addSubview:imgV];
    [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(10);
        make.bottom.equalTo(view).offset(-6.5);
        make.width.height.mas_equalTo(18);
    }];
    UILabel *ttLabel = [[UILabel alloc]init];
    ttLabel.text = @"今日优选";
    ttLabel.font = [UIFont boldSystemFontOfSize:18];
    [view addSubview:ttLabel];
    [ttLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgV.mas_right).offset(7);
        make.centerY.equalTo(imgV);
    }];
    timeLabel = [[UILabel alloc]init];
    timeLabel.text = @"  每天9点更新  ";
    timeLabel.backgroundColor = [normalColors colorWithAlphaComponent:0.2];
    timeLabel.textColor = normalColors;
    timeLabel.layer.cornerRadius = 8.5;
    timeLabel.layer.masksToBounds = YES;
    timeLabel.font = SYS_Font(10);
    [view addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ttLabel.mas_right).offset(10);
        make.centerY.equalTo(imgV);
        make.height.mas_equalTo(17);
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"今日优选";
    dataArray = [NSMutableArray array];
    page = 1;
//    [self.searchBtn setTitle:@"  搜索商品名称" forState:0];
//    self.searchBtn.selected = YES;
    [self addHeaderView];
    [self.view addSubview:self.optimizationTableView];
    [self requestData];
}
-(UITableView *)optimizationTableView{
    if (!_optimizationTableView) {
        _optimizationTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+44+statusbarHeight, _window_width, _window_height-(64+44+statusbarHeight) ) style:0];
        _optimizationTableView.delegate = self;
        _optimizationTableView.dataSource = self;
        _optimizationTableView.separatorStyle = 0;
        _optimizationTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            page = 1;
            [self requestData];
        }];
        _optimizationTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            page ++;
            [self requestData];
        }];
    }
    return _optimizationTableView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OptimizationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptimizationCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OptimizationCell" owner:nil options:nil] lastObject];
    }
    cell.model = dataArray[indexPath.row];
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    optimizationModel *model = dataArray[indexPath.row];
    CGFloat width = [[WYToolClass sharedInstance] widthOfString:model.name andFont:[UIFont boldSystemFontOfSize:14] andHeight:20];
    if (width > (_window_width - 20)) {
        return (_window_width - 20)*0.436 + 95.5;
    }else{
        return (_window_width - 20)*0.436 + 75.5;
    }

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    optimizationModel *model = dataArray[indexPath.row];
    GoodsDetailsViewController *vc = [[GoodsDetailsViewController alloc]init];
    vc.goodsID = model.goodsID;
    vc.liveUid = @"";
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
- (void)requestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"product/day?page=%d",page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_optimizationTableView.mj_header endRefreshing];
        [_optimizationTableView.mj_footer endRefreshing];
        if (code == 200) {
            timeLabel.text = [NSString stringWithFormat:@"  %@  ",minstr([info valueForKey:@"tips"])];
            NSArray *list = [info valueForKey:@"list"];
            if (page == 1) {
                [dataArray removeAllObjects];
            }
            for (NSDictionary *dic in list) {
                optimizationModel *model = [[optimizationModel alloc]initWithDic:dic];
                [dataArray addObject:model];
            }
            [_optimizationTableView reloadData];
            if (list.count < 20) {
                [_optimizationTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } Fail:^{
        [_optimizationTableView.mj_header endRefreshing];
        [_optimizationTableView.mj_footer endRefreshing];
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
