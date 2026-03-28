//
//  SWStoreClassViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWStoreClassViewController.h"
#import "SWFootprintVC.h"
#import "SWStoreClassColtCell.h"
#import "SWStoreSearchViewController.h"

@interface SWStoreClassViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *searchBtn;
@end

@implementation SWStoreClassViewController

- (void)doReturn {
    if (self.block) {
        self.block();
    }
}

- (void)doSearch {
    SWStoreSearchViewController *vc = [[SWStoreSearchViewController alloc] init];
    vc.mer_id = self.mer_id;
    vc.cid = @"";
    vc.sid = @"";
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.returnBtn.selected = YES;
    self.naviView.backgroundColor = RGB_COLOR(@"#0A0F1B", 1);
    self.lineView.hidden = YES;

    self.searchBtn = [UIButton buttonWithType:0];
    [self.searchBtn setImage:[UIImage imageNamed:@"home_search"] forState:0];
    [self.searchBtn setTitle:@" 搜索店铺内商品" forState:0];
    [self.searchBtn setTitleColor:RGB_COLOR(@"#b4b4b4", 1) forState:0];
    self.searchBtn.titleLabel.font = SYS_Font(14);
    [self.searchBtn setBackgroundColor:RGB_COLOR(@"#FAFAFA", 0.1)];
    self.searchBtn.layer.cornerRadius = 15;
    self.searchBtn.layer.masksToBounds = YES;
    [self.searchBtn addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    self.searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.naviView addSubview:self.searchBtn];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.returnBtn.mas_right).offset(5);
        make.right.equalTo(self.naviView).offset(-15);
        make.centerY.equalTo(self.returnBtn);
        make.height.mas_equalTo(30);
    }];
    [self creatUI];
}

- (void)creatUI {
    UIView *storeView = [[UIView alloc] initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, 91)];
    storeView.backgroundColor = RGB_COLOR(@"#0A0F1B", 1);
    [self.view addSubview:storeView];

    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(15, 75 + statusbarHeight, _window_width - 30, _window_height - (75 + statusbarHeight + ShowDiff + 48))];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.clipsToBounds = YES;
    [self.view addSubview:contentView];
    contentView.layer.mask = [[SWToolClass sharedInstance] setViewLeftTop:10 andRightTop:10 andView:contentView];

    self.dataArray = [NSMutableArray array];
    self.page = 1;

    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake((_window_width - 55) / 2, 38);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 5;
    flow.sectionInset = UIEdgeInsetsMake(0, 10, 10, 10);
    flow.headerReferenceSize = CGSizeMake(_window_width, 40);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _window_width - 30, _window_height - (75 + statusbarHeight + ShowDiff + 48)) collectionViewLayout:flow];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SWStoreClassColtCell" bundle:nil] forCellWithReuseIdentifier:@"WYStoreClassColtCELL"];
    [self.collectionView registerClass:[SWFootprintHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"StoreClassHeaderView"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = RGB_COLOR(@"#FAFAFA", 1);

    [contentView addSubview:self.collectionView];
    [self requestData];
}

- (void)requestData {
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"category&mer_id=%@", self.mer_id] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        self.dataArray = [info mutableCopy];
        [self.collectionView reloadData];
    } Fail:^{
    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *array = [self.dataArray[section] valueForKey:@"children"];
    return array.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSDictionary *firstLevelDictionary = self.dataArray[indexPath.section];
    NSDictionary *secondLevelDictionary = [firstLevelDictionary valueForKey:@"children"][indexPath.row];
    SWStoreSearchViewController *vc = [[SWStoreSearchViewController alloc] init];
    vc.cid = minstr([firstLevelDictionary valueForKey:@"id"]);
    vc.sid = minstr([secondLevelDictionary valueForKey:@"id"]);
    vc.className = minstr([secondLevelDictionary valueForKey:@"cate_name"]);
    vc.mer_id = self.mer_id;
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SWStoreClassColtCell *cell = (SWStoreClassColtCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WYStoreClassColtCELL" forIndexPath:indexPath];
    NSDictionary *dictionary = [self.dataArray[indexPath.section] valueForKey:@"children"][indexPath.row];
    cell.nameL.text = minstr([dictionary valueForKey:@"cate_name"]);
    return cell;
}

#pragma mark - collectionview头视图

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SWFootprintHeader *header = (SWFootprintHeader *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"StoreClassHeaderView" forIndexPath:indexPath];
        NSDictionary *dictionary = self.dataArray[indexPath.section];
        header.nameL.text = minstr([dictionary valueForKey:@"cate_name"]);
        return header;
    }
    return nil;
}

@end
