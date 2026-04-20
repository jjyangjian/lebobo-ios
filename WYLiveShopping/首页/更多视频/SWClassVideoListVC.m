//
//  SWClassVideoListVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/3.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWClassVideoListVC.h"
#import "SWMineVideoCell.h"
#import "SWYBLookVideoVC.h"
@interface SWClassVideoListVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIView *noDataView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) NSInteger page;

@end

@implementation SWClassVideoListVC
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
        label.text = @"暂无视频";
        [_noDataView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noDataView);
            make.top.equalTo(imgV.mas_bottom).offset(20);
        }];
    }
    return _noDataView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    self.page = 1;
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake((_window_width-25)/2, (_window_width-25)/2 * 1.43);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 5;
    flow.sectionInset = UIEdgeInsetsMake(0, 10, 10, 10);
//    flow.headerReferenceSize = CGSizeMake(_window_width, 40);
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0, _window_width, _window_height-(64+statusbarHeight)) collectionViewLayout:flow];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SWMineVideoCell" bundle:nil] forCellWithReuseIdentifier:@"WYMineVideoCELL"];

    self.collectionView.delegate =self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = RGB_COLOR(@"#ffffff", 1);
    self.collectionView.mj_footer  = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        self.page ++;
        [self requestData];
    }];

    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        [self requestData];
    }];
    
    [self.view addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.height.equalTo(self.view);
    }];
    [_collectionView addSubview:self.noDataView];
//    self.collectionView.layer.mask = [[SWToolClass sharedInstance] setViewLeftTop:10 andRightTop:10 andView:self.collectionView];
    [self requestData];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(videoDelate:) name:@"videoDelete" object:nil];

}
- (void)videoDelate:(NSNotification *)not{
    NSDictionary *dic = [not object];
    for (NSDictionary *odic in self.dataArray) {
        if ([minstr([dic valueForKey:@"videoid"]) isEqual:minstr([odic valueForKey:@"id"])]) {
            [self.dataArray removeObject:odic];
            break;
        }
    }
    [_collectionView reloadData];
}
- (void)requestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"videolist&catid=%@&page=%ld",_classID,(long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];

        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            [self.dataArray addObjectsFromArray:info];
//            for (NSDictionary *dic in info) {
//                SWVideoModel *model = [[SWVideoModel alloc]initWithDic:dic];
//                [dataArray addObject:model];
//            }
            [_collectionView reloadData];
            if (self.dataArray.count == 0) {
                _noDataView.hidden = NO;
            }else{
                _noDataView.hidden = YES;
            }
        }
    } Fail:^{
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];

    }];
//    _collectionView.hidden = YES;
//    self.nothingView.hidden = NO;
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
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SWYBLookVideoVC *video = [[SWYBLookVideoVC alloc]init];
    
    video.fromWhere = @"myVideoV";
    video.pushPlayIndex = indexPath.row;
    video.videoList = self.dataArray;
    video.pages = self.page;
    video.sourceBaseUrl = [NSString stringWithFormat:@"videolist&catid=%@",_classID];
//    video.block = ^(NSMutableArray *array, NSInteger page,NSInteger index) {
//        page = page;
//        dataArray = array;
//        [self.collectionView reloadData];
//        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
//    };
    [[SWMXBADelegate sharedAppDelegate] pushViewController:video animated:YES];

}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SWMineVideoCell *cell = (SWMineVideoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WYMineVideoCELL" forIndexPath:indexPath];
    NSDictionary* dic = self.dataArray[indexPath.row];
    SWVideoModel *model = [[SWVideoModel alloc]initWithDic:dic];

    cell.model = model;
    return cell;
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
