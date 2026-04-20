//
//  SWLiveCourseBuyHistoryVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/11.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWLiveCourseBuyHistoryVC.h"
#import "SWBuyHistoryCell.h"
#import "SWCourseDetaileVC.h"
@interface SWLiveCourseBuyHistoryVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UIView *noCourseView;
@property (nonatomic,strong) UITableView *classTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) NSInteger page;

@end

@implementation SWLiveCourseBuyHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"购买记录";
    self.dataArray = [NSMutableArray array];
    self.page = 1;
    self.classTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, _window_height- (64+statusbarHeight)) style:0];
    self.classTableView.delegate = self;
    self.classTableView.dataSource = self;
    self.classTableView.separatorStyle = 0;
    self.classTableView.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0, *)) {
        self.classTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self.view addSubview:self.classTableView];
    self.classTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        [self requeestData];
    }];
    self.classTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        self.page ++;
        [self requeestData];
    }];
    [self creatnoCourseView];
    [self requeestData];

}
- (void)requeestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"courseorder&page=%ld",(long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.classTableView.mj_header endRefreshing];
        [self.classTableView.mj_footer endRefreshing];

        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                SWCourseModel *model = [[SWCourseModel alloc]initWithDic:dic];
                [self.dataArray addObject:model];
            }
            [self.classTableView reloadData];
            if ([info count] == 0) {
                [self.classTableView.mj_footer endRefreshingWithNoMoreData];
            }
            if (self.dataArray.count == 0) {
                _noCourseView.hidden = NO;
            }else{
                _noCourseView.hidden = YES;
            }
        }
        } Fail:^{
            [self.classTableView.mj_header endRefreshing];
            [self.classTableView.mj_footer endRefreshing];

        }];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWBuyHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buyHistoryCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWBuyHistoryCell" owner:nil options:nil] lastObject];
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 145;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SWCourseModel *model = self.dataArray[indexPath.row];
    SWCourseDetaileVC *vc = [[SWCourseDetaileVC alloc]init];
    vc.model = model;
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

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
