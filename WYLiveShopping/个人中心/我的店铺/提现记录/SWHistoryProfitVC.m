//
//  SWHistoryProfitVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/22.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWHistoryProfitVC.h"
#import "SWProfitHistoryCell.h"
@interface SWHistoryProfitVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *profitTableView;
@property (nonatomic,strong) UIImageView *nothingImgView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) NSInteger page;

@end

@implementation SWHistoryProfitVC
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
    self.page = 1;
    self.dataArray = [NSMutableArray array];
    [self.view addSubview:self.profitTableView];
    [self requestHistoryData];

}
- (UITableView *)profitTableView{
    if (!_profitTableView) {
        _profitTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-(64+statusbarHeight)) style:0];
        _profitTableView.delegate = self;
        _profitTableView.dataSource = self;
        _profitTableView.separatorStyle = 0;
        _profitTableView.backgroundColor = colorf0;
        _profitTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.page = 1;
            [self requestHistoryData];
        }];
        _profitTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            self.page ++;
            [self requestHistoryData];
        }];
        [_profitTableView addSubview:self.nothingImgView];

    }
    return _profitTableView;
}
- (void)requestHistoryData{
    NSString *url;
    if (_ptofitType == 0) {
        url = @"bringlist";
    }else if (_ptofitType == 1){
        url = @"shopcashlist";
    }

    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"%@?page=%ld&limit=20",url,(long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.profitTableView.mj_header endRefreshing];
        [self.profitTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            [self.dataArray addObjectsFromArray:info];
            [self.profitTableView reloadData];
            if ([self.dataArray count] == 0) {
                self.nothingImgView.hidden = NO;
            }else{
                self.nothingImgView.hidden = YES;
            }

        }
    } Fail:^{
        [self.profitTableView.mj_header endRefreshing];
        [self.profitTableView.mj_footer endRefreshing];
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWProfitHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profitHistoryCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWProfitHistoryCell" owner:nil options:nil] lastObject];
    }
    NSDictionary *dic = self.dataArray[indexPath.row];
    cell.orderNumL.text = [NSString stringWithFormat:@"订单%@",minstr([dic valueForKey:@"orderno"])];
    cell.timeL.text = minstr([dic valueForKey:@"addtime"]);
    cell.moneyL.text = [NSString stringWithFormat:@"¥ %@",minstr([dic valueForKey:@"money"])];
    cell.statusL.text = minstr([dic valueForKey:@"status_txt"]);
    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
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
