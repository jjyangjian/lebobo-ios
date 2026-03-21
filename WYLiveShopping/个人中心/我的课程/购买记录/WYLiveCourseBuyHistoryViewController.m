//
//  WYLiveCourseBuyHistoryViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/11.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYLiveCourseBuyHistoryViewController.h"
#import "buyHistoryCell.h"
#import "courseDetaileViewController.h"
@interface WYLiveCourseBuyHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *classTableV;
    NSMutableArray *dataArray;
    int p;
}
@property (nonatomic,strong) UIView *noCourseView;

@end

@implementation WYLiveCourseBuyHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"购买记录";
    dataArray = [NSMutableArray array];
    p = 1;
    classTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, _window_height- (64+statusbarHeight)) style:0];
    classTableV.delegate = self;
    classTableV.dataSource = self;
    classTableV.separatorStyle = 0;
    classTableV.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0, *)) {
        classTableV.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self.view addSubview:classTableV];
    classTableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        p = 1;
        [self requeestData];
    }];
    classTableV.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        p ++;
        [self requeestData];
    }];
    [self creatnoCourseView];
    [self requeestData];

}
- (void)requeestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"courseorder&page=%d",p] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [classTableV.mj_header endRefreshing];
        [classTableV.mj_footer endRefreshing];

        if (code == 200) {
            if (p == 1) {
                [dataArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                courseModel *model = [[courseModel alloc]initWithDic:dic];
                [dataArray addObject:model];
            }
            [classTableV reloadData];
            if ([info count] == 0) {
                [classTableV.mj_footer endRefreshingWithNoMoreData];
            }
            if (dataArray.count == 0) {
                _noCourseView.hidden = NO;
            }else{
                _noCourseView.hidden = YES;
            }
        }
        } Fail:^{
            [classTableV.mj_header endRefreshing];
            [classTableV.mj_footer endRefreshing];

        }];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    buyHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buyHistoryCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"buyHistoryCell" owner:nil options:nil] lastObject];
    }
    cell.model = dataArray[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 145;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    courseModel *model = dataArray[indexPath.row];
    courseDetaileViewController *vc = [[courseDetaileViewController alloc]init];
    vc.model = model;
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

}
- (void)creatnoCourseView{
    _noCourseView = [[UIView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight)];
    _noCourseView.backgroundColor = [UIColor whiteColor];
    _noCourseView.hidden = YES;
    [self.view addSubview:_noCourseView];
    UIImageView *_nothingImgV = [[UIImageView alloc]initWithFrame:CGRectMake(_noCourseView.width/2-40, 120, 80, 80)];
    _nothingImgV.contentMode = UIViewContentModeScaleAspectFit;
    _nothingImgV.image = [UIImage imageNamed:@"nothingImage"];
    [_noCourseView addSubview:_nothingImgV];
    UILabel *_nothingTitleL = [[UILabel alloc]initWithFrame:CGRectMake(0, _nothingImgV.bottom+10, _window_width, 15)];
    _nothingTitleL.font = [UIFont systemFontOfSize:12];
    _nothingTitleL.textAlignment = NSTextAlignmentCenter;
    _nothingTitleL.text = @"暂无购买记录";
    _nothingTitleL.textColor = colorCC;
    [_noCourseView addSubview:_nothingTitleL];
    
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
