//
//  SWLiveGoodsView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWLiveGoodsView.h"
#import "SWLiveGoodsCell.h"
#import "SWAddGoodsViewController.h"
#import "SWGoodsDetailsViewController.h"

@interface SWLiveGoodsView ()<UITableViewDelegate,UITableViewDataSource,liveGoodsCellDelegate>{
    int page;
    UIView *showView;
    UILabel *titleLabel;
    NSString *liveUid;
}
@property (nonatomic,strong) UITableView *goodsTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation SWLiveGoodsView

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
    showView.layer.mask = [[SWToolClass sharedInstance] setViewLeftTop:20 andRightTop:20 andView:showView];
    titleLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.text = @"在售商品 (0)";
    [showView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(showView);
        make.centerY.equalTo(showView.mas_top).offset(20);
    }];
    if ([liveUid isEqual:[SWConfig getOwnID]]) {
        UIButton *addBtn = [UIButton buttonWithType:0];
        [addBtn setTitleColor:normalColors forState:0];
        [addBtn setTitle:@"添加商品" forState:0];
        addBtn.titleLabel.font = SYS_Font(12);
        [addBtn addTarget:self action:@selector(addGoods) forControlEvents:UIControlEventTouchUpInside];
        [showView addSubview:addBtn];
        [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(titleLabel);
            make.right.equalTo(showView).offset(-20);
        }];
    }
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(10, 39, _window_width-20, 1) andColor:colorf0 andView:showView];
    
    [showView addSubview:self.goodsTableView];
}
-(UITableView *)goodsTableView{
    if (!_goodsTableView) {
        _goodsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, _window_width, showView.height-40-ShowDiff) style:0];
        _goodsTableView.delegate = self;
        _goodsTableView.dataSource = self;
        _goodsTableView.separatorStyle = 0;
        _goodsTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            page = 1;
            [self requestData];
            [self getSellerGoodsNum];
        }];
        _goodsTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            page ++;
            [self requestData];
        }];
    }
    return _goodsTableView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWLiveGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"liveGoodsCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWLiveGoodsCell" owner:nil options:nil] lastObject];
        cell.delegate = self;
        if (![liveUid isEqual:[SWConfig getOwnID]]) {
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
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"shopsale?liveuid=%@&page=%d",liveUid,page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_goodsTableView.mj_header endRefreshing];
        [_goodsTableView.mj_footer endRefreshing];

        if (code == 200) {
            if (page == 1) {
                [_dataArray removeAllObjects];
            }
            for (NSDictionary *itemMap in info) {
                SWLiveGoodsModel *model = [[SWLiveGoodsModel alloc]initWithDictionary:itemMap];
                [_dataArray addObject:model];
            }
            [_goodsTableView reloadData];
            if ([info count] < 20) {
                [_goodsTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } Fail:^{
        [_goodsTableView.mj_header endRefreshing];
        [_goodsTableView.mj_footer endRefreshing];
    }];
}
//添加商品
- (void)addGoods{
    SWAddGoodsViewController *vc = [[SWAddGoodsViewController alloc]init];
    WeakSelf;
    vc.block = ^(NSDictionary * _Nonnull goodsMap) {
        [weakSelf getSellerGoodsNum];
        [weakSelf.goodsTableView.mj_header beginRefreshing];
    };
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)getSellerGoodsNum{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"shopsalenums?liveuid=%@",liveUid] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            titleLabel.text = [NSString stringWithFormat:@"在售商品 (%@)",minstr([info valueForKey:@"nums"])];
        }
    } Fail:^{
        
    }];
}
-(void)DismountGoods:(SWLiveGoodsModel *)model{
    if ([liveUid isEqual:[SWConfig getOwnID]]) {
        ///下架
        [MBProgressHUD showMessage:@""];
        [SWToolClass postNetworkWithUrl:@"setsale" andParameter:@{@"productid":model.goodsID,@"issale":@"0"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUD];
                    [_dataArray removeObject:model];
                    [_goodsTableView reloadData];
                    [MBProgressHUD showError:msg];
                    [self getSellerGoodsNum];
                });
                
            }
        } fail:^{
            
        }];
    }else{
        ///去购买
        SWGoodsDetailsViewController *vc = [[SWGoodsDetailsViewController alloc]init];
        vc.goodsID = model.goodsID;
        vc.liveUid = liveUid;
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}
@end
