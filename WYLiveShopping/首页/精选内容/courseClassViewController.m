//
//  courseClassViewController.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/2.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "courseClassViewController.h"
#import "WYLiveCourseCell.h"
#import "courseDetaileViewController.h"

@interface courseClassViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *classTableV;
    NSMutableArray *dataArray;
    int p;
}
@property (nonatomic,strong) UIView *nothingView;


@end

@implementation courseClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];

    dataArray = [NSMutableArray array];
    p = 1;
    classTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height- (64+statusbarHeight+49)) style:0];
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
    [self creatNothingView];
    [self requeestData];
}
- (void)viewWillDisappear:(BOOL)animated{
}
- (void)requeestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"courselist&catid=%@&page=%d",_type,p] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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
                _nothingView.hidden = NO;
            }else{
                _nothingView.hidden = YES;
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
    WYLiveCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WYLiveCourseCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WYLiveCourseCell" owner:nil options:nil] lastObject];
    }
    cell.model = dataArray[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    courseModel *model = dataArray[indexPath.row];
    courseDetaileViewController *vc = [[courseDetaileViewController alloc]init];
    vc.model = model;
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
- (void)creatNothingView{
    _nothingView = [[UIView alloc]initWithFrame:CGRectMake(0, 100, _window_width, 90)];
    _nothingView.backgroundColor = [UIColor whiteColor];
    _nothingView.hidden = YES;
    [classTableV addSubview:_nothingView];
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(_nothingView.width/2-42, 0, 84, 54)];
    imgV.image = [UIImage imageNamed:@"no-video"];
    [_nothingView addSubview:imgV];
    UILabel *label = [[UILabel alloc]init];
    label.font = SYS_Font(12);
    label.textColor = color96;
    label.text = @"暂无内容";
    [_nothingView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_nothingView);
        make.top.equalTo(imgV.mas_bottom).offset(20);
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
