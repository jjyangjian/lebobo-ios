//
//  SWGoodsSearchViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/20.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWGoodsSearchViewController.h"
#import "SWLiveGoodsCell.h"
#import "SWGoodsDetailsViewController.h"

@interface SWGoodsSearchViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSMutableArray *infoArray;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) NSArray *keyArray;
@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) UIImageView *nothingImgView;
@end

@implementation SWGoodsSearchViewController

- (void)addSearchView{
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight, _window_width, 46)];
    searchView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:searchView];

    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 8, _window_width - 75, 30)];
    self.searchTextField.font = SYS_Font(14);
    self.searchTextField.placeholder = @"搜索商品名称关键字";
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    self.searchTextField.layer.cornerRadius = 15;
    self.searchTextField.layer.masksToBounds = YES;
    self.searchTextField.backgroundColor = RGB_COLOR(@"#F5F5F5", 1);
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.delegate = self;
    [searchView addSubview:self.searchTextField];

    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 5, 20, 20)];
    imageView.image = [UIImage imageNamed:@"搜索"];
    [leftView addSubview:imageView];
    self.searchTextField.leftView = leftView;

    UIButton *searchButton = [UIButton buttonWithType:0];
    searchButton.frame = CGRectMake(self.searchTextField.right + 5, 8, 50, 30);
    [searchButton setTitle:@"搜索" forState:0];
    [searchButton setTitleColor:color32 forState:0];
    searchButton.titleLabel.font = SYS_Font(14);
    [searchButton addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    [searchView addSubview:searchButton];
}

- (void)doSearch{
    if (self.searchTextField.text.length == 0) {
        [MBProgressHUD showError:@"请输入关键词"];
        return;
    }
    self.searchString = self.searchTextField.text;
    self.page = 1;
    [self requestData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self doSearch];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"搜索商品";
    self.nothingImgV.image = [UIImage imageNamed:@"noSearch"];
    self.infoArray = [NSMutableArray array];
    self.page = 1;
    self.searchString = @"";
    [self addSearchView];
    [self.view addSubview:self.searchTableView];
    [self requestSearchKeyword];
}

- (void)requestSearchKeyword{
    [SWToolClass getQCloudWithUrl:@"search/keyword" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.keyArray = info;
            if (self.keyArray.count > 0) {
                [self creatTableHeader];
            }
        }
    } Fail:^{

    }];
}

- (void)creatTableHeader{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, 93.5)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, _window_width - 30, 18)];
    label.text = @"热门搜索";
    label.textColor = color96;
    label.font = SYS_Font(15);
    [view addSubview:label];
    CGFloat leftSpace = 15;
    CGFloat topSpace = label.bottom + 15;
    for (NSInteger i = 0; i < self.keyArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:0];
        [button setTitle:self.keyArray[i] forState:0];
        [button setTitleColor:color32 forState:0];
        button.titleLabel.font = SYS_Font(15);
        button.layer.cornerRadius = 2.5;
        button.layer.masksToBounds = YES;
        button.layer.borderColor = color96.CGColor;
        button.layer.borderWidth = 1;
        button.tag = 1000 + i;
        [button addTarget:self action:@selector(keyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat width = [[SWToolClass sharedInstance] widthOfString:self.keyArray[i] andFont:SYS_Font(15) andHeight:30] + 20;
        if (leftSpace + width > _window_width) {
            leftSpace = 15;
            topSpace += 40;
        }
        button.frame = CGRectMake(leftSpace, topSpace, width, 30);
        [view addSubview:button];
        leftSpace = leftSpace + width + 10;
        if (i == self.keyArray.count - 1) {
            view.height = button.bottom + 20;
        }
    }
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, view.height - 5, _window_width, 5) andColor:colorf0 andView:view];
    self.searchTableView.tableHeaderView = view;
    self.nothingImgView.y = view.height + 20;
}

- (void)keyBtnClick:(UIButton *)sender{
    self.searchString = sender.titleLabel.text;
    self.searchTextField.text = self.searchString;
    self.page = 1;
    [self requestData];
}

- (void)requestData{
    [self.searchTextField resignFirstResponder];
    NSString *url = [NSString stringWithFormat:@"products?keyword=%@", self.searchString];
    [SWToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.searchTableView.mj_header endRefreshing];
        [self.searchTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.infoArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                SWLiveGoodsModel *model = [[SWLiveGoodsModel alloc] initWithDic:dic];
                [self.infoArray addObject:model];
            }
            [self.searchTableView reloadData];
            if ([info count] < 20) {
                [self.searchTableView.mj_footer endRefreshingWithNoMoreData];
            }
            self.nothingImgView.hidden = ([self.infoArray count] != 0);
        }
    } Fail:^{
        [self.searchTableView.mj_header endRefreshing];
        [self.searchTableView.mj_footer endRefreshing];
    }];
}

- (UITableView *)searchTableView{
    if (!_searchTableView) {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight + 50, _window_width, _window_height - 64 - statusbarHeight - 50) style:0];
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.separatorStyle = 0;
        _searchTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.page = 1;
            [self requestData];
        }];
        _searchTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            self.page++;
            [self requestData];
        }];
        [_searchTableView addSubview:self.nothingImgView];
    }
    return _searchTableView;
}

- (UIImageView *)nothingImgView{
    if (!_nothingImgView) {
        _nothingImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, _window_width, _window_width * 0.5)];
        _nothingImgView.image = [UIImage imageNamed:@"noSearch"];
        _nothingImgView.contentMode = UIViewContentModeScaleAspectFit;
        _nothingImgView.hidden = YES;
    }
    return _nothingImgView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.infoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWLiveGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"liveGoodsCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWLiveGoodsCell" owner:nil options:nil] lastObject];
        cell.caozuoBtn.hidden = YES;
        cell.salesNumL.hidden = NO;
    }
    SWLiveGoodsModel *model = self.infoArray[indexPath.row];
    cell.model = model;
    cell.salesNumL.text = [NSString stringWithFormat:@"已售%@件", model.sales];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SWLiveGoodsModel *model = self.infoArray[indexPath.row];
    SWGoodsDetailsViewController *vc = [[SWGoodsDetailsViewController alloc] init];
    vc.goodsID = model.goodsID;
    vc.liveUid = @"";
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

@end
