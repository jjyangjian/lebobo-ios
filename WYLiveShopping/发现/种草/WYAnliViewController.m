//
//  WYAnliViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/30.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYAnliViewController.h"
#import "WYAnliCell.h"
#import "WYAnliDetailsViewController.h"
#import "LivePlayerViewController.h"
@interface WYAnliViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *classTableV;
    NSMutableArray *dataArray;
    int p;
}
@property (nonatomic,strong) UIView *nothingView;

@end

@implementation WYAnliViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor clearColor];

    dataArray = [NSMutableArray array];
    p = 1;
    classTableV = [[UITableView alloc]initWithFrame:CGRectMake(10, 0, _window_width-20, _window_height- (79+statusbarHeight + ShowDiff+48)) style:0];
    classTableV.delegate = self;
    classTableV.dataSource = self;
    classTableV.separatorStyle = 0;
    classTableV.backgroundColor = [UIColor clearColor];
    classTableV.estimatedRowHeight = 100;
    if (@available(iOS 11.0, *)) {
        classTableV.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self.view addSubview:classTableV];
    [classTableV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.height.top.equalTo(self.view);
        make.width.equalTo(self.view).offset(-20);
    }];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        p = 1;
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
    classTableV.mj_header = header;
    classTableV.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        p ++;
        [self requeestData];
    }];
    [self creatNothingView];
    [self requeestData];
}
- (void)reloadList{
    [self requeestData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [classTableV.mj_header endRefreshing];
    [classTableV.mj_footer endRefreshing];
}
- (void)requeestData{
    if (_classID) {
        NSString *url;
        if (_typeValue == 3) {
            url = [NSString stringWithFormat:@"kollive?page=%d",p];
        }else{
            if ([_classID isEqual:@"follow"]) {
                url = [NSString stringWithFormat:@"livefollow?page=%d",p];
            }else if ([_classID isEqual:@"0"]) {
                url = [NSString stringWithFormat:@"featured?page=%d",p];
            }else{
                url = [NSString stringWithFormat:@"classlive/%@?page=%d",_classID,p];
            }
        }
        [WYToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [classTableV.mj_header endRefreshing];
            [classTableV.mj_footer endRefreshing];
            if (code == 200) {
                if (p == 1) {
                    [dataArray removeAllObjects];
                }
                if ([_classID isEqual:@"0"]) {
                    NSArray *list = [info valueForKey:@"list"];
                    for (NSDictionary *dic in list) {
                        HomeLiveModel *model = [[HomeLiveModel alloc]initWithDic:dic];
                        [dataArray addObject:model];
                    }
                }else{
                    for (NSDictionary *dic in info) {
                        HomeLiveModel *model = [[HomeLiveModel alloc]initWithDic:dic];
                        [dataArray addObject:model];
                    }
                }
                [classTableV reloadData];
                if ([info count] < 20) {
                    [classTableV.mj_footer endRefreshingWithNoMoreData];
                }
                if ([dataArray count] == 0) {
                    classTableV.backgroundColor = [UIColor whiteColor];
                    _nothingView.hidden = NO;
                }else{
                    _nothingView.hidden = YES;
                    classTableV.backgroundColor = [UIColor clearColor];

                }
            }
            
        } Fail:^{
            [classTableV.mj_header endRefreshing];
            [classTableV.mj_footer endRefreshing];
        }];

    }else{
        NSString *url;
        if (_typeValue == 0) {
            url = [NSString stringWithFormat:@"kolfollow&page=%d",p];
        }else if(_typeValue == 1){
            url = [NSString stringWithFormat:@"kollist&page=%d&type=2",p];
        }else{
            url = [NSString stringWithFormat:@"kollist&page=%d&type=1",p];
        }
        [WYToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [classTableV.mj_header endRefreshing];
            [classTableV.mj_footer endRefreshing];
            if (code == 200) {
                if (p == 1) {
                    [dataArray removeAllObjects];
                }
                for (NSDictionary *dic in info) {
                    WYAnliModel *model = [[WYAnliModel alloc] initWithDic:dic];
                    [dataArray addObject:model];
                }
                [classTableV reloadData];
                if ([dataArray count] == 0) {
                    classTableV.backgroundColor = [UIColor whiteColor];
                    _nothingView.hidden = NO;
                }else{
                    _nothingView.hidden = YES;
                    classTableV.backgroundColor = [UIColor clearColor];

                }
            }
        } Fail:^{
            [classTableV.mj_header endRefreshing];
            [classTableV.mj_footer endRefreshing];

        }];
    }
//    [MBProgressHUD hideHUD];
//    [MBProgressHUD showMessage:@""];
//    [WYToolClass postNetworkWithUrl:@"Course.GetMyCourse" andParameter:@{@"p":@(p),@"type":_type,@"keyword":_keyword?_keyword:@""} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
//        [classTableV.mj_header endRefreshing];
//        [classTableV.mj_footer endRefreshing];
//        [MBProgressHUD hideHUD];
//        if (code == 0) {
//            if (p == 1) {
//                [dataArray removeAllObjects];
//            }
//            for (NSDictionary *dic in info) {
//                courseModel *model = [[courseModel alloc] initWithDic:dic];
//                [dataArray addObject:model];
//            }
//            [classTableV reloadData];
//            if (dataArray.count > 0) {
//                _nothingView.hidden = YES;
//            }else{
//                _nothingView.hidden = NO;
//            }
//        }
//    } fail:^{
//        [MBProgressHUD hideHUD];
//        [classTableV.mj_header endRefreshing];
//        [classTableV.mj_footer endRefreshing];
//
//    }];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WYAnliCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WYAnliCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WYAnliCell" owner:nil options:nil] lastObject];
        [cell.followBtn setBackgroundImage:[WYToolClass getImgWithColor:normalColors] forState:0];
        [cell.followBtn setBackgroundImage:[WYToolClass getImgWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
        if (_classID) {
            cell.likeBtn.hidden = YES;
        }
    }
    if (_classID) {
        HomeLiveModel *model = dataArray[indexPath.section];
        cell.livemodel = model;
    }else{
        WYAnliModel *model = dataArray[indexPath.section];
        cell.model = model;
    }
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_classID) {
        HomeLiveModel *model = dataArray[indexPath.section];
        return model.rowH;
    }else{
        WYAnliModel *model = dataArray[indexPath.section];
        return model.rowH;
    }

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_classID) {
        HomeLiveModel *model = dataArray[indexPath.section];
        [MBProgressHUD showMessage:@""];
        [[WYToolClass sharedInstance] removeSusPlayer];
        [self checkLive:model];

    }else{
        WYAnliDetailsViewController *vc = [[WYAnliDetailsViewController alloc]init];
        vc.model = dataArray[indexPath.section];
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}
- (void)creatNothingView{
    _nothingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, classTableV.width, classTableV.height)];
//    _nothingView.backgroundColor = [UIColor whiteColor];
    _nothingView.hidden = YES;
    [classTableV addSubview:_nothingView];
    if (_classID && _typeValue != 3) {
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(_nothingView.width/2-42, 100, 84, 54)];
        imgV.image = [UIImage imageNamed:@"no-video"];
        [_nothingView addSubview:imgV];
        UILabel *label = [[UILabel alloc]init];
        label.font = SYS_Font(12);
        label.textColor = color96;
        label.text = @"暂无直播";
        [_nothingView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_nothingView);
            make.top.equalTo(imgV.mas_bottom).offset(20);
        }];

    }else{
        UIImageView *_nothingImgV = [[UIImageView alloc]initWithFrame:CGRectMake(_nothingView.width/2-40, 120, 80, 80)];
        _nothingImgV.contentMode = UIViewContentModeScaleAspectFit;
        _nothingImgV.image = [UIImage imageNamed:@"no-video"];
        [_nothingView addSubview:_nothingImgV];
        UILabel *_nothingTitleL = [[UILabel alloc]initWithFrame:CGRectMake(0, _nothingImgV.bottom+10, _window_width, 15)];
        _nothingTitleL.font = [UIFont systemFontOfSize:12];
        _nothingTitleL.textAlignment = NSTextAlignmentCenter;
        _nothingTitleL.text = @"暂无数据，去其他频道看看吧～";
        _nothingTitleL.textColor = colorCC;
        [_nothingView addSubview:_nothingTitleL];
    }

    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (void)checkLive:(HomeLiveModel *)model{
    [WYToolClass postNetworkWithUrl:@"live/check" andParameter:@{@"stream":model.stream} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            LivePlayerViewController *player = [[LivePlayerViewController alloc]init];
            player.roomDic = [model.originDic mutableCopy];
            [[MXBADelegate sharedAppDelegate] pushViewController:player animated:YES];
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
