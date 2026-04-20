//
//  SWCatalogView.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/12.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWCatalogView.h"
#import "SWXDMultTableView.h"
#import "SWCatalogCell.h"
#import "SWCourseContentVC.h"

@interface SWCatalogView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) NSString *courseID;
@property (nonatomic, readwrite, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *nothingView;

@end

@implementation SWCatalogView

- (instancetype)initWithFrame:(CGRect)frame andCourseID:(NSString *)str {
    if (self = [super initWithFrame:frame]) {
        self.courseID = str;
        self.dataArray = [NSMutableArray array];
        [self creatUI];
        [self requestData];
    }
    return self;
}

- (void)creatUI {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:0];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = 0;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.tableView];
    self.tableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        [self requestData];
    }];
    [self creatNothingView];
}

- (void)creatNothingView {
    self.nothingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, self.tableView.height)];
    self.nothingView.backgroundColor = [UIColor whiteColor];
    self.nothingView.hidden = YES;
    [self.tableView addSubview:self.nothingView];

    UIImageView *nothingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.nothingView.width / 2 - 40, 120, 80, 80)];
    nothingImageView.contentMode = UIViewContentModeScaleAspectFit;
    nothingImageView.image = [UIImage imageNamed:@"nothingImage"];
    [self.nothingView addSubview:nothingImageView];

    UILabel *nothingTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, nothingImageView.bottom + 10, _window_width, 15)];
    nothingTitleLabel.font = [UIFont systemFontOfSize:12];
    nothingTitleLabel.textAlignment = NSTextAlignmentCenter;
    nothingTitleLabel.text = @"暂未添加课时";
    nothingTitleLabel.textColor = colorCC;
    [self.nothingView addSubview:nothingTitleLabel];
}

- (void)setHomeDic:(NSDictionary *)homeDic {
    _homeDic = homeDic;
    if ([minstr([self.homeDic valueForKey:@"mode"]) isEqual:@"1"]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 30)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, view.width - 30, 30)];
        label.text = @"解锁模式课程，需按照课节顺序学习";
        label.textColor = color96;
        label.font = SYS_Font(11);
        [view addSubview:label];
        self.tableView.tableHeaderView = view;
    }
}

- (void)reloadLIst:(NSDictionary *)dic {
    _homeDic = dic;
    [self.tableView.mj_header beginRefreshing];
}

- (void)requestData {
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"lessonlist&courseid=%@", self.courseID] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.tableView.mj_header endRefreshing];
        if (code == 200) {
            [self.dataArray removeAllObjects];
            for (NSDictionary *dic in info) {
                SWCatalogModel *model = [[SWCatalogModel alloc] initWithDic:dic];
                model.courseid = minstr([self.homeDic valueForKey:@"id"]);
                [self.dataArray addObject:model];
            }
            [self.tableView reloadData];
            self.nothingView.hidden = self.dataArray.count > 0;
        }
    } Fail:^{
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark - datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWCatalogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"catalogCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWCatalogCell" owner:nil options:nil] lastObject];
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWCatalogModel *model = self.dataArray[indexPath.row];
    CGFloat wordH = 0.0;
    if ([model.islast isEqual:@"1"]) {
        wordH = [self getSpaceLabelHeight:[NSString stringWithFormat:@"%@   上次学到  ", model.name] withFont:SYS_Font(14) withWidth:_window_width - 131];
    } else {
        wordH = [self getSpaceLabelHeight:model.name withFont:SYS_Font(14) withWidth:_window_width - 131];
    }
    if ([model.type intValue] > 3) {
        return wordH + 52;
    }
    return wordH + 35;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击cell");
    if ([minstr([self.homeDic valueForKey:@"isbuy"]) isEqual:@"1"]) {
        SWCatalogModel *model = self.dataArray[indexPath.row];
        WeakSelf;
        SWCourseContentVC *vc = [[SWCourseContentVC alloc] init];
        vc.thumb = minstr([self.homeDic valueForKey:@"thumb"]);
        vc.fromWhere = 1;
        vc.model = model;
        vc.block = ^{
            if ([minstr([weakSelf.homeDic valueForKey:@"mode"]) isEqual:@"1"]) {
                [weakSelf.tableView.mj_header beginRefreshing];
            }
        };
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

- (CGFloat)getSpaceLabelHeight:(NSString *)str withFont:(UIFont *)font withWidth:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 5;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName: font, NSParagraphStyleAttributeName: paraStyle, NSKernAttributeName: @1.5f};
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.height;
}

- (void)doCourseDetaile:(NSString *)courseid {
    [MBProgressHUD showMessage:@""];
    [SWToolClass postNetworkWithUrl:@"Course.GetDetail" andParameter:@{@"courseid": courseid} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code != 0) {
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
}

@end
