//
//  WYStoreGoodsView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYStoreGoodsView.h"
#import "WSLWaterFlowLayout.h"
#import "WYHomeShopColCell.h"
#import "GoodsDetailsViewController.h"

@interface WYStoreGoodsView()<UICollectionViewDelegate,UICollectionViewDataSource,WSLWaterFlowLayoutDelegate>{
    NSMutableArray *dataArray;//商品
    int page;
    NSString *mer_id;
    NSInteger goodsType;
}
@property (nonatomic,strong) UICollectionView *goodsCollectionView;
@property (nonatomic,strong) UIView *noDataView;

@end
@implementation WYStoreGoodsView
- (UIView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, 100, _window_width, 90)];
        _noDataView.hidden = YES;
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(_noDataView.width/2-42, 0, 84, 54)];
        imgV.image = [UIImage imageNamed:@"no-video"];
        [_noDataView addSubview:imgV];
        UILabel *label = [[UILabel alloc]init];
        label.font = SYS_Font(12);
        label.textColor = color96;
        label.text = @"暂无商品";
        [_noDataView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noDataView);
            make.top.equalTo(imgV.mas_bottom).offset(20);
        }];
    }
    return _noDataView;
}

-(instancetype)initWithFrame:(CGRect)frame andType:(NSInteger)type andStoreID:(NSString *)sid{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGB_COLOR(@"#fafafa", 1);
        mer_id = sid;
        goodsType = type;
        page = 1;
        dataArray = [NSMutableArray array];
        [self addSubview:self.goodsCollectionView];
        [_goodsCollectionView addSubview:self.noDataView];
        [self requestData];
        
    }
    return self;
}
- (UICollectionView *)goodsCollectionView{
    if (!_goodsCollectionView) {
//        WYWaterFallLayout * waterFallLayout = [[WYWaterFallLayout alloc]init];
//        waterFallLayout.delegate = self;
        WSLWaterFlowLayout *_flow = [[WSLWaterFlowLayout alloc] init];
        _flow.delegate = self;
        _flow.flowLayoutStyle = 0;

        _goodsCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0, self.width, self.height) collectionViewLayout:_flow];
        [_goodsCollectionView registerClass:[WYHomeShopColCell class] forCellWithReuseIdentifier:@"WYHomeShopColCELL"];

        _goodsCollectionView.delegate =self;
        _goodsCollectionView.dataSource = self;
        _goodsCollectionView.backgroundColor = colorf0;
        _goodsCollectionView.mj_footer  = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            page ++;
            [self requestData];
        }];
        
        _goodsCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            page = 1;
            [self requestData];
        }];
        
    }
    return _goodsCollectionView;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return dataArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    GoodsDetailsViewController *vc = [[GoodsDetailsViewController alloc]init];
    liveGoodsModel *model = dataArray[indexPath.row];
    vc.goodsID = model.goodsID;
    vc.liveUid = @"";
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WYHomeShopColCell *cell = (WYHomeShopColCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WYHomeShopColCELL" forIndexPath:indexPath];
    cell.model = dataArray[indexPath.row];
    return cell;
}

- (CGSize)waterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    liveGoodsModel *model = dataArray[indexPath.row];
    return CGSizeMake((_window_width-30)/2, (_window_width-30)/2 + (model.isDouble ? 78 : 58));

}
/** 列数*/
-(CGFloat)columnCountInWaterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout{
    return 2;
}
/** 列间距*/
-(CGFloat)columnMarginInWaterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout{
    return 10;
}
/** 边缘之间的间距*/
-(UIEdgeInsets)edgeInsetInWaterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
#pragma mark -- 网络请求
- (void)requestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"products&order=%d&mer_id=%@&page=%d",goodsType == 0 ? 2 : 1,mer_id,page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_goodsCollectionView.mj_header endRefreshing];
        [_goodsCollectionView.mj_footer endRefreshing];
        if (code == 200) {
            if (page == 1) {
                [dataArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                liveGoodsModel *model = [[liveGoodsModel alloc]initWithDic:dic];
                [dataArray addObject:model];
            }
            [_goodsCollectionView reloadData];
            if (dataArray.count == 0) {
                _noDataView.hidden = NO;
            }else{
                _noDataView.hidden = YES;
            }
        }
    } Fail:^{
        [_goodsCollectionView.mj_header endRefreshing];
        [_goodsCollectionView.mj_footer endRefreshing];
    }];

}

@end
