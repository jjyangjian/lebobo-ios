//
//  WYStoreSearchViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/14.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYStoreSearchViewController.h"
#import "WSLWaterFlowLayout.h"
#import "WYHomeShopColCell.h"
#import "GoodsDetailsViewController.h"

@interface WYStoreSearchViewController ()<UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,WSLWaterFlowLayoutDelegate>{
    UITextField *searchTextF;
    NSMutableArray *dataArray;
    int page;
}
@property (nonatomic,strong) UICollectionView *goodsCollectionView;

@end

@implementation WYStoreSearchViewController
- (void)addSearchView{
    searchTextF = [[UITextField alloc]initWithFrame:CGRectMake(40, self.naviView.height-37, _window_width-55, 30)];
    searchTextF.font = SYS_Font(13);
    searchTextF.textColor = color32;
    searchTextF.text = @"";
    searchTextF.delegate = self;
    searchTextF.leftViewMode = UITextFieldViewModeAlways;
    searchTextF.layer.cornerRadius = 15;
    searchTextF.layer.masksToBounds = YES;
    searchTextF.backgroundColor = RGB_COLOR(@"#FAFAFA", 1);
    searchTextF.returnKeyType = UIReturnKeySearch;
    if (_className) {
        searchTextF.placeholder = [NSString stringWithFormat:@"当前店铺类目：%@",_className];
    }else{
        searchTextF.placeholder = @"搜索店铺内商品";
    }
    [self.naviView addSubview:searchTextF];
    UIView *leftV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(8, 5, 20, 20)];
    imgV.image = [UIImage imageNamed:@"搜索"];
    [leftV addSubview:imgV];
    searchTextF.leftView = leftV;

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    page = 1;
    [self requestData];
    return YES;
}
- (UICollectionView *)goodsCollectionView{
    if (!_goodsCollectionView) {
//        WYWaterFallLayout * waterFallLayout = [[WYWaterFallLayout alloc]init];
//        waterFallLayout.delegate = self;
        WSLWaterFlowLayout *_flow = [[WSLWaterFlowLayout alloc] init];
        _flow.delegate = self;
        _flow.flowLayoutStyle = 0;

//        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
//        flow.scrollDirection = UICollectionViewScrollDirectionVertical;
//        flow.minimumLineSpacing = 10;
//        flow.minimumInteritemSpacing = 10;
//        flow.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
//        flow.headerReferenceSize = CGSizeMake(_window_width, _window_height);
        _goodsCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,64+statusbarHeight, _window_width, _window_height-(64+statusbarHeight)) collectionViewLayout:_flow];
        [_goodsCollectionView registerClass:[WYHomeShopColCell class] forCellWithReuseIdentifier:@"WYHomeShopColCELL"];
        [_goodsCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"homeClollectionHeaderView"];

        _goodsCollectionView.delegate =self;
        _goodsCollectionView.dataSource = self;
        _goodsCollectionView.backgroundColor = colorf0;
        _goodsCollectionView.mj_footer  = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            page = 1;
            [self requestData];
        }];
        
        _goodsCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            page ++;
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

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    liveGoodsModel *model = dataArray[indexPath.row];
//    return CGSizeMake((_window_width-30)/2, (_window_width-30)/2 + (model.isDouble ? 78 : 58));
//}
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


- (void)viewDidLoad {
    [super viewDidLoad];
    dataArray = [NSMutableArray array];
    page = 1;
    [self addSearchView];
    [self.view addSubview:self.goodsCollectionView];
    [self requestData];
}
- (void)requestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"products?page=%d&cid=%@&sid=%@&keyword=%@&mer_id=%@",page,_cid,_sid,searchTextF.text,_mer_id] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_goodsCollectionView.mj_header endRefreshing];
        [_goodsCollectionView.mj_footer endRefreshing];
        if (code == 200) {
            if (page == 1) {
                [dataArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                liveGoodsModel *model = [[liveGoodsModel alloc]initWithDic:dic];
                model.isAdmin = YES;
                model.is_sale = @"0";
                [dataArray addObject:model];
            }
            
            [_goodsCollectionView reloadData];
        }
    } Fail:^{
        [_goodsCollectionView.mj_header endRefreshing];
        [_goodsCollectionView.mj_footer endRefreshing];
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
