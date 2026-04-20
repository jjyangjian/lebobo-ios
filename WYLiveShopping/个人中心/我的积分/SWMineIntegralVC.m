//
//  myProfitVC.m
//  yunbaolive
//
//  Created by Boom on 2018/9/26.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "SWMineIntegralVC.h"
#import "SWProfitTypeVC.h"
#import "SWDetailedTableViewCell.h"

@interface SWMineIntegralVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *detailedTableView;
@property (nonatomic,strong) UIView *noView;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation SWMineIntegralVC
- (void)addBtnClick:(UIButton *)sender{
    SWWebViewController *web = [[SWWebViewController alloc]init];
    web.urls = [NSString stringWithFormat:@"%@/Appapi/cash/index?uid=%@&token=%@",h5url,[SWConfig getOwnID],[SWConfig getOwnToken]];
    [self.navigationController pushViewController:web animated:YES];
}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)creatNothingView{
    _noView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _detailedTableView.height)];
    _noView.backgroundColor = [UIColor whiteColor];
    _noView.hidden = YES;
    [_detailedTableView addSubview:_noView];
    UIImageView *_nothingImgV = [[UIImageView alloc]initWithFrame:CGRectMake(_noView.width/2-40, _detailedTableView.height/2-60, 80, 80)];
    _nothingImgV.contentMode = UIViewContentModeScaleAspectFit;
    _nothingImgV.image = [UIImage imageNamed:@"nothingImage"];
    [_noView addSubview:_nothingImgV];
    UILabel *_nothingTitleL = [[UILabel alloc]initWithFrame:CGRectMake(0, _nothingImgV.bottom+10, _window_width, 15)];
    _nothingTitleL.font = [UIFont systemFontOfSize:12];
    _nothingTitleL.textAlignment = NSTextAlignmentCenter;
    _nothingTitleL.text = @"暂无积分明细";
    _nothingTitleL.textColor = colorCC;
    [_noView addSubview:_nothingTitleL];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"我的积分";
    self.view.backgroundColor = colorf0;
    self.dataArray = [NSMutableArray array];
    self.page = 1;
    [self creatUI];
    [self requestData];
}
- (void)requestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"integral/list&page=%ld",(long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.detailedTableView.mj_header endRefreshing];
        [self.detailedTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            [self.dataArray addObjectsFromArray:info];
            [self.detailedTableView reloadData];
            if ([info count] == 0) {
                [self.detailedTableView.mj_footer endRefreshingWithNoMoreData];
            }
            if (self.dataArray.count == 0) {
                _noView.hidden = NO;
            }else{
                _noView.hidden = YES;
            }
        }

    } Fail:^{
        [self.detailedTableView.mj_header endRefreshing];
        [self.detailedTableView.mj_footer endRefreshing];
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWDetailedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailedTableViewCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWDetailedTableViewCell" owner:nil options:nil] lastObject];
    }
    NSDictionary *dic = self.dataArray[indexPath.row];
    cell.nameLabel.text = minstr([dic valueForKey:@"mark"]);
    cell.timeLabel.text = minstr([dic valueForKey:@"add_time"]);
    if ([minstr([dic valueForKey:@"pm"]) isEqual:@"1"]) {
        //类型 1收入 0支出
        cell.numLabel.text = [NSString stringWithFormat:@"+ %@",minstr([dic valueForKey:@"number"])];
        cell.numLabel.textColor = color32;
    }else{
        cell.numLabel.text = [NSString stringWithFormat:@"- %@",minstr([dic valueForKey:@"number"])];
        cell.numLabel.textColor = [UIColor redColor];
    }
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 51;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 50)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc]init];
    label.text = @"积分明细";
    label.textColor = color32;
    label.font = [UIFont boldSystemFontOfSize:14];
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.centerY.equalTo(view);
    }];
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(15, 49, view.width-30, 1) andColor:colorf0 andView:view];
    return view;
}
- (void)creatUI{
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
//    [self.view addGestureRecognizer:tap];
    
    //黄色背景图
    UIImageView *backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 64+statusbarHeight+15, _window_width-30, (_window_width - 30)*0.348)];
    backImgView.image = [UIImage imageNamed:@"profitBg"];
    [self.view addSubview:backImgView];
    
    for (int i = 0; i < 2; i++) {
        UILabel *label = [[UILabel alloc]init];
        label.textColor = [UIColor whiteColor];
        if (i == 0) {
            label.font = [UIFont boldSystemFontOfSize:14];
            label.text = @"我的积分";
        }else{
            label.font = [UIFont boldSystemFontOfSize:18];
            label.text = [SWConfig getIntegral];
        }
        [backImgView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(backImgView);
            make.centerY.equalTo(backImgView).multipliedBy(i==0?0.75:1.283);
        }];
    }
    _detailedTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, backImgView.bottom + 15, _window_width, _window_height-(backImgView.bottom + 15)) style:0];
    _detailedTableView.delegate = self;
    _detailedTableView.dataSource = self;
    _detailedTableView.separatorStyle = 0;
    _detailedTableView.backgroundColor = [UIColor whiteColor];
    _detailedTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        [self requestData];
    }];
    _detailedTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        self.page ++;
        [self requestData];
    }];
    if (@available(iOS 15.0, *)) {
        _detailedTableView.sectionHeaderTopPadding = 0;
    } else {
        // Fallback on earlier versions
    }

    [self.view addSubview:self.detailedTableView];
    [self creatNothingView];
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
