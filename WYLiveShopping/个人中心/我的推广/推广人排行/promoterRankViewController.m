//
//  promoterRankViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "promoterRankViewController.h"
#import "rankHeaderView.h"
#import "rankUserCell.h"

@interface promoterRankViewController ()<UITableViewDelegate,UITableViewDataSource>{
    int page;
    NSMutableArray *dataArray;
    UITableView *listTableView;
    rankHeaderView *headerView;
    NSString *typeStr;
    UIButton *weekBtn;
    UIButton *monthBtn;
}


@end

@implementation promoterRankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.returnBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
    self.lineView.hidden = YES;
    self.naviView.backgroundColor = [UIColor clearColor];
    self.titleL.textColor = [UIColor whiteColor];
    self.titleL.text = @"推广人排行";
    self.view.backgroundColor = colorf0;
    dataArray = [NSMutableArray array];
    page = 1;
    typeStr = @"week";
    [self creatHeaderView];
    [self requestData];
}
- (void)creatHeaderView{
    headerView = [[[NSBundle mainBundle] loadNibNamed:@"rankHeaderView" owner:nil options:nil] lastObject];
    headerView.frame = CGRectMake(0, 0, _window_width, _window_width*0.8+statusbarHeight);
    [self.view addSubview:headerView];
    [self.view sendSubviewToBack:headerView];
    
    
    NSArray *sgArr1 = [NSArray arrayWithObjects:@"周榜",@"月榜", nil];
    UIView *buttonBackView = [[UIView alloc]initWithFrame:CGRectMake(_window_width/2-100, 78+statusbarHeight, 200, 30)];
    buttonBackView.layer.cornerRadius = 15;
    buttonBackView.layer.masksToBounds = YES;
    buttonBackView.layer.borderColor = [UIColor whiteColor].CGColor;
    buttonBackView.layer.borderWidth = 1;
    [headerView addSubview:buttonBackView];
    for (int i = 0; i < sgArr1.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(i*100, 0, 100, 30);
        [btn setTitle:sgArr1[i] forState:0];
        [btn setTitleColor:normalColors forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor whiteColor] forState:0];
        [btn setBackgroundImage:[WYToolClass getImgWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
        [btn setBackgroundImage:[WYToolClass getImgWithColor:normalColors] forState:0];
        btn.titleLabel.font = SYS_Font(13);
        [btn addTarget:self action:@selector(segmentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 10000 + i;
        [buttonBackView addSubview:btn];
        if (i == 0) {
            btn.selected = YES;
            weekBtn = btn;
        }else{
            monthBtn = btn;
        }
    }

    
    listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, headerView.bottom, _window_width, _window_height-headerView.bottom) style:0];
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

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (dataArray.count > 3) {
        return dataArray.count - 3;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    rankUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rankUserCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"rankUserCell" owner:nil options:nil] lastObject];
    }
    cell.model = dataArray[indexPath.row+3];
    cell.numsL.text = [NSString stringWithFormat:@"%ld",indexPath.row+4];
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)requestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"rank?page=%d&type=%@&limit=20",page,typeStr] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [listTableView.mj_header endRefreshing];
            [listTableView.mj_footer endRefreshing];
            if (code == 200) {
                if (page == 1) {
                    [dataArray removeAllObjects];
                }
                NSArray *list = info;
                for (NSDictionary *dic in list) {
                    rankUserModel *model = [[rankUserModel alloc]initWithDic:dic];
                    [dataArray addObject:model];
                }
                if (page == 1) {
                    [self setValueForHeader];
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
- (void)setValueForHeader{
    if (dataArray.count == 0) {
        headerView.oneImgV.hidden = YES;
        headerView.oneName.hidden = YES;
        headerView.oneNums.hidden = YES;
        headerView.headerimg1.hidden = YES;
        headerView.twoImgV.hidden = YES;
        headerView.twoNameL.hidden = YES;
        headerView.twoNumsL.hidden = YES;
        headerView.headerimg2.hidden = YES;
        headerView.threeImgV.hidden = YES;
        headerView.threeNameL.hidden = YES;
        headerView.threeNumsL.hidden = YES;
        headerView.headerimg3.hidden = YES;
    }else if (dataArray.count == 1){
        headerView.oneImgV.hidden = NO;
        headerView.oneName.hidden = NO;
        headerView.oneNums.hidden = NO;
        headerView.headerimg1.hidden = NO;
        headerView.twoImgV.hidden = YES;
        headerView.twoNameL.hidden = YES;
        headerView.twoNumsL.hidden = YES;
        headerView.headerimg2.hidden = YES;
        headerView.threeImgV.hidden = YES;
        headerView.threeNameL.hidden = YES;
        headerView.threeNumsL.hidden = YES;
        headerView.headerimg3.hidden = YES;
        rankUserModel *model1 = dataArray[0];
        [headerView.oneImgV sd_setImageWithURL:[NSURL URLWithString:model1.avatar]];
        headerView.oneName.text = model1.nickname;
        headerView.oneNums.text = [NSString stringWithFormat:@"%@人",model1.count];

    }else if (dataArray.count == 2){
        headerView.oneImgV.hidden = NO;
        headerView.oneName.hidden = NO;
        headerView.oneNums.hidden = NO;
        headerView.headerimg1.hidden = NO;
        headerView.twoImgV.hidden = NO;
        headerView.twoNameL.hidden = NO;
        headerView.twoNumsL.hidden = NO;
        headerView.headerimg2.hidden = NO;
        headerView.threeImgV.hidden = YES;
        headerView.threeNameL.hidden = YES;
        headerView.threeNumsL.hidden = YES;
        headerView.headerimg3.hidden = YES;
        rankUserModel *model1 = dataArray[0];
        [headerView.oneImgV sd_setImageWithURL:[NSURL URLWithString:model1.avatar]];
        headerView.oneName.text = model1.nickname;
        headerView.oneNums.text = [NSString stringWithFormat:@"%@人",model1.count];
        rankUserModel *model2 = dataArray[1];
        [headerView.twoImgV sd_setImageWithURL:[NSURL URLWithString:model2.avatar]];
        headerView.twoNameL.text = model2.nickname;
        headerView.twoNumsL.text = [NSString stringWithFormat:@"%@人",model2.count];

    }else {
        headerView.oneImgV.hidden = NO;
        headerView.oneName.hidden = NO;
        headerView.oneNums.hidden = NO;
        headerView.headerimg1.hidden = NO;
        headerView.twoImgV.hidden = NO;
        headerView.twoNameL.hidden = NO;
        headerView.twoNumsL.hidden = NO;
        headerView.headerimg2.hidden = NO;
        headerView.threeImgV.hidden = NO;
        headerView.threeNameL.hidden = NO;
        headerView.threeNumsL.hidden = NO;
        headerView.headerimg3.hidden = NO;
        rankUserModel *model1 = dataArray[0];
        [headerView.oneImgV sd_setImageWithURL:[NSURL URLWithString:model1.avatar]];
        headerView.oneName.text = model1.nickname;
        headerView.oneNums.text = [NSString stringWithFormat:@"%@人",model1.count];
        rankUserModel *model2 = dataArray[1];
        [headerView.twoImgV sd_setImageWithURL:[NSURL URLWithString:model2.avatar]];
        headerView.twoNameL.text = model2.nickname;
        headerView.twoNumsL.text = [NSString stringWithFormat:@"%@人",model2.count];
        rankUserModel *model3 = dataArray[2];
        [headerView.threeImgV sd_setImageWithURL:[NSURL URLWithString:model3.avatar]];
        headerView.threeNameL.text = model3.nickname;
        headerView.threeNumsL.text = [NSString stringWithFormat:@"%@人",model3.count];

    }
}
- (void)segmentButtonClick:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
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
