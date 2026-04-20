//
//  SWCourseClassVC.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/2.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWCourseClassVC.h"
#import "SWLiveCourseCell.h"
#import "SWCourseDetaileVC.h"

@interface SWCourseClassVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *classTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) UIView *nothingView;


@end

@implementation SWCourseClassVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.dataArray = [NSMutableArray array];
    self.page = 1;
    self.classTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height- (64+statusbarHeight+49)) style:0];
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
    [self creatNothingView];
    [self requeestData];
}
- (void)viewWillDisappear:(BOOL)animated{
}
- (void)requeestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"courselist&catid=%@&page=%ld",_type,(long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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
                self.nothingView.hidden = NO;
            }else{
                self.nothingView.hidden = YES;
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
    SWLiveCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WYLiveCourseCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWLiveCourseCell" owner:nil options:nil] lastObject];
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SWCourseModel *model = self.dataArray[indexPath.row];
    SWCourseDetaileVC *vc = [[SWCourseDetaileVC alloc]init];
    vc.model = model;
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
- (void)creatNothingView{
    self.nothingView = [[UIView alloc]initWithFrame:CGRectMake(0, 100, _window_width, 90)];
    self.nothingView.backgroundColor = [UIColor whiteColor];
    self.nothingView.hidden = YES;
    [self.classTableView addSubview:self.nothingView];
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(self.nothingView.width/2-42, 0, 84, 54)];
    imgV.image = [UIImage imageNamed:@"no-video"];
    [self.nothingView addSubview:imgV];
    UILabel *label = [[UILabel alloc]init];
    label.font = SYS_Font(12);
    label.textColor = color96;
    label.text = @"暂无内容";
    [self.nothingView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.nothingView);
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
