//
//  commissionRankViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "commissionRankViewController.h"
#import "rankUserCell.h"

@interface commissionRankViewController ()<UITableViewDelegate,UITableViewDataSource>{
    int page;
    NSMutableArray *dataArray;
    UITableView *listTableView;
    NSString *typeStr;
    UIButton *weekBtn;
    UIButton *monthBtn;
    UILabel *rankLabel;
    UIView *moveLineV;
}


@end

@implementation commissionRankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.returnBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
    self.lineView.hidden = YES;
    self.naviView.image = [UIImage imageNamed:@"button_back"];
    self.titleL.textColor = [UIColor whiteColor];
    self.titleL.text = @"佣金排行";
    self.view.backgroundColor = colorf0;
    typeStr = @"week";
    dataArray = [NSMutableArray array];
    page = 1;
    [self creatUI];
    [self requestData];
}
- (void)creatUI{
    UIImageView *backImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, _window_width*0.46)];
    backImgV.image = [UIImage imageNamed:@"commission_header.jpg"];
    backImgV.userInteractionEnabled = YES;
    [self.view addSubview:backImgV];
    UILabel *label = [[UILabel alloc]init];
    label.font = SYS_Font(15);
    label.textColor = [UIColor whiteColor];
    [backImgV addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backImgV).offset(0.06*_window_width);
        make.top.equalTo(backImgV.mas_centerY);
    }];
    rankLabel = label;
    UIView *view = [[UIView alloc]init];
    view.layer.cornerRadius = 10;
    view.clipsToBounds = YES;
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(backImgV.mas_bottom).offset(-40);
        make.width.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view).offset(-10-ShowDiff);
    }];
    CGFloat viewWidth = (_window_width - 20);
    NSArray *sgArr1 = [NSArray arrayWithObjects:@"周榜",@"月榜", nil];
    for (int i = 0; i < sgArr1.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(i*viewWidth/2, 0, viewWidth/2, 40);
        [btn setTitle:sgArr1[i] forState:0];
        [btn setTitleColor:normalColors forState:UIControlStateSelected];
        [btn setTitleColor:color96 forState:0];
//        [btn setBackgroundImage:[WYToolClass getImgWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
//        [btn setBackgroundImage:[WYToolClass getImgWithColor:normalColors] forState:0];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [btn addTarget:self action:@selector(segmentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 10000 + i;
        [view addSubview:btn];
        if (i == 0) {
            btn.selected = YES;
            weekBtn = btn;
        }else{
            monthBtn = btn;
        }
    }
    moveLineV = [[UIView alloc]initWithFrame:CGRectMake(viewWidth/4-25, 39, 50, 1)];
    moveLineV.backgroundColor = normalColors;
    [view addSubview:moveLineV];

    
    listTableView = [[UITableView alloc]initWithFrame:CGRectZero style:0];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    listTableView.separatorStyle = 0;
    [view addSubview:listTableView];
    listTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        [self requestData];
    }];
    listTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        page ++;
        [self requestData];
    }];
    [listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.bottom.equalTo(view);
        make.top.equalTo(view).offset(40);
    }];

}
- (void)requestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"brokerage_rank?page=%d&type=%@&limit=20",page,typeStr] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [listTableView.mj_header endRefreshing];
            [listTableView.mj_footer endRefreshing];
            if (code == 200) {
                if (page == 1) {
                    [dataArray removeAllObjects];
                    if ([minstr([info valueForKey:@"position"]) intValue] == 0) {
                        rankLabel.text = @"您目前暂无排名";
                    }else{
                        rankLabel.attributedText = [self setAttText:minstr([info valueForKey:@"position"])];
                    }
                }
                NSArray *list = [info valueForKey:@"rank"];
                for (NSDictionary *dic in list) {
                    commissionUserModel *model = [[commissionUserModel alloc]initWithDic:dic];
                    [dataArray addObject:model];
                }
                [listTableView reloadData];
                if (list.count < 20) {
                    [listTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
    } Fail:^{
        [listTableView.mj_header endRefreshing];
        [listTableView.mj_footer endRefreshing];
    }];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    rankUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rankUserCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"rankUserCell" owner:nil options:nil] lastObject];
        cell.peopleL.textColor = normalColors;
    }
    cell.comModel = dataArray[indexPath.row];
    cell.numsL.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    if (indexPath.row < 3) {
        cell.numImgView.hidden = NO;
        cell.numImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"medal%02d",(int)indexPath.row + 1]];
    }else{
        cell.numImgView.hidden = YES;
    }
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSAttributedString *)setAttText:(NSString *)str{

    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"您目前的排名 %@ 名",str]];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;

    [muStr addAttributes:@{NSFontAttributeName:SYS_Font(25)} range:NSMakeRange(7, str.length)];
    [muStr addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, muStr.length)];
    return muStr;
}
- (void)segmentButtonClick:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        moveLineV.centerX = sender.centerX;
    }];
    if (sender == weekBtn) {
        typeStr = @"week";
        weekBtn.selected = YES;
        monthBtn.selected = NO;
    }else {
        typeStr = @"month";
        weekBtn.selected = NO;
        monthBtn.selected = YES;
    }
    page = 1;
    [self requestData];
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
