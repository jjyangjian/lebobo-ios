//
//  SWReplyListViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/29.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWReplyListViewController.h"
#import "SWReplyCell.h"

@interface SWReplyListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) UILabel *highLabel;
@property (nonatomic, strong) SWStarView *starView;
@property (nonatomic, assign) int type;
@property (nonatomic, strong) UITableView *replyTableView;
@end

@implementation SWReplyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"商品评分";
    self.dataArray = [NSMutableArray array];
    self.buttonArray = [NSMutableArray array];
    self.page = 1;
    self.type = 0;
    [self addHeaderView];
    [self.view addSubview:self.replyTableView];
    [self getReplyNums];
    [self requestData];
}

- (void)addHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, 90)];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 33, 47)];
    label.text = @"评分";
    label.font = SYS_Font(15);
    label.textColor = normalColors;
    [headerView addSubview:label];

    self.starView = [[SWStarView alloc] initWithFrame:CGRectMake(label.right + 5, label.centerY - 7.5, 80, 16) starCount:5 starStyle:IncompleteStar isAllowScroe:NO];
    [headerView addSubview:self.starView];

    UILabel *highTipsLabel = [[UILabel alloc] init];
    highTipsLabel.font = SYS_Font(15);
    highTipsLabel.textColor = color64;
    highTipsLabel.text = @"好评率";
    [headerView addSubview:highTipsLabel];
    [highTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerView).offset(-15);
        make.centerY.equalTo(label);
    }];

    self.highLabel = [[UILabel alloc] init];
    self.highLabel.font = SYS_Font(15);
    self.highLabel.textColor = normalColors;
    self.highLabel.text = @"";
    [headerView addSubview:self.highLabel];
    [self.highLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(highTipsLabel.mas_left).offset(-1);
        make.centerY.equalTo(label);
    }];

    NSArray *titleArray = @[@"全部(0)", @"好评(0)", @"中评(0)", @"差评(0)"];
    MASViewAttribute *leftAnchor = label.mas_left;
    for (int i = 0; i < titleArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:0];
        [button setTitle:[NSString stringWithFormat:@"  %@  ", titleArray[i]] forState:0];
        [button setBackgroundImage:[SWToolClass getImgWithColor:colorCC] forState:0];
        [button setBackgroundImage:[SWToolClass getImgWithColor:normalColors] forState:UIControlStateSelected];
        [button setTitleColor:color32 forState:0];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        button.titleLabel.font = SYS_Font(12);
        button.layer.cornerRadius = 3;
        button.layer.masksToBounds = YES;
        button.tag = 1000 + i;
        [button addTarget:self action:@selector(typeBtnChange:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.left.equalTo(leftAnchor);
            } else {
                make.left.equalTo(leftAnchor).offset(10);
            }
            make.top.equalTo(label.mas_bottom);
            make.height.mas_equalTo(27);
        }];
        leftAnchor = button.mas_right;
        [self.buttonArray addObject:button];
        if (i == 0) {
            button.selected = YES;
        }
    }
}

- (void)typeBtnChange:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    for (UIButton *button in self.buttonArray) {
        button.selected = (button == sender);
    }
    self.type = (int)sender.tag - 1000;
    self.page = 1;
    [self requestData];
}

- (void)getReplyNums {
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"reply/config/%@", self.goodsID] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.highLabel.text = [NSString stringWithFormat:@"%@%%", minstr([info valueForKey:@"reply_chance"])];
            self.starView.currentScore = [minstr([info valueForKey:@"reply_star"]) floatValue];
            for (int i = 0; i < self.buttonArray.count; i++) {
                UIButton *button = self.buttonArray[i];
                if (i == 0) {
                    [button setTitle:[NSString stringWithFormat:@"  全部(%@)  ", minstr([info valueForKey:@"sum_count"])] forState:0];
                } else if (i == 1) {
                    [button setTitle:[NSString stringWithFormat:@"  好评(%@)  ", minstr([info valueForKey:@"good_count"])] forState:0];
                } else if (i == 2) {
                    [button setTitle:[NSString stringWithFormat:@"  中评(%@)  ", minstr([info valueForKey:@"in_count"])] forState:0];
                } else {
                    [button setTitle:[NSString stringWithFormat:@"  差评(%@)  ", minstr([info valueForKey:@"poor_count"])] forState:0];
                }
            }
        }
    } Fail:^{
    }];
}

- (UITableView *)replyTableView {
    if (!_replyTableView) {
        _replyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.naviView.bottom + 90, _window_width, _window_height - (self.naviView.bottom + 90)) style:0];
        _replyTableView.delegate = self;
        _replyTableView.dataSource = self;
        _replyTableView.separatorStyle = 0;
        _replyTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.page = 1;
            [self requestData];
        }];
        _replyTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            self.page++;
            [self requestData];
        }];
    }
    return _replyTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReplyCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWReplyCell" owner:nil options:nil] lastObject];
    }
    SWReplyModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWReplyModel *model = self.dataArray[indexPath.row];
    return model.rowH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)requestData {
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"reply/list/%@?page=%d&type=%d", self.goodsID, self.page, self.type] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.replyTableView.mj_header endRefreshing];
        [self.replyTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            for (NSDictionary *dictionary in info) {
                SWReplyModel *model = [[SWReplyModel alloc] initWithDic:dictionary];
                [self.dataArray addObject:model];
            }
            [self.replyTableView reloadData];
            if ([info count] < 20) {
                [self.replyTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } Fail:^{
        [self.replyTableView.mj_header endRefreshing];
        [self.replyTableView.mj_footer endRefreshing];
    }];
}

@end
