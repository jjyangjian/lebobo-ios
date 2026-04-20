//
//  SWStoreGoodsView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWStoreGoodsView.h"
#import "SWWSLWaterFlowLayout.h"
#import "SWHomeShopColCell.h"
#import "SWGoodsDetailsViewController.h"

@interface SWStoreGoodsView()<UICollectionViewDelegate, UICollectionViewDataSource, WSLWaterFlowLayoutDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int page;
@property (nonatomic, copy) NSString *storeID;
@property (nonatomic, assign) NSInteger goodsType;
@property (nonatomic, strong) UICollectionView *goodsCollectionView;
@property (nonatomic, strong) UIView *noDataView;
@end

@implementation SWStoreGoodsView

- (UIView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, _window_width, 90)];
        _noDataView.hidden = YES;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_noDataView.width / 2 - 42, 0, 84, 54)];
        imageView.image = [UIImage imageNamed:@"no-video"];
        [_noDataView addSubview:imageView];

        UILabel *label = [[UILabel alloc] init];
        label.font = SYS_Font(12);
        label.textColor = color96;
        label.text = @"暂无商品";
        [_noDataView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.noDataView);
            make.top.equalTo(imageView.mas_bottom).offset(20);
        }];
    }
    return _noDataView;
}

- (instancetype)initWithFrame:(CGRect)frame andType:(NSInteger)type andStoreID:(NSString *)sid {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGB_COLOR(@"#fafafa", 1);
        self.storeID = sid;
        self.goodsType = type;
        self.page = 1;
        self.dataArray = [NSMutableArray array];
        [self addSubview:self.goodsCollectionView];
        [self.goodsCollectionView addSubview:self.noDataView];
        [self requestData];
    }
    return self;
}

- (UICollectionView *)goodsCollectionView {
    if (!_goodsCollectionView) {
        SWWSLWaterFlowLayout *flowLayout = [[SWWSLWaterFlowLayout alloc] init];
        flowLayout.delegate = self;
        flowLayout.flowLayoutStyle = 0;

        _goodsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) collectionViewLayout:flowLayout];
        [_goodsCollectionView registerClass:[SWHomeShopColCell class] forCellWithReuseIdentifier:@"WYHomeShopColCELL"];
        _goodsCollectionView.delegate = self;
        _goodsCollectionView.dataSource = self;
        _goodsCollectionView.backgroundColor = colorf0;
        _goodsCollectionView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            self.page++;
            [self requestData];
        }];
        _goodsCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.page = 1;
            [self requestData];
        }];
    }
    return _goodsCollectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SWGoodsDetailsViewController *vc = [[SWGoodsDetailsViewController alloc] init];
    SWLiveGoodsModel *model = self.dataArray[indexPath.row];
    vc.goodsID = model.goodsID;
    vc.liveUid = @"";
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SWHomeShopColCell *cell = (SWHomeShopColCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WYHomeShopColCELL" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (CGSize)waterFlowLayout:(SWWSLWaterFlowLayout *)waterFlowLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    SWLiveGoodsModel *model = self.dataArray[indexPath.row];
    return CGSizeMake((_window_width - 30) / 2, (_window_width - 30) / 2 + (model.isDouble ? 78 : 58));
}

- (CGFloat)columnCountInWaterFlowLayout:(SWWSLWaterFlowLayout *)waterFlowLayout {
    return 2;
}

- (CGFloat)columnMarginInWaterFlowLayout:(SWWSLWaterFlowLayout *)waterFlowLayout {
    return 10;
}

- (UIEdgeInsets)edgeInsetInWaterFlowLayout:(SWWSLWaterFlowLayout *)waterFlowLayout {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark -- 网络请求

- (void)requestData {
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"products&order=%d&mer_id=%@&page=%d", self.goodsType == 0 ? 2 : 1, self.storeID, self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.goodsCollectionView.mj_header endRefreshing];
        [self.goodsCollectionView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            for (NSDictionary *dictionary in info) {
                SWLiveGoodsModel *model = [[SWLiveGoodsModel alloc] initWithDictionary:dictionary];
                [self.dataArray addObject:model];
            }
            [self.goodsCollectionView reloadData];
            self.noDataView.hidden = self.dataArray.count != 0;
        }
    } Fail:^{
        [self.goodsCollectionView.mj_header endRefreshing];
        [self.goodsCollectionView.mj_footer endRefreshing];
    }];
}

@end
