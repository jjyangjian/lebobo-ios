//
//  SWPromoterRankVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWPromoterRankVC.h"
#import "SWRankHeaderView.h"
#import "SWRankUserCell.h"

@interface SWPromoterRankVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) UITableView *listTableView;
@property (nonatomic,strong) SWRankHeaderView *headerView;
@property (nonatomic,copy) NSString *typeString;
@property (nonatomic,strong) UIButton *weekButton;
@property (nonatomic,strong) UIButton *monthButton;

@end

@implementation SWPromoterRankVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.returnBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
    self.lineView.hidden = YES;
    self.naviView.backgroundColor = [UIColor clearColor];
    self.titleL.textColor = [UIColor whiteColor];
    self.titleL.text = @"推广人排行";
    self.view.backgroundColor = colorf0;
    self.dataArray = [NSMutableArray array];
    self.page = 1;
    self.typeString = @"week";
    [self creatHeaderView];
    [self requestData];
}
- (void)creatHeaderView{
    self.headerView = [[[NSBundle mainBundle] loadNibNamed:@"SWRankHeaderView" owner:nil options:nil] lastObject];
    self.headerView.frame = CGRectMake(0, 0, _window_width, _window_width*0.8+statusbarHeight);
    [self.view addSubview:self.headerView];
    [self.view sendSubviewToBack:self.headerView];
    
    NSArray *sgArr1 = [NSArray arrayWithObjects:@"周榜",@"月榜", nil];
    UIView *buttonBackView = [[UIView alloc]initWithFrame:CGRectMake(_window_width/2-100, 78+statusbarHeight, 200, 30)];
    buttonBackView.layer.cornerRadius = 15;
    buttonBackView.layer.masksToBounds = YES;
    buttonBackView.layer.borderColor = [UIColor whiteColor].CGColor;
    buttonBackView.layer.borderWidth = 1;
    [self.headerView addSubview:buttonBackView];
    for (int i = 0; i < sgArr1.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(i*100, 0, 100, 30);
        [btn setTitle:sgArr1[i] forState:0];
        [btn setTitleColor:normalColors forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor whiteColor] forState:0];
        [btn setBackgroundImage:[SWToolClass getImgWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
        [btn setBackgroundImage:[SWToolClass getImgWithColor:normalColors] forState:0];
        btn.titleLabel.font = SYS_Font(13);
        [btn addTarget:self action:@selector(segmentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 10000 + i;
        [buttonBackView addSubview:btn];
        if (i == 0) {
            btn.selected = YES;
            self.weekButton = btn;
        }else{
            self.monthButton = btn;
        }
    }

    self.listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.headerView.bottom, _window_width, _window_height-self.headerView.bottom) style:0];
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

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataArray.count > 3) {
        return self.dataArray.count - 3;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWRankUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rankUserCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWRankUserCell" owner:nil options:nil] lastObject];
    }
    cell.model = self.dataArray[indexPath.row+3];
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
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"rank?page=%ld&type=%@&limit=20",(long)self.page,self.typeString] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.listTableView.mj_header endRefreshing];
        [self.listTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            NSArray *list = info;
            for (NSDictionary *dic in list) {
                SWRankUserModel *model = [[SWRankUserModel alloc]initWithDic:dic];
                [self.dataArray addObject:model];
            }
            if (self.page == 1) {
                [self setValueForHeader];
            }
            [self.listTableView reloadData];
            if (list.count < 20) {
                [self.listTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } Fail:^{
        [self.listTableView.mj_header endRefreshing];
        [self.listTableView.mj_footer endRefreshing];
    }];
}
- (void)setValueForHeader{
    if (self.dataArray.count == 0) {
        self.headerView.oneImgV.hidden = YES;
        self.headerView.oneName.hidden = YES;
        self.headerView.oneNums.hidden = YES;
        self.headerView.headerimg1.hidden = YES;
        self.headerView.twoImgV.hidden = YES;
        self.headerView.twoNameL.hidden = YES;
        self.headerView.twoNumsL.hidden = YES;
        self.headerView.headerimg2.hidden = YES;
        self.headerView.threeImgV.hidden = YES;
        self.headerView.threeNameL.hidden = YES;
        self.headerView.threeNumsL.hidden = YES;
        self.headerView.headerimg3.hidden = YES;
    }else if (self.dataArray.count == 1){
        self.headerView.oneImgV.hidden = NO;
        self.headerView.oneName.hidden = NO;
        self.headerView.oneNums.hidden = NO;
        self.headerView.headerimg1.hidden = NO;
        self.headerView.twoImgV.hidden = YES;
        self.headerView.twoNameL.hidden = YES;
        self.headerView.twoNumsL.hidden = YES;
        self.headerView.headerimg2.hidden = YES;
        self.headerView.threeImgV.hidden = YES;
        self.headerView.threeNameL.hidden = YES;
        self.headerView.threeNumsL.hidden = YES;
        self.headerView.headerimg3.hidden = YES;
        SWRankUserModel *model1 = self.dataArray[0];
        [self.headerView.oneImgV sd_setImageWithURL:[NSURL URLWithString:model1.avatar]];
        self.headerView.oneName.text = model1.nickname;
        self.headerView.oneNums.text = [NSString stringWithFormat:@"%@人",model1.count];

    }else if (self.dataArray.count == 2){
        self.headerView.oneImgV.hidden = NO;
        self.headerView.oneName.hidden = NO;
        self.headerView.oneNums.hidden = NO;
        self.headerView.headerimg1.hidden = NO;
        self.headerView.twoImgV.hidden = NO;
        self.headerView.twoNameL.hidden = NO;
        self.headerView.twoNumsL.hidden = NO;
        self.headerView.headerimg2.hidden = NO;
        self.headerView.threeImgV.hidden = YES;
        self.headerView.threeNameL.hidden = YES;
        self.headerView.threeNumsL.hidden = YES;
        self.headerView.headerimg3.hidden = YES;
        SWRankUserModel *model1 = self.dataArray[0];
        [self.headerView.oneImgV sd_setImageWithURL:[NSURL URLWithString:model1.avatar]];
        self.headerView.oneName.text = model1.nickname;
        self.headerView.oneNums.text = [NSString stringWithFormat:@"%@人",model1.count];
        SWRankUserModel *model2 = self.dataArray[1];
        [self.headerView.twoImgV sd_setImageWithURL:[NSURL URLWithString:model2.avatar]];
        self.headerView.twoNameL.text = model2.nickname;
        self.headerView.twoNumsL.text = [NSString stringWithFormat:@"%@人",model2.count];

    }else {
        self.headerView.oneImgV.hidden = NO;
        self.headerView.oneName.hidden = NO;
        self.headerView.oneNums.hidden = NO;
        self.headerView.headerimg1.hidden = NO;
        self.headerView.twoImgV.hidden = NO;
        self.headerView.twoNameL.hidden = NO;
        self.headerView.twoNumsL.hidden = NO;
        self.headerView.headerimg2.hidden = NO;
        self.headerView.threeImgV.hidden = NO;
        self.headerView.threeNameL.hidden = NO;
        self.headerView.threeNumsL.hidden = NO;
        self.headerView.headerimg3.hidden = NO;
        SWRankUserModel *model1 = self.dataArray[0];
        [self.headerView.oneImgV sd_setImageWithURL:[NSURL URLWithString:model1.avatar]];
        self.headerView.oneName.text = model1.nickname;
        self.headerView.oneNums.text = [NSString stringWithFormat:@"%@人",model1.count];
        SWRankUserModel *model2 = self.dataArray[1];
        [self.headerView.twoImgV sd_setImageWithURL:[NSURL URLWithString:model2.avatar]];
        self.headerView.twoNameL.text = model2.nickname;
        self.headerView.twoNumsL.text = [NSString stringWithFormat:@"%@人",model2.count];
        SWRankUserModel *model3 = self.dataArray[2];
        [self.headerView.threeImgV sd_setImageWithURL:[NSURL URLWithString:model3.avatar]];
        self.headerView.threeNameL.text = model3.nickname;
        self.headerView.threeNumsL.text = [NSString stringWithFormat:@"%@人",model3.count];

    }
}
- (void)segmentButtonClick:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    if (sender == self.weekButton) {
        self.typeString = @"week";
        self.weekButton.selected = YES;
        self.monthButton.selected = NO;
    }else {
        self.typeString = @"month";
        self.weekButton.selected = NO;
        self.monthButton.selected = YES;
    }
    self.page = 1;
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
