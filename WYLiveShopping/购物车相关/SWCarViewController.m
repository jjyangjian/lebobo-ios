//
//  SWCarViewController.m
//  YBEducation
//
//  Created by IOS1 on 2020/5/6.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWCarViewController.h"
#import "SWCartGoodsCell.h"
#import "SWGoodsDetailsViewController.h"
#import "SWCartInvalidCell.h"
#import "SWCarBottomView.h"
#import "SWRecommendView.h"
#import "SWGoodsDetailsViewController.h"
#import "SWSubmitOrderVC.h"

@interface SWCarViewController ()<UITableViewDelegate, UITableViewDataSource, SWCartGoodsCellDelegate>
@property (nonatomic, strong) UILabel *cartCountLabel;
@property (nonatomic, strong) UIButton *adminButton;
@property (nonatomic, strong) NSMutableArray *invalidArray;
@property (nonatomic, strong) UIView *invalidView;
@property (nonatomic, strong) UITableView *carTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *invalidTableView;
@property (nonatomic, strong) SWCarBottomView *carBottomView;
@property (nonatomic, strong) SWRecommendView *recommendView;
@end

@implementation SWCarViewController
- (SWRecommendView *)recommendView{
    if (!_recommendView) {
        _recommendView = [[SWRecommendView alloc] initWithFrame:CGRectMake(0, self.naviView.bottom + 55, _window_width, _window_height - (self.naviView.bottom + 55 + ShowDiff + 48)) andNothingImage:[UIImage imageNamed:@"noCart"]];
        if (!self.isTabbar) {
            _recommendView.height = _window_height - (self.naviView.bottom + 55 + ShowDiff);
        }
    }
    return _recommendView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.titleL.text = @"购物车";
    if (self.isTabbar) {
        self.returnBtn.hidden = YES;
    }
    self.dataArray = [NSMutableArray array];
    self.invalidArray = [NSMutableArray array];
    [self addHeaderView];
    [self requestCartNums];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestCartNums) name:WYCarNumChange object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [self requestData];
}

- (void)addHeaderView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, 55)];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];

    UILabel *label = [[UILabel alloc] init];
    label.text = @"商品数量";
    label.font = SYS_Font(12);
    label.textColor = color32;
    [headerView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(18);
        make.centerY.equalTo(headerView.mas_top).offset(25);
    }];

    self.cartCountLabel = [[UILabel alloc] init];
    self.cartCountLabel.text = @"";
    self.cartCountLabel.font = SYS_Font(12);
    self.cartCountLabel.textColor = normalColors;
    [headerView addSubview:self.cartCountLabel];
    [self.cartCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label.mas_right).offset(3);
        make.centerY.equalTo(label);
    }];

    self.adminButton = [UIButton buttonWithType:0];
    self.adminButton.layer.cornerRadius = 3;
    self.adminButton.layer.masksToBounds = YES;
    self.adminButton.layer.borderColor = color96.CGColor;
    self.adminButton.layer.borderWidth = 1;
    [self.adminButton setTitle:@"管理" forState:0];
    [self.adminButton setTitle:@"取消" forState:UIControlStateSelected];
    [self.adminButton setTitleColor:color32 forState:0];
    self.adminButton.titleLabel.font = SYS_Font(10);
    [self.adminButton addTarget:self action:@selector(doAdminCartGoods) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.adminButton];
    [self.adminButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerView).offset(-15);
        make.centerY.equalTo(label);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(20);
    }];
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 50, _window_width, 5) andColor:colorf0 andView:headerView];
}

- (void)requestCartNums{
    [SWToolClass getQCloudWithUrl:@"cart/count?numType=true" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.cartCountLabel.text = minstr([info valueForKey:@"count"]);
            if (self.carBottomView) {
                self.carBottomView.numsLabel.text = [NSString stringWithFormat:@"全选(%@)", minstr([info valueForKey:@"count"])];
            }
        }
    } Fail:^{
    }];
}

- (UITableView *)carTableView{
    if (!_carTableView) {
        _carTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.naviView.bottom + 55, _window_width, _window_height - (self.naviView.bottom + 55 + 60 + ShowDiff + 48)) style:1];
        if (!self.isTabbar) {
            _carTableView.height = _window_height - (self.naviView.bottom + 55 + 60 + ShowDiff);
        }
        _carTableView.delegate = self;
        _carTableView.dataSource = self;
        _carTableView.separatorStyle = 0;
        _carTableView.backgroundColor = colorf0;
        if (@available(iOS 15.0, *)) {
            _carTableView.sectionHeaderTopPadding = 0;
        }
    }
    return _carTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.carTableView) {
        NSArray *array = [self.dataArray[section] valueForKey:@"model"];
        return array.count;
    }
    return self.invalidArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.carTableView) {
        return self.dataArray.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.carTableView) {
        SWCartGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cartGoodsCELL"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SWCartGoodsCell" owner:nil options:nil] lastObject];
            cell.delegate = self;
        }
        NSArray *array = [self.dataArray[indexPath.section] valueForKey:@"model"];
        cell.model = array[indexPath.row];
        return cell;
    } else {
        SWCartInvalidCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cartInvalidCELL"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SWCartInvalidCell" owner:nil options:nil] lastObject];
        }
        cell.model = self.invalidArray[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.carTableView) {
        return 120;
    }
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.carTableView) {
        return 40;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == self.carTableView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, 40)];
        view.backgroundColor = [UIColor whiteColor];
        UIButton *button = [UIButton buttonWithType:0];
        [button setImage:[UIImage imageNamed:@"jubao_nor"] forState:0];
        [button setImage:[UIImage imageNamed:@"cart_sel"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(headerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = section + 1000;
        button.selected = YES;
        [view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(15);
            make.centerY.equalTo(view);
            make.width.height.mas_equalTo(25);
        }];

        UIImageView *imgV = [[UIImageView alloc] init];
        imgV.image = [UIImage imageNamed:@"小店"];
        [view addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(button.mas_right).offset(10);
            make.centerY.equalTo(view);
            make.width.mas_equalTo(18);
            make.height.mas_equalTo(16);
        }];

        NSDictionary *dictionary = self.dataArray[section];
        UILabel *label = [[UILabel alloc] init];
        label.text = minstr([dictionary valueForKey:@"name"]);
        label.font = SYS_Font(14);
        label.textColor = color32;
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imgV.mas_right).offset(8);
            make.centerY.equalTo(view);
        }];
        for (SWCartModel *model in [dictionary valueForKey:@"model"]) {
            if (!model.isSelected) {
                button.selected = NO;
            }
        }
        [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(15, 39, _window_width - 30, 1) andColor:RGB_COLOR(@"#eeeeee", 1) andView:view];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (tableView == self.carTableView) {
        return 5;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (tableView == self.carTableView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, 5)];
        view.backgroundColor = RGB_COLOR(@"#eeeeee", 1);
        return view;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.carTableView) {
        NSArray *array = [self.dataArray[indexPath.section] valueForKey:@"model"];
        SWCartModel *model = array[indexPath.row];
        SWGoodsDetailsViewController *vc = [[SWGoodsDetailsViewController alloc] init];
        vc.goodsID = model.goods_id;
        vc.liveUid = @"";
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

- (void)requestData{
    [SWToolClass getQCloudWithUrl:@"cart/list" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            NSArray *valid = [info valueForKey:@"valid"];
            NSArray *invalid = [info valueForKey:@"invalid"];
            if ([valid count] > 0 || [invalid count] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.carTableView) {
                        self.carTableView.hidden = NO;
                        self.carBottomView.hidden = NO;
                    } else {
                        [self.view addSubview:self.carTableView];
                        [self.view addSubview:self.carBottomView];
                    }
                    if (self.recommendView) {
                        self.recommendView.hidden = YES;
                    }

                    [self.dataArray removeAllObjects];
                    CGFloat allMoney = 0;
                    for (NSDictionary *dictionary in valid) {
                        NSMutableDictionary *mutableDictionary = [dictionary mutableCopy];
                        NSMutableArray *array = [NSMutableArray array];
                        NSArray *list = [dictionary valueForKey:@"list"];
                        for (NSDictionary *itemDictionary in list) {
                            SWCartModel *model = [[SWCartModel alloc] initWithDic:itemDictionary];
                            allMoney += [model.price floatValue] * [model.cart_num intValue];
                            [array addObject:model];
                        }
                        [mutableDictionary setObject:array forKey:@"model"];
                        [self.dataArray addObject:mutableDictionary];
                    }
                    self.carBottomView.moneyLabel.text = [NSString stringWithFormat:@"¥%.2f", allMoney];
                    if ([invalid isKindOfClass:[NSArray class]] && [invalid count] > 0) {
                        [self.invalidArray removeAllObjects];
                        if (self.invalidView) {
                            [self.invalidView removeFromSuperview];
                            self.invalidView = nil;
                        }
                        for (NSDictionary *itemDictionary in invalid) {
                            SWCartModel *model = [[SWCartModel alloc] initWithDic:itemDictionary];
                            [self.invalidArray addObject:model];
                        }
                        [self addTableBottomView];
                    }
                    [self.carTableView reloadData];
                    [self reloadSelected];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view addSubview:self.recommendView];
                });
                if (self.carTableView) {
                    self.carTableView.hidden = YES;
                    self.carBottomView.hidden = YES;
                }
                if (self.recommendView) {
                    self.recommendView.hidden = NO;
                }
            }
        }
    } Fail:^{
    }];
}

- (void)addTableBottomView{
    if (self.invalidView) {
        [self.invalidView removeFromSuperview];
        self.invalidView = nil;
    }
    self.invalidView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, 40)];
    self.invalidView.backgroundColor = [UIColor whiteColor];

    UIButton *button = [UIButton buttonWithType:0];
    [button setImage:[UIImage imageNamed:@"down_gray"] forState:0];
    [button setImage:[UIImage imageNamed:@"up_gray"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@" 失效商品" forState:0];
    button.titleLabel.font = SYS_Font(12);
    [button setTitleColor:color32 forState:0];
    [self.invalidView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.invalidView).offset(15);
        make.centerY.equalTo(self.invalidView.mas_top).offset(20);
    }];

    UIButton *deleteButton = [UIButton buttonWithType:0];
    [deleteButton setImage:[UIImage imageNamed:@"profit_del"] forState:0];
    [deleteButton addTarget:self action:@selector(delBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setTitle:@" 清空" forState:0];
    deleteButton.titleLabel.font = SYS_Font(12);
    [deleteButton setTitleColor:color96 forState:0];
    [self.invalidView addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.invalidView).offset(-15);
        make.centerY.equalTo(button);
    }];
    self.carTableView.tableFooterView = self.invalidView;
}

- (UITableView *)invalidTableView{
    if (!_invalidTableView) {
        _invalidTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, _window_width, 100 * self.invalidArray.count) style:0];
        _invalidTableView.delegate = self;
        _invalidTableView.dataSource = self;
        _invalidTableView.separatorStyle = 0;
        _invalidTableView.scrollEnabled = NO;
    }
    return _invalidTableView;
}

- (void)bottomBtnClick:(UIButton *)sender{
    if (sender.selected) {
        [self.invalidTableView removeFromSuperview];
        self.invalidView.height = 40;
    } else {
        self.invalidView.height = 40 + self.invalidArray.count * 100;
        [self.invalidView addSubview:self.invalidTableView];
        [self.invalidTableView reloadData];
    }
    self.carTableView.tableFooterView = self.invalidView;
    sender.selected = !sender.selected;
}

- (void)delBtnClick:(UIButton *)btn{
    NSString *ids = @"";
    for (int i = 0; i < self.invalidArray.count; i++) {
        SWCartModel *model = self.invalidArray[i];
        if (i == 0) {
            ids = model.cart_id;
        } else {
            ids = [NSString stringWithFormat:@"%@,%@", ids, model.cart_id];
        }
    }
    [self delateCartGoodsForID:ids andIsValid:NO];
}

- (void)doAdminCartGoods{
    self.adminButton.selected = !self.adminButton.selected;
    self.carBottomView.adminView.hidden = !self.adminButton.selected;
}

- (SWCarBottomView *)carBottomView{
    if (!_carBottomView) {
        _carBottomView = [[[NSBundle mainBundle] loadNibNamed:@"SWCarBottomView" owner:nil options:nil] lastObject];
        _carBottomView.numsLabel.text = [NSString stringWithFormat:@"全选(%@)", self.cartCountLabel.text];
        _carBottomView.frame = CGRectMake(0, self.carTableView.bottom, _window_width, 60 + ShowDiff);
        WeakSelf;
        _carBottomView.block = ^(int type) {
            if (type == 0 || type == 1) {
                [weakSelf bottomAllBtnCLick:type];
            } else if (type == 4) {
                [weakSelf doCollectSelectedGoods];
            } else if (type == 2) {
                [weakSelf doBuy];
            } else if (type == 3) {
                [weakSelf bottomDelate];
            }
        };
    }
    return _carBottomView;
}

- (void)bottomAllBtnCLick:(BOOL)isSelected{
    CGFloat allMoney = 0;
    for (NSDictionary *dictionary in self.dataArray) {
        NSArray *list = [dictionary valueForKey:@"model"];
        for (SWCartModel *model in list) {
            model.isSelected = isSelected;
            if (model.isSelected) {
                allMoney += [model.price floatValue] * [model.cart_num intValue];
            }
        }
    }
    self.carBottomView.moneyLabel.text = [NSString stringWithFormat:@"¥%.2f", allMoney];
    self.carBottomView.allButton.selected = isSelected;
    [self.carTableView reloadData];
}

- (void)changeSelectedState:(BOOL)isSelected{
    if (!isSelected) {
        self.carBottomView.allButton.selected = NO;
    }
    [self reloadSelected];
}

- (void)headerBtnClick:(UIButton *)sender{
    NSArray *array = [self.dataArray[sender.tag - 1000] valueForKey:@"model"];
    for (SWCartModel *model in array) {
        model.isSelected = !sender.selected;
    }
    [self reloadSelected];
}

- (void)reloadSelected{
    CGFloat allMoney = 0;
    BOOL isAll = YES;
    for (NSDictionary *dictionary in self.dataArray) {
        NSArray *list = [dictionary valueForKey:@"model"];
        for (SWCartModel *model in list) {
            if (model.isSelected) {
                allMoney += [model.price floatValue] * [model.cart_num intValue];
            } else {
                isAll = NO;
            }
        }
    }
    self.carBottomView.moneyLabel.text = [NSString stringWithFormat:@"¥%.2f", allMoney];
    self.carBottomView.allButton.selected = isAll;
    [self.carTableView reloadData];
}

- (void)bottomDelate{
    NSString *ids = @"";
    for (NSDictionary *dictionary in self.dataArray) {
        NSArray *list = [dictionary valueForKey:@"model"];
        for (SWCartModel *model in list) {
            if (model.isSelected) {
                if (ids.length == 0) {
                    ids = model.cart_id;
                } else {
                    ids = [NSString stringWithFormat:@"%@,%@", ids, model.cart_id];
                }
            }
        }
    }
    [self delateCartGoodsForID:ids andIsValid:YES];
}

- (void)delateCartGoodsForID:(NSString *)ids andIsValid:(BOOL)isValid{
    [SWToolClass postNetworkWithUrl:@"cart/del" andParameter:@{@"ids": ids} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            if (isValid) {
                [self requestData];
                self.carBottomView.allButton.selected = YES;
            } else {
                [self.invalidArray removeAllObjects];
                [self.invalidView removeFromSuperview];
                self.invalidView = nil;
                self.carTableView.tableFooterView = nil;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:WYCarNumChange object:nil];
        }
    } fail:^{
    }];
}

- (void)doCollectSelectedGoods{
    NSMutableArray *selectedGoodsArray = [NSMutableArray array];
    for (NSDictionary *dictionary in self.dataArray) {
        NSArray *list = [dictionary valueForKey:@"model"];
        for (SWCartModel *model in list) {
            if (model.isSelected) {
                [selectedGoodsArray addObject:model.goods_id];
            }
        }
    }
    if (selectedGoodsArray.count == 0) {
        [MBProgressHUD showError:@"请选择要收藏的商品"];
        return;
    }
    [SWToolClass postNetworkWithUrl:@"collect/all" andParameter:@{@"id": selectedGoodsArray, @"category": @"product"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [MBProgressHUD showError:msg];
        }
    } fail:^{
    }];
}

- (void)doBuy{
    [MBProgressHUD showMessage:@""];
    NSString *ids = @"";
    for (NSDictionary *dictionary in self.dataArray) {
        NSArray *list = [dictionary valueForKey:@"model"];
        for (SWCartModel *model in list) {
            if (model.isSelected) {
                if (ids.length == 0) {
                    ids = model.cart_id;
                } else {
                    ids = [NSString stringWithFormat:@"%@,%@", ids, model.cart_id];
                }
            }
        }
    }
    [SWToolClass postNetworkWithUrl:@"order/confirm" andParameter:@{@"cartId": ids} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [MBProgressHUD hideHUD];
            SWSubmitOrderVC *vc = [[SWSubmitOrderVC alloc] init];
            vc.orderMessage = [info mutableCopy];
            vc.liveUid = @"";
            [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
        }
    } fail:^{
    }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
