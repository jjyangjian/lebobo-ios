//
//  SWSpreadTixianjiluVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/9.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWSpreadTixianjiluVC.h"
#import "SWCommissionCell.h"

@interface SWSpreadTixianjiluVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) UIImageView *nothingImgView;

@end

@implementation SWSpreadTixianjiluVC
- (UIImageView *)nothingImgView{
    if (!_nothingImgView) {
        _nothingImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 80, _window_width, _window_width*0.55)];
        _nothingImgView.image = [UIImage imageNamed:@"noTixian"];
        _nothingImgView.contentMode = UIViewContentModeScaleAspectFit;
        _nothingImgView.hidden = YES;
    }
    return _nothingImgView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"提现记录";
    self.page = 1;
    self.dataArray = [NSMutableArray array];
    self.listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, _window_height-64-statusbarHeight) style:0];
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    self.listTableView.separatorStyle = 0;
    [self.view addSubview:self.listTableView];
    self.listTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        [self requestData];
    }];
    self.listTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        self.page ++;
        [self requestData];
    }];
    [self.listTableView addSubview:self.nothingImgView];

    [self requestData];
}

- (NSAttributedString *)setAttText:(NSString *)nums{
    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"佣金记录\n¥ %@",nums]];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;

    [muStr addAttributes:@{NSFontAttributeName:SYS_Font(25)} range:NSMakeRange(7, nums.length)];
    [muStr addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, muStr.length)];
    return muStr;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *list = [self.dataArray[section] valueForKey:@"list"];
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWCommissionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commissionCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWCommissionCell" owner:nil options:nil] lastObject];
    }
    NSArray *list = [self.dataArray[indexPath.section] valueForKey:@"list"];
    NSDictionary *dic = list[indexPath.row];
    cell.titleL.text = minstr([dic valueForKey:@"title"]);
    cell.timeL.text = minstr([dic valueForKey:@"add_time"]);
    cell.moneyL.text = [NSString stringWithFormat:@"¥ %@",minstr([dic valueForKey:@"number"])];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)requestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"spread/commission/4?page=%ld&limit=20", (long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.listTableView.mj_header endRefreshing];
        [self.listTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            [self.dataArray addObjectsFromArray:info];
            [self.listTableView reloadData];
            if ([info count] < 20) {
                [self.listTableView.mj_footer endRefreshingWithNoMoreData];
            }
            self.nothingImgView.hidden = (self.dataArray.count != 0);
        }
    } Fail:^{
        [self.listTableView.mj_header endRefreshing];
        [self.listTableView.mj_footer endRefreshing];
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
