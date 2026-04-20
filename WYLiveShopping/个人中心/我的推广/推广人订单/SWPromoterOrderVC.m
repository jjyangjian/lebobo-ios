//
//  SWPromoterOrderVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWPromoterOrderVC.h"
#import "SWPromoterOrderCell.h"

@interface SWPromoterOrderVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) UITableView *listTableView;
@property (nonatomic,strong) UILabel *allNumsLabel;

@end

@implementation SWPromoterOrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.returnBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
    self.lineView.hidden = YES;
    self.naviView.backgroundColor = [UIColor clearColor];
    self.titleL.textColor = [UIColor whiteColor];
    self.titleL.text = @"推广人订单";
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
    imgV.image = [UIImage imageNamed:@"推广人订单_fan"];
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
    [headerImgView addSubview:numsL];
    [numsL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerImgView).offset(25);
        make.centerY.equalTo(imgV);
    }];
    self.allNumsLabel = numsL;
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
    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"累计推广订单\n%@单",nums]];
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
    NSArray *list = [self.dataArray[section] valueForKey:@"child"];
    return list.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWPromoterOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"promoterOrderCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWPromoterOrderCell" owner:nil options:nil] lastObject];
    }
    NSArray *list = [self.dataArray[indexPath.section] valueForKey:@"child"];
    NSDictionary *dic = list[indexPath.row];
    [cell.iconImgV sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"avatar"])]];
    cell.nameL.text = minstr([dic valueForKey:@"nickname"]);
    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"订单编号：%@\n下单时间：%@",minstr([dic valueForKey:@"order_id"]),minstr([dic valueForKey:@"time"])]];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    [muStr addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, muStr.length)];
    cell.orderNumL.attributedText = muStr;
    if ([minstr([dic valueForKey:@"type"]) isEqual:@"pay_money"]) {
        cell.moneyl.text = @"";
        cell.tipsL.text = @"暂未返佣";
    }else{
        cell.moneyl.text = [NSString stringWithFormat:@"¥%@",minstr([dic valueForKey:@"number"])];
        cell.tipsL.text = @"返佣：";
    }
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 60)];
    view.backgroundColor = colorf0;
    NSDictionary *dic = self.dataArray[section];
    UILabel *label = [[UILabel alloc]init];
    label.text = minstr([dic valueForKey:@"time"]);
    label.font = SYS_Font(13);
    label.textColor = color32;
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view.mas_top).offset(20);
        make.left.equalTo(view).offset(10);
    }];
    
    UILabel *label2 = [[UILabel alloc]init];
    label2.text = [NSString stringWithFormat:@"本月累计推广：%@单",minstr([dic valueForKey:@"count"])];
    label2.font = SYS_Font(13);
    label2.textColor = color96;
    [view addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view.mas_top).offset(42);
        make.left.equalTo(view).offset(10);
    }];

    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 115;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)requestData{
    [SWToolClass postNetworkWithUrl:@"spread/order" andParameter:@{@"page":@(self.page),@"limit":@"20"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.listTableView.mj_header endRefreshing];
        [self.listTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
                self.allNumsLabel.attributedText = [self setAttText:minstr([info valueForKey:@"count"])];
            }
            NSArray *list = [info valueForKey:@"list"];
            [self.dataArray addObjectsFromArray:list];
            [self.listTableView reloadData];
            if ([list count] < 20) {
                [self.listTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } fail:^{
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
