//
//  JJOrderBaseListView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2026/3/27.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import "JJOrderBaseListView.h"
#import "MJRefresh.h"
#import "JJNoDataNormalView.h"

@interface JJOrderBaseListView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) JJNoDataNormalView *noDataView;

@end

@implementation JJOrderBaseListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _dataArray = [NSMutableArray array];
        _page = 1;
        [self configUI];
    }
    return self;
}

- (void)configUI {
    self.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
    
    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            __weak typeof(self) weakSelf = self;
            weakSelf.page = 1;
            [weakSelf requestData];
        }];
        tableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            __weak typeof(self) weakSelf = self;
            weakSelf.page++;
            [weakSelf requestData];
        }];
        if (@available(iOS 15.0, *)) {
            tableView.sectionHeaderTopPadding = 0;
        }
        [self addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.tableView = tableView;
    }
    
    {
        JJNoDataNormalView *noDataView = [[JJNoDataNormalView alloc] initWithFrame:CGRectZero];
        noDataView.hidden = YES;
        noDataView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.backgroundView = noDataView;
        self.noDataView = noDataView;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.noDataView.frame = self.tableView.bounds;
}

- (void)requestFirstPageData {
    self.page = 1;
    [self requestData];
}

- (void)requestData {
    // 子类重写此方法
}

- (void)updateNoDataViewHidden {
    self.noDataView.hidden = self.dataArray.count > 0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 子类重写此方法
    return [[UITableViewCell alloc] init];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectBlock && indexPath.row < self.dataArray.count) {
        self.selectBlock(self.dataArray[indexPath.row]);
    }
}

@end