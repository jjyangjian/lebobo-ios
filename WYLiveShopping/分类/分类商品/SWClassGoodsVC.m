//
//  SWClassGoodsVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/23.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWClassGoodsVC.h"
#import "SWClassGoodsHHHCell.h"
#import "SWRecommendView.h"
#import "SWClassGoodsVVVCell.h"
#import "SWGoodsDetailsViewController.h"
#import "SWWSLWaterFlowLayout.h"
#import "SWHomeShopColCell.h"

@interface SWClassGoodsVC ()<UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,WSLWaterFlowLayoutDelegate>
@property (nonatomic, strong) UICollectionView *goodsCollectionView;
@property (nonatomic, strong) SWRecommendView *recommendV;
@property (nonatomic, strong) SWWSLWaterFlowLayout *waterLayout;
@property (nonatomic, strong) UICollectionViewFlowLayout *normalLayout;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) UIButton *changeButton;
@property (nonatomic, strong) UIButton *priceButton;
@property (nonatomic, copy) NSString *priceOrder;
@property (nonatomic, strong) UIButton *salesButton;
@property (nonatomic, copy) NSString *salesOrder;
@property (nonatomic, strong) UIButton *latestButton;
@property (nonatomic, assign) BOOL isVipPrice;

@end

@implementation SWClassGoodsVC

- (void)addSearchView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight, _window_width, 50)];
    view.backgroundColor = normalColors;
    [self.view addSubview:view];

    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, _window_width - 65, 30)];
    self.searchTextField.font = SYS_Font(14);
    self.searchTextField.placeholder = @"搜索商品";
    self.searchTextField.delegate = self;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    self.searchTextField.layer.cornerRadius = 15;
    self.searchTextField.layer.masksToBounds = YES;
    self.searchTextField.backgroundColor = RGB_COLOR(@"#ffffff", 1);
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.text = self.normalSearchStr;
    [view addSubview:self.searchTextField];

    UIView *leftV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(8, 5, 20, 20)];
    imgV.image = [UIImage imageNamed:@"搜索"];
    [leftV addSubview:imgV];
    self.searchTextField.leftView = leftV;

    self.changeButton = [UIButton buttonWithType:0];
    [self.changeButton setImage:[UIImage imageNamed:@"list_V"] forState:0];
    [self.changeButton setImage:[UIImage imageNamed:@"list_H"] forState:UIControlStateSelected];
    self.changeButton.frame = CGRectMake(self.searchTextField.right + 10, 10, 30, 30);
    [self.changeButton addTarget:self action:@selector(changeListShow) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.changeButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.page = 1;
    [self requestData];
    return YES;
}

- (void)changeListShow {
    self.changeButton.selected = !self.changeButton.selected;
    self.goodsCollectionView.collectionViewLayout = self.changeButton.selected ? self.normalLayout : self.waterLayout;
    [self.goodsCollectionView reloadData];
}

- (void)addBUttonView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight + 50, _window_width, 40)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];

    NSArray *array = @[self.cate_name, @"价格", @"销量", @"新品"];
    for (int i = 0; i < array.count; i++) {
        UIButton *button = [UIButton buttonWithType:0];
        [button setTitle:array[i] forState:0];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(_window_width * 0.25 * i, 0, _window_width * 0.25, 40);
        button.tag = 1000 + i;
        [view addSubview:button];
        if (i == 0) {
            [button setTitleColor:[self.cate_name isEqual:@"默认"] ? color32 : normalColors forState:0];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        } else {
            [button setTitleColor:color32 forState:0];
            button.titleLabel.font = SYS_Font(12);
            if (i == 1 || i == 2) {
                CGRect rect = [array[i] boundingRectWithSize:CGSizeMake(1000, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : SYS_Font(12)} context:nil];
                [button setImage:[UIImage imageNamed:@"list_nor"] forState:0];
                button.titleEdgeInsets = UIEdgeInsetsMake(0, -button.imageView.image.size.width - 2.5, 0, button.imageView.image.size.width + 2.5);
                button.imageEdgeInsets = UIEdgeInsetsMake(0, rect.size.width + 2.5, 0, -rect.size.width - 2.5);
                if (i == 1) {
                    self.priceButton = button;
                } else {
                    self.salesButton = button;
                }
            } else if (i == 3) {
                [button setTitleColor:normalColors forState:UIControlStateSelected];
                self.latestButton = button;
            }
        }
    }
}

- (void)buttonClick:(UIButton *)sender {
    if (sender.tag == 1000) {
        [super doReturn];
        return;
    }
    if (sender == self.priceButton) {
        if (self.salesOrder.length != 0) {
            self.salesOrder = @"";
            [self.salesButton setImage:[UIImage imageNamed:@"list_nor"] forState:0];
        }
        if (self.priceOrder.length == 0) {
            self.priceOrder = @"desc";
            [self.priceButton setImage:[UIImage imageNamed:@"list_top"] forState:0];
        } else if ([self.priceOrder isEqual:@"desc"]) {
            self.priceOrder = @"asc";
            [self.priceButton setImage:[UIImage imageNamed:@"list_down"] forState:0];
        } else {
            self.priceOrder = @"";
            [self.priceButton setImage:[UIImage imageNamed:@"list_nor"] forState:0];
        }
    } else if (sender == self.salesButton) {
        if (self.priceOrder.length != 0) {
            self.priceOrder = @"";
            [self.priceButton setImage:[UIImage imageNamed:@"list_nor"] forState:0];
        }
        if (self.salesOrder.length == 0) {
            self.salesOrder = @"desc";
            [self.salesButton setImage:[UIImage imageNamed:@"list_top"] forState:0];
        } else if ([self.salesOrder isEqual:@"desc"]) {
            self.salesOrder = @"asc";
            [self.salesButton setImage:[UIImage imageNamed:@"list_down"] forState:0];
        } else {
            self.salesOrder = @"";
            [self.salesButton setImage:[UIImage imageNamed:@"list_nor"] forState:0];
        }
    } else {
        self.latestButton.selected = !self.latestButton.selected;
    }
    self.page = 1;
    [self requestData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"商品列表";
    self.titleL.textColor = [UIColor whiteColor];
    self.returnBtn.selected = YES;
    self.lineView.hidden = YES;
    self.naviView.backgroundColor = normalColors;
    self.dataArray = [NSMutableArray array];
    self.page = 1;
    self.priceOrder = @"";
    self.salesOrder = @"";
    [self addSearchView];
    [self addBUttonView];
    [self.view addSubview:self.goodsCollectionView];
    [self requestData];
}

- (UICollectionView *)goodsCollectionView {
    if (!_goodsCollectionView) {
        _normalLayout = [[UICollectionViewFlowLayout alloc] init];
        _normalLayout.scrollDirection = UICollectionViewScrollDirectionVertical;

        _waterLayout = [[SWWSLWaterFlowLayout alloc] init];
        _waterLayout.delegate = self;
        _waterLayout.flowLayoutStyle = 0;

        _goodsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight + 90, _window_width, _window_height - (64 + statusbarHeight + 90)) collectionViewLayout:_waterLayout];
        [_goodsCollectionView registerNib:[UINib nibWithNibName:@"SWClassGoodsHHHCell" bundle:nil] forCellWithReuseIdentifier:@"classGoodsHHHCELL"];
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

- (SWRecommendView *)recommendV {
    if (!_recommendV) {
        _recommendV = [[SWRecommendView alloc] initWithFrame:self.goodsCollectionView.frame andNothingImage:[UIImage imageNamed:@"noShopper"]];
    }
    return _recommendV;
}

- (void)requestData {
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"products?page=%d&cid=%@&sid=%@&keyword=%@&priceOrder=%@&salesOrder=%@&news=%d", self.page, self.cid, self.sid, self.searchTextField.text, self.priceOrder, self.salesOrder, self.latestButton.selected] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.goodsCollectionView.mj_header endRefreshing];
        [self.goodsCollectionView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
                self.isVipPrice = NO;
            }
            for (NSDictionary *dic in info) {
                SWLiveGoodsModel *model = [[SWLiveGoodsModel alloc] initWithDic:dic];
                model.isAdmin = YES;
                model.is_sale = @"0";
                if (model.vip_price.length > 0) {
                    self.isVipPrice = YES;
                }
                [self.dataArray addObject:model];
            }
            [self.goodsCollectionView reloadData];
            if (self.dataArray.count == 0) {
                self.goodsCollectionView.hidden = YES;
                if (_recommendV) {
                    _recommendV.hidden = NO;
                } else {
                    [self.view addSubview:self.recommendV];
                }
            } else {
                if ([info count] < 20) {
                    [self.goodsCollectionView.mj_footer endRefreshingWithNoMoreData];
                }
                self.goodsCollectionView.hidden = NO;
                if (_recommendV) {
                    _recommendV.hidden = YES;
                }
            }
        }
    } Fail:^{
        [self.goodsCollectionView.mj_header endRefreshing];
        [self.goodsCollectionView.mj_footer endRefreshing];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SWLiveGoodsModel *model = self.dataArray[indexPath.row];
    SWGoodsDetailsViewController *vc = [[SWGoodsDetailsViewController alloc] init];
    vc.goodsID = model.goodsID;
    vc.liveUid = @"";
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.changeButton.selected) {
        SWClassGoodsHHHCell *cell = (SWClassGoodsHHHCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"classGoodsHHHCELL" forIndexPath:indexPath];
        cell.model = self.dataArray[indexPath.row];
        return cell;
    }
    SWHomeShopColCell *cell = (SWHomeShopColCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WYHomeShopColCELL" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.changeButton.selected) {
        return CGSizeMake(_window_width, 110);
    }
    if (self.isVipPrice) {
        return CGSizeMake((_window_width - 40) / 2, (_window_width - 40) / 2 + 84);
    }
    return CGSizeMake((_window_width - 40) / 2, (_window_width - 40) / 2 + 74);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return self.changeButton.selected ? UIEdgeInsetsMake(0, 0, 0, 0) : UIEdgeInsetsMake(10, 15, 10, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.changeButton.selected ? 0 : 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.changeButton.selected ? 0 : 10;
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

@end
