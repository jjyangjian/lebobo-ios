//
//  SWCommissionHistoryVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWCommissionHistoryVC.h"
#import "SWCommissionCell.h"
@interface SWCommissionHistoryVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) UITableView *listTableView;

@end

@implementation SWCommissionHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.returnBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
    self.lineView.hidden = YES;
    self.naviView.backgroundColor = [UIColor clearColor];
    self.titleL.textColor = [UIColor whiteColor];
    self.titleL.text = @"佣金记录";
    self.dataArray = [NSMutableArray array];
    self.page = 1;
    [self creatHeaderView];
    [self requestData];
}
- (void)creatHeaderView{
    UIImageView *headerImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_width*0.304+64+statusbarHeight)];
    headerImgView.image = [UIImage imageNamed:@"推广头部_背景"];
    headerImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:headerImgView];
    [self.view sendSubviewToBack:headerImgView];
    
    UIImageView *imgV = [[UIImageView alloc]init];
    imgV.image = [UIImage imageNamed:@"佣金记录_white"];
    [headerImgView addSubview:imgV];
    [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(60);
        make.right.equalTo(headerImgView).offset(-45);
        make.bottom.equalTo(headerImgView).offset(-20);
    }];
    UILabel *numsL = [[UILabel alloc]init];
    numsL.textColor = [UIColor whiteColor];
    numsL.numberOfLines = 0;
    numsL.font = SYS_Font(14);
    numsL.attributedText = [self setAttText:_curCommNums];
    [headerImgView addSubview:numsL];
    [numsL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerImgView).offset(25);
        make.centerY.equalTo(imgV);
    }];
    
    self.listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, headerImgView.bottom, _window_width, _window_height-headerImgView.bottom) style:0];
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    self.listTableView.separatorStyle = 0;
    if (@available(iOS 15.0, *)) {
        self.listTableView.sectionHeaderTopPadding = 0;
    } else {
        // Fallback on earlier versions
    }
    [self.view addSubview:self.listTableView];
    self.listTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        [self requestData];
    }];
    self.listTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        self.page ++;
        [self requestData];
    }];
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
    if ([minstr([dic valueForKey:@"pm"]) isEqual:@"0"]) {
        cell.moneyL.text = [NSString stringWithFormat:@"-%@",minstr([dic valueForKey:@"number"])];
//        cell.moneyL.textColor = normalColors;
    }else{
        cell.moneyL.text = [NSString stringWithFormat:@"+%@",minstr([dic valueForKey:@"number"])];
//        cell.moneyL.textColor = RGB_COLOR(@"#00ad59", 1);
    }
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 40)];
    view.backgroundColor = colorf0;
    UILabel *label = [[UILabel alloc]init];
    NSDictionary *dic = self.dataArray[section];
    label.text = minstr([dic valueForKey:@"time"]);
    label.font = SYS_Font(11);
    label.textColor = color64;
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view);
        make.left.equalTo(view).offset(10);
    }];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)requestData{
//    0 全部  1 消费  2 充值  3 返佣  4 提现
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"spread/commission/3?page=%ld&limit=20",(long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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
