//
//  SWEvaluateView.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWEvaluateView.h"
#import "SWEvaluateCell.h"
#import "SWCouserStarView.h"
#import "SWWriteEvaluateVC.h"

@interface SWEvaluateView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) int page;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) NSString *courseID;
@property (nonatomic, assign) BOOL isCourse;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) SWCouserStarView *starView;
@property (nonatomic, strong) UILabel *starNumberLabel;
@property (nonatomic, strong) UIButton *writeButton;
@property (nonatomic, strong) UIView *nothingView;

@end

@implementation SWEvaluateView

- (void)doWrite {
    SWWriteEvaluateVC *vc = [[SWWriteEvaluateVC alloc] init];
    vc.courseMsgDic = self.courseDiccccc;
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)setCourseDiccccc:(NSDictionary *)courseDiccccc {
    _courseDiccccc = courseDiccccc;
    int isbuy = [minstr([self.courseDiccccc valueForKey:@"isbuy"]) intValue];
    self.writeButton.hidden = isbuy != 1;
}

- (instancetype)initWithFrame:(CGRect)frame andCourse:(NSDictionary *)course andIsCourse:(BOOL)isC {
    if (self = [super initWithFrame:frame]) {
        self.courseID = minstr([course valueForKey:@"id"]);
        self.courseDiccccc = course;
        self.isCourse = isC;
        self.page = 1;
        self.dataArray = [NSMutableArray array];
        [self creatUI:course];
        [self requestData];
    }
    return self;
}

- (void)creatUI:(NSDictionary *)course {
    self.listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _window_width, self.height) style:0];
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    self.listTableView.separatorStyle = 0;
    self.listTableView.estimatedRowHeight = 100;
    [self addSubview:self.listTableView];
    self.listTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        [self requestData];
    }];
    self.listTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        self.page ++;
        [self requestData];
    }];

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, 60)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    self.starView = [[SWCouserStarView alloc] init];
    self.starView.frame = CGRectMake(15, 20, 100, 20);
    [self.headerView addSubview:self.starView];
    int starNum = [minstr([course valueForKey:@"star"]) intValue];
    [self.starView setCurIndex:starNum andStartingDirectionLeft:YES];

    self.starNumberLabel = [[UILabel alloc] init];
    self.starNumberLabel.font = SYS_Font(14);
    self.starNumberLabel.textColor = normalColors;
    self.starNumberLabel.text = minstr([course valueForKey:@"star"]);
    [self.headerView addSubview:self.starNumberLabel];
    [self.starNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.starView);
        make.left.equalTo(self.starView.mas_right).offset((starNum - 5) * 20 + 20);
    }];

    self.writeButton = [UIButton buttonWithType:0];
    self.writeButton.frame = CGRectMake(self.headerView.width - 75, 20, 60, 20);
    [self.writeButton setTitle:@"写评价" forState:0];
    [self.writeButton setTitleColor:normalColors forState:0];
    self.writeButton.titleLabel.font = SYS_Font(10);
    [self.writeButton setCornerRadius:10];
    [self.writeButton setBorderWidth:1];
    [self.writeButton setBorderColor:normalColors];
    [self.writeButton addTarget:self action:@selector(doWrite) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.writeButton];

    int isbuy = [minstr([self.courseDiccccc valueForKey:@"isbuy"]) intValue];
    self.writeButton.hidden = isbuy != 1;
    self.listTableView.tableHeaderView = self.headerView;
    [self creatNothingView];
}

- (void)selfDowvaluateSucessToReload {
    self.page = 1;
    [self requestData];
}

- (void)requestData {
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"coursecomment&courseid=%@&page=%d", self.courseID, self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.listTableView.mj_header endRefreshing];
        [self.listTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
                int starNum = [minstr([info valueForKey:@"star"]) intValue];
                [self.starView setCurIndex:starNum andStartingDirectionLeft:YES];
                self.starNumberLabel.text = minstr([info valueForKey:@"star"]);
                [self.starNumberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.starView);
                    make.left.equalTo(self.starView.mas_right).offset((starNum - 5) * 20 + 20);
                }];
            }
            NSArray *list = [info valueForKey:@"list"];
            for (NSDictionary *dic in list) {
                SWEvaluateModel *model = [[SWEvaluateModel alloc] initWithDic:dic];
                model.iscourse = self.isCourse;
                [self.dataArray addObject:model];
            }
            [self.listTableView reloadData];
            self.nothingView.hidden = self.dataArray.count > 0;
        }
    } Fail:^{
        [self.listTableView.mj_header endRefreshing];
        [self.listTableView.mj_footer endRefreshing];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWEvaluateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"evaluateCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWEvaluateCell" owner:nil options:nil] lastObject];
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)creatNothingView {
    self.nothingView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, _window_width, self.listTableView.height - 60)];
    self.nothingView.backgroundColor = [UIColor whiteColor];
    self.nothingView.hidden = YES;
    [self.listTableView addSubview:self.nothingView];

    UIImageView *nothingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.nothingView.width / 2 - 40, 30, 80, 80)];
    nothingImageView.contentMode = UIViewContentModeScaleAspectFit;
    nothingImageView.image = [UIImage imageNamed:@"nothingImage"];
    [self.nothingView addSubview:nothingImageView];

    UILabel *nothingTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, nothingImageView.bottom + 10, _window_width, 15)];
    nothingTitleLabel.font = [UIFont systemFontOfSize:12];
    nothingTitleLabel.textAlignment = NSTextAlignmentCenter;
    nothingTitleLabel.text = @"还未收到评价";
    nothingTitleLabel.textColor = colorCC;
    [self.nothingView addSubview:nothingTitleLabel];
}

@end
