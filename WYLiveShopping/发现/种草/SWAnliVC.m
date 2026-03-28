//
//  SWAnliVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/30.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWAnliVC.h"
#import "SWAnliCell.h"
#import "SWAnliDetailsVC.h"
#import "SWLivePlayerViewController.h"

@interface SWAnliVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *classTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) UIView *nothingView;

@end

@implementation SWAnliVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor clearColor];

    self.dataArray = [NSMutableArray array];
    self.page = 1;
    self.classTableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 0, _window_width-20, _window_height-(79+statusbarHeight+ShowDiff+48)) style:0];
    self.classTableView.delegate = self;
    self.classTableView.dataSource = self;
    self.classTableView.separatorStyle = 0;
    self.classTableView.backgroundColor = [UIColor clearColor];
    self.classTableView.estimatedRowHeight = 100;
    if (@available(iOS 11.0, *)) {
        self.classTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self.view addSubview:self.classTableView];
    [self.classTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.height.top.equalTo(self.view);
        make.width.equalTo(self.view).offset(-20);
    }];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        [self requeestData];
    }];
    if (_classID && _typeValue != 3) {
        header.stateLabel.textColor = color32;
        header.lastUpdatedTimeLabel.textColor = color32;
        header.loadingView.color = color32;
    }else{
        header.stateLabel.textColor = [UIColor whiteColor];
        header.lastUpdatedTimeLabel.textColor = [UIColor whiteColor];
        header.loadingView.color = [UIColor whiteColor];
    }
    self.classTableView.mj_header = header;
    self.classTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        self.page ++;
        [self requeestData];
    }];
    [self creatNothingView];
    [self requeestData];
}
- (void)reloadList{
    [self requeestData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.classTableView.mj_header endRefreshing];
    [self.classTableView.mj_footer endRefreshing];
}
- (void)requeestData{
    if (_classID) {
        NSString *url;
        if (_typeValue == 3) {
            url = [NSString stringWithFormat:@"kollive?page=%ld", (long)self.page];
        }else{
            if ([_classID isEqual:@"follow"]) {
                url = [NSString stringWithFormat:@"livefollow?page=%ld", (long)self.page];
            }else if ([_classID isEqual:@"0"]) {
                url = [NSString stringWithFormat:@"featured?page=%ld", (long)self.page];
            }else{
                url = [NSString stringWithFormat:@"classlive/%@?page=%ld", _classID, (long)self.page];
            }
        }
        [SWToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [self.classTableView.mj_header endRefreshing];
            [self.classTableView.mj_footer endRefreshing];
            if (code == 200) {
                if (self.page == 1) {
                    [self.dataArray removeAllObjects];
                }
                if ([_classID isEqual:@"0"]) {
                    NSArray *list = [info valueForKey:@"list"];
                    for (NSDictionary *dic in list) {
                        SWHomeLiveModel *model = [[SWHomeLiveModel alloc]initWithDic:dic];
                        [self.dataArray addObject:model];
                    }
                }else{
                    for (NSDictionary *dic in info) {
                        SWHomeLiveModel *model = [[SWHomeLiveModel alloc]initWithDic:dic];
                        [self.dataArray addObject:model];
                    }
                }
                [self.classTableView reloadData];
                if ([info count] < 20) {
                    [self.classTableView.mj_footer endRefreshingWithNoMoreData];
                }
                if (self.dataArray.count == 0) {
                    self.classTableView.backgroundColor = [UIColor whiteColor];
                    self.nothingView.hidden = NO;
                }else{
                    self.nothingView.hidden = YES;
                    self.classTableView.backgroundColor = [UIColor clearColor];
                }
            }
        } Fail:^{
            [self.classTableView.mj_header endRefreshing];
            [self.classTableView.mj_footer endRefreshing];
        }];

    }else{
        NSString *url;
        if (_typeValue == 0) {
            url = [NSString stringWithFormat:@"kolfollow&page=%ld", (long)self.page];
        }else if(_typeValue == 1){
            url = [NSString stringWithFormat:@"kollist&page=%ld&type=2", (long)self.page];
        }else{
            url = [NSString stringWithFormat:@"kollist&page=%ld&type=1", (long)self.page];
        }
        [SWToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [self.classTableView.mj_header endRefreshing];
            [self.classTableView.mj_footer endRefreshing];
            if (code == 200) {
                if (self.page == 1) {
                    [self.dataArray removeAllObjects];
                }
                for (NSDictionary *dic in info) {
                    SWAnliModel *model = [[SWAnliModel alloc] initWithDic:dic];
                    [self.dataArray addObject:model];
                }
                [self.classTableView reloadData];
                if (self.dataArray.count == 0) {
                    self.classTableView.backgroundColor = [UIColor whiteColor];
                    self.nothingView.hidden = NO;
                }else{
                    self.nothingView.hidden = YES;
                    self.classTableView.backgroundColor = [UIColor clearColor];
                }
            }
        } Fail:^{
            [self.classTableView.mj_header endRefreshing];
            [self.classTableView.mj_footer endRefreshing];

        }];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWAnliCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WYAnliCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWAnliCell" owner:nil options:nil] lastObject];
        [cell.followBtn setBackgroundImage:[SWToolClass getImgWithColor:normalColors] forState:0];
        [cell.followBtn setBackgroundImage:[SWToolClass getImgWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
        if (_classID) {
            cell.likeBtn.hidden = YES;
        }
    }
    if (_classID) {
        SWHomeLiveModel *model = self.dataArray[indexPath.section];
        cell.livemodel = model;
    }else{
        SWAnliModel *model = self.dataArray[indexPath.section];
        cell.model = model;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_classID) {
        SWHomeLiveModel *model = self.dataArray[indexPath.section];
        return model.rowH;
    }else{
        SWAnliModel *model = self.dataArray[indexPath.section];
        return model.rowH;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_classID) {
        SWHomeLiveModel *model = self.dataArray[indexPath.section];
        [MBProgressHUD showMessage:@""];
        [[SWToolClass sharedInstance] removeSusPlayer];
        [self checkLive:model];
    }else{
        SWAnliDetailsVC *vc = [[SWAnliDetailsVC alloc]init];
        vc.model = self.dataArray[indexPath.section];
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}
- (void)creatNothingView{
    self.nothingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.classTableView.width, self.classTableView.height)];
    self.nothingView.hidden = YES;
    [self.classTableView addSubview:self.nothingView];
    if (_classID && _typeValue != 3) {
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(self.nothingView.width/2-42, 100, 84, 54)];
        imgV.image = [UIImage imageNamed:@"no-video"];
        [self.nothingView addSubview:imgV];
        UILabel *label = [[UILabel alloc]init];
        label.font = SYS_Font(12);
        label.textColor = color96;
        label.text = @"暂无直播";
        [self.nothingView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.nothingView);
            make.top.equalTo(imgV.mas_bottom).offset(20);
        }];

    }else{
        UIImageView *nothingImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.nothingView.width/2-40, 120, 80, 80)];
        nothingImageView.contentMode = UIViewContentModeScaleAspectFit;
        nothingImageView.image = [UIImage imageNamed:@"no-video"];
        [self.nothingView addSubview:nothingImageView];
        UILabel *nothingTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, nothingImageView.bottom+10, _window_width, 15)];
        nothingTitleLabel.font = [UIFont systemFontOfSize:12];
        nothingTitleLabel.textAlignment = NSTextAlignmentCenter;
        nothingTitleLabel.text = @"暂无数据，去其他频道看看吧～";
        nothingTitleLabel.textColor = colorCC;
        [self.nothingView addSubview:nothingTitleLabel];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (void)checkLive:(SWHomeLiveModel *)model{
    [SWToolClass postNetworkWithUrl:@"live/check" andParameter:@{@"stream":model.stream} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            SWLivePlayerViewController *player = [[SWLivePlayerViewController alloc]init];
            player.roomDic = [model.originDic mutableCopy];
            [[SWMXBADelegate sharedAppDelegate] pushViewController:player animated:YES];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
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
