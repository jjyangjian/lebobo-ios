//
//  spreadTixianjiluViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/9.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "spreadTixianjiluViewController.h"
#import "commissionCell.h"

@interface spreadTixianjiluViewController ()<UITableViewDelegate,UITableViewDataSource>{
    int page;
    NSMutableArray *dataArray;
    UITableView *listTableView;
}
@property (nonatomic,strong) UIImageView *nothingImgView;

@end

@implementation spreadTixianjiluViewController
-(UIImageView *)nothingImgView{
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
    page = 1;
    dataArray = [NSMutableArray array];
    listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, _window_height-64-statusbarHeight) style:0];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    listTableView.separatorStyle = 0;
    [self.view addSubview:listTableView];
    listTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        [self requestData];
    }];
    listTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        page ++;
        [self requestData];
    }];
    [listTableView addSubview:self.nothingImgView];

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
    return dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *list = [dataArray[section] valueForKey:@"list"];
    return list.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    commissionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commissionCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"commissionCell" owner:nil options:nil] lastObject];
    }
    NSArray *list = [dataArray[indexPath.section] valueForKey:@"list"];
    NSDictionary *dic = list[indexPath.row];
    cell.titleL.text = minstr([dic valueForKey:@"title"]);
    cell.timeL.text = minstr([dic valueForKey:@"add_time"]);
//    if ([minstr([dic valueForKey:@"pm"]) isEqual:@"0"]) {
        cell.moneyL.text = [NSString stringWithFormat:@"¥ %@",minstr([dic valueForKey:@"number"])];
//        cell.moneyL.textColor = normalColors;
//    }else{
//        cell.moneyL.text = [NSString stringWithFormat:@"+%@",minstr([dic valueForKey:@"number"])];
//        cell.moneyL.textColor = RGB_COLOR(@"#00ad59", 1);
//    }
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)requestData{
//    0 全部  1 消费  2 充值  3 返佣  4 提现
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"spread/commission/4?page=%d&limit=20",page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [listTableView.mj_header endRefreshing];
        [listTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (page == 1) {
                [dataArray removeAllObjects];
            }
            [dataArray addObjectsFromArray:info];
            [listTableView reloadData];
            if ([info count] < 20) {
                [listTableView.mj_footer endRefreshingWithNoMoreData];
            }
            if ([dataArray count] == 0) {
                _nothingImgView.hidden = NO;
            }else{
                _nothingImgView.hidden = YES;
            }

        }
    } Fail:^{
        [listTableView.mj_header endRefreshing];
        [listTableView.mj_footer endRefreshing];
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
