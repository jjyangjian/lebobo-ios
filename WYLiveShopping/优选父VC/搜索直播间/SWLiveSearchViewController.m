//
//  SWLiveSearchViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/20.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWLiveSearchViewController.h"
#import "SWHomeLiveCell.h"
#import "SWLivePlayerViewController.h"

@interface SWLiveSearchViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *infoArray;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UICollectionView *classCollectionView;
@property (nonatomic, strong) UIImageView *nothingImgView;
@end

@implementation SWLiveSearchViewController
- (void)addSearchView{
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight, _window_width, 46)];
    searchView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:searchView];

    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 8, _window_width - 75, 30)];
    self.searchTextField.font = SYS_Font(14);
    self.searchTextField.placeholder = @"搜索直播间ID或房间名称";
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
    self.page = 1;
    [self requestData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self doSearch];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"搜索直播间";
    self.infoArray = [NSMutableArray array];
    self.page = 1;
    [self addSearchView];
    [self.view addSubview:self.classCollectionView];
}

- (UICollectionView *)classCollectionView{
    if (!_classCollectionView) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        flow.scrollDirection = UICollectionViewScrollDirectionVertical;
        flow.itemSize = CGSizeMake((_window_width - 25) / 2, (_window_width - 25) / 2 * 1.2 + 70);
        flow.minimumLineSpacing = 5;
        flow.minimumInteritemSpacing = 5;
        flow.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
        _classCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight + 50, _window_width, _window_height - 64 - statusbarHeight - 50) collectionViewLayout:flow];
        [_classCollectionView registerNib:[UINib nibWithNibName:@"SWHomeLiveCell" bundle:nil] forCellWithReuseIdentifier:@"HomeLiveCELL"];
        _classCollectionView.delegate = self;
        _classCollectionView.dataSource = self;
        _classCollectionView.backgroundColor = RGB_COLOR(@"#ffffff", 1);
        _classCollectionView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            self.page++;
            [self requestData];
        }];
        _classCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.page = 1;
            [self requestData];
        }];
        if (@available(iOS 11.0, *)) {
            _classCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        [_classCollectionView addSubview:self.nothingImgView];
    }
    return _classCollectionView;
}

- (UIImageView *)nothingImgView{
    if (!_nothingImgView) {
        _nothingImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, _window_width, _window_width * 0.6)];
        _nothingImgView.image = [UIImage imageNamed:@"noSearch"];
        _nothingImgView.contentMode = UIViewContentModeScaleAspectFit;
        _nothingImgView.hidden = YES;
    }
    return _nothingImgView;
}

- (void)requestData{
    [self.searchTextField resignFirstResponder];
    NSString *url = [NSString stringWithFormat:@"livesearch?keyword=%@", self.searchTextField.text];
    [SWToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.classCollectionView.mj_header endRefreshing];
        [self.classCollectionView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.infoArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                SWHomeLiveModel *model = [[SWHomeLiveModel alloc] initWithDic:dic];
                [self.infoArray addObject:model];
            }
            [self.classCollectionView reloadData];
            if ([info count] < 20) {
                [self.classCollectionView.mj_footer endRefreshingWithNoMoreData];
            }
            self.nothingImgView.hidden = ([self.infoArray count] != 0);
        }
    } Fail:^{
        [self.classCollectionView.mj_header endRefreshing];
        [self.classCollectionView.mj_footer endRefreshing];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.infoArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SWHomeLiveModel *model = self.infoArray[indexPath.row];
    [MBProgressHUD showMessage:@""];
    [self checkLive:model];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SWHomeLiveCell *cell = (SWHomeLiveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeLiveCELL" forIndexPath:indexPath];
    cell.model = self.infoArray[indexPath.row];
    return cell;
}

- (void)checkLive:(SWHomeLiveModel *)model{
    [SWToolClass postNetworkWithUrl:@"live/check" andParameter:@{@"stream": model.stream} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [MBProgressHUD hideHUD];
            SWLivePlayerViewController *player = [[SWLivePlayerViewController alloc] init];
            player.roomMap = [model.originDic mutableCopy];
            [[SWMXBADelegate sharedAppDelegate] pushViewController:player animated:YES];
        }
    } fail:^{

    }];
}

@end
