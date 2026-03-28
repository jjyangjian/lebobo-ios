//
//  SWStoreSearchViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/14.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWStoreSearchViewController.h"
#import "SWWSLWaterFlowLayout.h"
#import "SWHomeShopColCell.h"
#import "SWGoodsDetailsViewController.h"

@interface SWStoreSearchViewController ()<UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, WSLWaterFlowLayoutDelegate>
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) UICollectionView *goodsCollectionView;
@end

@implementation SWStoreSearchViewController

- (void)addSearchView {
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, self.naviView.height - 37, _window_width - 55, 30)];
    self.searchTextField.font = SYS_Font(13);
    self.searchTextField.textColor = color32;
    self.searchTextField.text = @"";
    self.searchTextField.delegate = self;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    self.searchTextField.layer.cornerRadius = 15;
    self.searchTextField.layer.masksToBounds = YES;
    self.searchTextField.backgroundColor = RGB_COLOR(@"#FAFAFA", 1);
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    if (self.className) {
        self.searchTextField.placeholder = [NSString stringWithFormat:@"当前店铺类目：%@", self.className];
    } else {
        self.searchTextField.placeholder = @"搜索店铺内商品";
    }
    [self.naviView addSubview:self.searchTextField];

    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    UIImageView *searchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 5, 20, 20)];
    searchImageView.image = [UIImage imageNamed:@"搜索"];
    [leftView addSubview:searchImageView];
    self.searchTextField.leftView = leftView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.page = 1;
    [self requestData];
    return YES;
}

- (UICollectionView *)goodsCollectionView {
    if (!_goodsCollectionView) {
        SWWSLWaterFlowLayout *flowLayout = [[SWWSLWaterFlowLayout alloc] init];
        flowLayout.delegate = self;
        flowLayout.flowLayoutStyle = 0;

        _goodsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight, _window_width, _window_height - (64 + statusbarHeight)) collectionViewLayout:flowLayout];
        [_goodsCollectionView registerClass:[SWHomeShopColCell class] forCellWithReuseIdentifier:@"WYHomeShopColCELL"];
        [_goodsCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"homeClollectionHeaderView"];
        _goodsCollectionView.delegate = self;
        _goodsCollectionView.dataSource = self;
        _goodsCollectionView.backgroundColor = colorf0;
        _goodsCollectionView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            self.page = 1;
            [self requestData];
        }];
        _goodsCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.page++;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    self.page = 1;
    [self addSearchView];
    [self.view addSubview:self.goodsCollectionView];
    [self requestData];
}

- (void)requestData {
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"products?page=%d&cid=%@&sid=%@&keyword=%@&mer_id=%@", self.page, self.cid, self.sid, self.searchTextField.text, self.mer_id] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.goodsCollectionView.mj_header endRefreshing];
        [self.goodsCollectionView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            for (NSDictionary *dictionary in info) {
                SWLiveGoodsModel *model = [[SWLiveGoodsModel alloc] initWithDic:dictionary];
                model.isAdmin = YES;
                model.is_sale = @"0";
                [self.dataArray addObject:model];
            }
            [self.goodsCollectionView reloadData];
        }
    } Fail:^{
        [self.goodsCollectionView.mj_header endRefreshing];
        [self.goodsCollectionView.mj_footer endRefreshing];
    }];
}

@end
