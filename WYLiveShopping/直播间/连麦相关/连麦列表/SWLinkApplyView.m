//
//  SWLinkApplyView.m
//  WYLiveShopping
//
//  Created by iyz on 2026/1/20.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import "SWLinkApplyView.h"
#import "SWLinkApplyCell.h"

@interface SWLinkApplyView()<UITableViewDelegate,UITableViewDataSource,LinkApplyDelegate>{
    int page;
    UIView *showView;
    UILabel *titleLable;
    NSString *liveUid;
}
@property (nonatomic,strong) UITableView *godsTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end


@implementation SWLinkApplyView

- (instancetype)initWithFrame:(CGRect)frame andLiveUid:(NSString *)uid{
    if (self = [super initWithFrame:frame]) {
        _dataArray = [NSMutableArray array];
        page = 1;
        liveUid = uid;
        [self creatUI];
        [self requestData];
    }
    return self;
}
- (void)diHide{

    [UIView animateWithDuration:0.3 animations:^{
        showView.y = _window_height;
    }completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}
- (void)show{
    self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        showView.y = _window_height-400-ShowDiff;
    }];
    page = 1;
    [self requestData];
}
- (void)creatUI{
    UIButton *closeBtn = [UIButton buttonWithType:0];
    closeBtn.frame = CGRectMake(0, 0, _window_width, _window_height-400-ShowDiff);
    [closeBtn addTarget:self action:@selector(diHide) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    showView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, 400+ShowDiff)];
    showView.backgroundColor = [UIColor whiteColor];
    [self addSubview:showView];
    showView.layer.mask = [[SWToolClass sharedInstance] setViewLeftTop:20 andRightTop:20 andView:showView];
    titleLable = [[UILabel alloc]init];
    titleLable.font = [UIFont boldSystemFontOfSize:14];
    titleLable.text = @"申请连麦";
    [showView addSubview:titleLable];
    [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(showView);
        make.centerY.equalTo(showView.mas_top).offset(20);
    }];
    if ([liveUid isEqual:[SWConfig getOwnID]]) {
        UIButton *addBtn = [UIButton buttonWithType:0];
        [addBtn setTitleColor:normalColors forState:0];
        [addBtn setTitle:@"关闭连麦" forState:0];
        addBtn.titleLabel.font = SYS_Font(12);
        [addBtn addTarget:self action:@selector(closeLink) forControlEvents:UIControlEventTouchUpInside];
        [showView addSubview:addBtn];
        [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(titleLable);
            make.right.equalTo(showView).offset(-20);
        }];
    }
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(10, 39, _window_width-20, 1) andColor:colorf0 andView:showView];

    [showView addSubview:self.godsTableView];
}

-(UITableView *)godsTableView{
    if (!_godsTableView) {
        _godsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, _window_width, showView.height-40-ShowDiff) style:0];
        _godsTableView.delegate = self;
        _godsTableView.dataSource = self;
        _godsTableView.separatorStyle = 0;
        _godsTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            page = 1;
            [self requestData];
        }];
        _godsTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            page ++;
            [self requestData];
        }];
    }
    return _godsTableView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWLinkApplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SWLinkApplyCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWLinkApplyCell" owner:nil options:nil] lastObject];
        cell.delegate = self;
    }
    cell.dataDic = _dataArray[indexPath.row];
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)requestData{
//    NSDictionary *changelive = @{
//        @"stream":minstr([[SWLinkmicManager shareInstance].roomDic valueForKey:@"stream"]),
//    };
    //
    NSString *getUrl = [NSString stringWithFormat:@"livemic/list&stream=%@&p=%@",minstr([[SWLinkmicManager shareInstance].roomDic valueForKey:@"stream"]),@(page)];
    [SWToolClass getQCloudWithUrl:getUrl Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_godsTableView.mj_header endRefreshing];
        [_godsTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (page == 1) {
                [_dataArray removeAllObjects];
            }
            [_dataArray addObjectsFromArray:info];
            [_godsTableView reloadData];
            if ([info count] < 20) {
                [_godsTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } Fail:^{
        [_godsTableView.mj_header endRefreshing];
        [_godsTableView.mj_footer endRefreshing];
    }];
}

/// 关闭连麦
-(void)closeLink{
    [[SWLinkmicManager shareInstance] livemicSwitch:0];
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeLinkSwitch)]) {
        [self.delegate closeLinkSwitch];
    }
}

#pragma mark - LinkApplyDelegate

- (void)linkToUser:(NSDictionary *)dic {

    if (self.delegate && [self.delegate respondsToSelector:@selector(agreeUserLink:)]) {
        [self.delegate agreeUserLink:dic];
    }
    // 刷新
    page = 1;
    [self requestData];
}

@end
