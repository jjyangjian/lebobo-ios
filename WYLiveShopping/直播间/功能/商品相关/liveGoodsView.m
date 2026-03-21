//
//  liveGoodsView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "liveGoodsView.h"
#import "liveGoodsCell.h"
#import "AddGoodsViewController.h"
#import "GoodsDetailsViewController.h"

@interface liveGoodsView ()<UITableViewDelegate,UITableViewDataSource,liveGoodsCellDelegate>{
    int page;
    UIView *showView;
    UILabel *titleLable;
    NSString *liveUid;
}
@property (nonatomic,strong) UITableView *godsTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation liveGoodsView

- (instancetype)initWithFrame:(CGRect)frame andLiveUid:(NSString *)uid{
    if (self = [super initWithFrame:frame]) {
        _dataArray = [NSMutableArray array];
        page = 1;
        liveUid = uid;
        [self creatUI];
        [self getSellerGoodsNum];
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
}
- (void)creatUI{
    UIButton *closeBtn = [UIButton buttonWithType:0];
    closeBtn.frame = CGRectMake(0, 0, _window_width, _window_height-400-ShowDiff);
    [closeBtn addTarget:self action:@selector(diHide) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    showView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, 400+ShowDiff)];
    showView.backgroundColor = [UIColor whiteColor];
    [self addSubview:showView];
    showView.layer.mask = [[WYToolClass sharedInstance] setViewLeftTop:20 andRightTop:20 andView:showView];
    titleLable = [[UILabel alloc]init];
    titleLable.font = [UIFont boldSystemFontOfSize:14];
    titleLable.text = @"在售商品 (0)";
    [showView addSubview:titleLable];
    [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(showView);
        make.centerY.equalTo(showView.mas_top).offset(20);
    }];
    if ([liveUid isEqual:[Config getOwnID]]) {
        UIButton *addBtn = [UIButton buttonWithType:0];
        [addBtn setTitleColor:normalColors forState:0];
        [addBtn setTitle:@"添加商品" forState:0];
        addBtn.titleLabel.font = SYS_Font(12);
        [addBtn addTarget:self action:@selector(addGoods) forControlEvents:UIControlEventTouchUpInside];
        [showView addSubview:addBtn];
        [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(titleLable);
            make.right.equalTo(showView).offset(-20);
        }];
    }
    [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(10, 39, _window_width-20, 1) andColor:colorf0 andView:showView];
    
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
            [self getSellerGoodsNum];
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
    liveGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"liveGoodsCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"liveGoodsCell" owner:nil options:nil] lastObject];
        cell.delegate = self;
        if (![liveUid isEqual:[Config getOwnID]]) {
            [cell.caozuoBtn setTitle:@"去购买" forState:0];
            [cell.caozuoBtn setBackgroundColor:normalColors];
            [cell.caozuoBtn setTitleColor:[UIColor whiteColor] forState:0];
        }
    }
    cell.model = _dataArray[indexPath.row];
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)requestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"shopsale?liveuid=%@&page=%d",liveUid,page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_godsTableView.mj_header endRefreshing];
        [_godsTableView.mj_footer endRefreshing];

        if (code == 200) {
            if (page == 1) {
                [_dataArray removeAllObjects];
            }
            for (NSDictionary *dci in info) {
                liveGoodsModel *model = [[liveGoodsModel alloc]initWithDic:dci];
                [_dataArray addObject:model];
            }
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
//添加商品
- (void)addGoods{
    AddGoodsViewController *vc = [[AddGoodsViewController alloc]init];
    WeakSelf;
    vc.block = ^(NSDictionary * _Nonnull dic) {
        [weakSelf getSellerGoodsNum];
        [weakSelf.godsTableView.mj_header beginRefreshing];
    };
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)getSellerGoodsNum{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"shopsalenums?liveuid=%@",liveUid] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            titleLable.text = [NSString stringWithFormat:@"在售商品 (%@)",minstr([info valueForKey:@"nums"])];
        }
    } Fail:^{
        
    }];
}
-(void)DismountGoods:(liveGoodsModel *)model{
    if ([liveUid isEqual:[Config getOwnID]]) {
        ///下架
        [MBProgressHUD showMessage:@""];
        [WYToolClass postNetworkWithUrl:@"setsale" andParameter:@{@"productid":model.goodsID,@"issale":@"0"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUD];
                    [_dataArray removeObject:model];
                    [_godsTableView reloadData];
                    [MBProgressHUD showError:msg];
                    [self getSellerGoodsNum];
                });
                
            }
        } fail:^{
            
        }];
    }else{
        ///去购买
        GoodsDetailsViewController *vc = [[GoodsDetailsViewController alloc]init];
        vc.goodsID = model.goodsID;
        vc.liveUid = liveUid;
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}
@end
