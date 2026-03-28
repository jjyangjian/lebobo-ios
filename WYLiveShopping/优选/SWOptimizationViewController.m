//
//  SWOptimizationViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/15.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWOptimizationViewController.h"
#import "SWOptimizationCell.h"
#import "SWGoodsDetailsViewController.h"

@interface SWOptimizationViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UITableView *optimizationTableView;
@end

@implementation SWOptimizationViewController

- (void)addHeaderView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight, _window_width, 44)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];

    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"今日优选"];
    [view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(10);
        make.bottom.equalTo(view).offset(-6.5);
        make.width.height.mas_equalTo(18);
    }];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"今日优选";
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(7);
        make.centerY.equalTo(imageView);
    }];

    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.text = @"  每天9点更新  ";
    self.timeLabel.backgroundColor = [normalColors colorWithAlphaComponent:0.2];
    self.timeLabel.textColor = normalColors;
    self.timeLabel.layer.cornerRadius = 8.5;
    self.timeLabel.layer.masksToBounds = YES;
    self.timeLabel.font = SYS_Font(10);
    [view addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(10);
        make.centerY.equalTo(imageView);
        make.height.mas_equalTo(17);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"今日优选";
    self.dataArray = [NSMutableArray array];
    self.page = 1;
    [self addHeaderView];
    [self.view addSubview:self.optimizationTableView];
    [self requestData];
}

- (UITableView *)optimizationTableView {
    if (!_optimizationTableView) {
        _optimizationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + 44 + statusbarHeight, _window_width, _window_height - (64 + 44 + statusbarHeight)) style:0];
        _optimizationTableView.delegate = self;
        _optimizationTableView.dataSource = self;
        _optimizationTableView.separatorStyle = 0;
        _optimizationTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.page = 1;
            [self requestData];
        }];
        _optimizationTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            self.page++;
            [self requestData];
        }];
    }
    return _optimizationTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWOptimizationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptimizationCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWOptimizationCell" owner:nil options:nil] lastObject];
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWOptimizationModel *model = self.dataArray[indexPath.row];
    CGFloat width = [[SWToolClass sharedInstance] widthOfString:model.name andFont:[UIFont boldSystemFontOfSize:14] andHeight:20];
    if (width > (_window_width - 20)) {
        return (_window_width - 20) * 0.436 + 95.5;
    }
    return (_window_width - 20) * 0.436 + 75.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SWOptimizationModel *model = self.dataArray[indexPath.row];
    SWGoodsDetailsViewController *vc = [[SWGoodsDetailsViewController alloc] init];
    vc.goodsID = model.goodsID;
    vc.liveUid = @"";
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)requestData {
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"product/day?page=%d", self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.optimizationTableView.mj_header endRefreshing];
        [self.optimizationTableView.mj_footer endRefreshing];
        if (code == 200) {
            self.timeLabel.text = [NSString stringWithFormat:@"  %@  ", minstr([info valueForKey:@"tips"])];
            NSArray *list = [info valueForKey:@"list"];
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            for (NSDictionary *dictionary in list) {
                SWOptimizationModel *model = [[SWOptimizationModel alloc] initWithDic:dictionary];
                [self.dataArray addObject:model];
            }
            [self.optimizationTableView reloadData];
            if (list.count < 20) {
                [self.optimizationTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } Fail:^{
        [self.optimizationTableView.mj_header endRefreshing];
        [self.optimizationTableView.mj_footer endRefreshing];
    }];
}

@end
