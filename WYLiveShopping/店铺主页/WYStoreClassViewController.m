//
//  WYStoreClassViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYStoreClassViewController.h"
#import "WYFootprintViewController.h"
#import "WYStoreClassColtCell.h"
#import "WYStoreSearchViewController.h"
@interface WYStoreClassViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSMutableArray *dataArray;
    int page;
}
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIButton *searchBtn;

@end

@implementation WYStoreClassViewController
-(void)doReturn{
    if (self.block) {
        self.block();
    }
}
- (void)doSearch{
    WYStoreSearchViewController *vc = [[WYStoreSearchViewController alloc]init];
    vc.mer_id = _mer_id;
    vc.cid = @"";
    vc.sid = @"";
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.returnBtn.selected = YES;
    self.naviView.backgroundColor = RGB_COLOR(@"#0A0F1B", 1);
    self.lineView.hidden = YES;
    _searchBtn = [UIButton buttonWithType:0];
    [_searchBtn setImage:[UIImage imageNamed:@"home_search"] forState:0];
    [_searchBtn setTitle:@" 搜索店铺内商品" forState:0];
    [_searchBtn setTitleColor:RGB_COLOR(@"#b4b4b4", 1) forState:0];
    _searchBtn.titleLabel.font = SYS_Font(14);
    [_searchBtn setBackgroundColor:RGB_COLOR(@"#FAFAFA", 0.1)];
    _searchBtn.layer.cornerRadius = 15;
    _searchBtn.layer.masksToBounds = YES;
    [_searchBtn addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    _searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.naviView addSubview:_searchBtn];
    [_searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.returnBtn.mas_right).offset(5);
        make.right.equalTo(self.naviView).offset(-15);
        make.centerY.equalTo(self.returnBtn);
        make.height.mas_equalTo(30);
    }];
    [self creatUI];

}
- (void)creatUI{
    UIView *storeView = [[UIView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, 91)];
    storeView.backgroundColor = RGB_COLOR(@"#0A0F1B", 1);
    [self.view addSubview:storeView];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(15,75+statusbarHeight, _window_width-30, _window_height-(75+statusbarHeight+ShowDiff+48))];
    view.backgroundColor = [UIColor whiteColor];
    view.clipsToBounds = YES;
    [self.view addSubview:view];
    view.layer.mask = [[WYToolClass sharedInstance] setViewLeftTop:10 andRightTop:10 andView:view];

    dataArray = [NSMutableArray array];
    page = 1;
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake((_window_width-55)/2, 38);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 5;
    flow.sectionInset = UIEdgeInsetsMake(0, 10, 10, 10);
    flow.headerReferenceSize = CGSizeMake(_window_width, 40);
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0, _window_width-30, _window_height-(75+statusbarHeight+ShowDiff+48)) collectionViewLayout:flow];
    [self.collectionView registerNib:[UINib nibWithNibName:@"WYStoreClassColtCell" bundle:nil] forCellWithReuseIdentifier:@"WYStoreClassColtCELL"];
    [self.collectionView registerClass:[footprintHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"StoreClassHeaderView"];

    self.collectionView.delegate =self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = RGB_COLOR(@"#FAFAFA", 1);
//    self.collectionView.mj_footer  = [MJRefreshBackFooter footerWithRefreshingBlock:^{
//    }];
//    
//    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//    }];
    
    [view addSubview:self.collectionView];
    [self requestData];

}

- (void)requestData{
//    _collectionView.hidden = YES;
//    self.nothingView.hidden = NO;
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"category&mer_id=%@",_mer_id] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        dataArray = info;
        [_collectionView reloadData];
    } Fail:^{
        
    }];

//    NSDictionary *dic = @{
//        @"name":@"2021-08-21",
//        @"list":@[@"",@"",@"",@"",@""]
//    };
//    NSDictionary *dic1 = @{
//        @"name":@"2021-08-20",
//        @"list":@[@""]
//    };
//    NSDictionary *dic2 = @{
//        @"name":@"2021-08-19",
//        @"list":@[@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@""]
//    };
//    [dataArray addObject:dic];
//    [dataArray addObject:dic1];
//    [dataArray addObject:dic2];
//    [_collectionView reloadData];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return dataArray.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray *array = [dataArray[section] valueForKey:@"children"];
    return array.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSDictionary *oneDic = dataArray[indexPath.section];
    NSDictionary *twoDic = [oneDic valueForKey:@"children"][indexPath.row];
    WYStoreSearchViewController *vc = [[WYStoreSearchViewController alloc]init];
    vc.cid = minstr([oneDic valueForKey:@"id"]);
    vc.sid = minstr([twoDic valueForKey:@"id"]);
    vc.className = minstr([twoDic valueForKey:@"cate_name"]);
    vc.mer_id = _mer_id;
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WYStoreClassColtCell *cell = (WYStoreClassColtCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WYStoreClassColtCELL" forIndexPath:indexPath];
    NSDictionary *dic = [dataArray[indexPath.section] valueForKey:@"children"][indexPath.row];
    cell.nameL.text = minstr([dic valueForKey:@"cate_name"]);
    return cell;
}

#pragma mark ================ collectionview头视图 ===============

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {

        footprintHeader *header = (footprintHeader *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"StoreClassHeaderView" forIndexPath:indexPath];
        NSDictionary *dic = dataArray[indexPath.section];
        header.nameL.text = minstr([dic valueForKey:@"cate_name"]);
        return header;
    }else{
        return nil;
    }
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
