//
//  WYFindVideoViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYFindVideoViewController.h"
#import "WYFindVideoCell.h"
#import "WSLWaterFlowLayout.h"
#import "YBLookVideoVC.h"
@interface WYFindVideoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,WSLWaterFlowLayoutDelegate>{
    NSMutableArray *dataArray;//商品
    int page;

}
@property (nonatomic,strong) UICollectionView *videoCollectionView;

@end

@implementation WYFindVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor clearColor];

    dataArray = [NSMutableArray array];
    page = 1;
    [self.view addSubview:self.videoCollectionView];
    [self requestData];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(videoDelate:) name:@"videoDelete" object:nil];

}
- (void)videoDelate:(NSNotification *)not{
    NSDictionary *dic = [not object];
    for (NSDictionary *odic in dataArray) {
        if ([minstr([dic valueForKey:@"videoid"]) isEqual:minstr([odic valueForKey:@"id"])]) {
            [dataArray removeObject:odic];
            break;
        }
    }
    [_videoCollectionView reloadData];
}
- (UICollectionView *)videoCollectionView{
    if (!_videoCollectionView) {
//        WYWaterFallLayout * waterFallLayout = [[WYWaterFallLayout alloc]init];
//        waterFallLayout.delegate = self;
        WSLWaterFlowLayout *_flow = [[WSLWaterFlowLayout alloc] init];
        _flow.delegate = self;
        _flow.flowLayoutStyle = 0;

        _videoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 0, _window_width-20, _window_height- (79+statusbarHeight + ShowDiff+48)) collectionViewLayout:_flow];
        [_videoCollectionView registerNib:[UINib nibWithNibName:@"WYFindVideoCell" bundle:nil] forCellWithReuseIdentifier:@"WYFindVideoCELL"];
        _videoCollectionView.layer.cornerRadius = 10;
        _videoCollectionView.layer.masksToBounds = YES;
        _videoCollectionView.delegate =self;
        _videoCollectionView.dataSource = self;
        _videoCollectionView.backgroundColor = [UIColor whiteColor];
        _videoCollectionView.mj_footer  = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            page ++;
            [self requestData];
        }];
        
        _videoCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            page = 1;
            [self requestData];
        }];
        
    }
    return _videoCollectionView;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return dataArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    YBLookVideoVC *video = [[YBLookVideoVC alloc]init];
    
    video.fromWhere = @"myVideoV";
    video.pushPlayIndex = indexPath.row;
    video.videoList = dataArray;
    video.pages = page;
    video.sourceBaseUrl = [NSString stringWithFormat:@"videolist&catid=%@",@"0"];
//    video.block = ^(NSMutableArray *array, NSInteger page,NSInteger index) {
//        page = page;
//        dataArray = array;
//        [self.collectionView reloadData];
//        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
//    };
    [[MXBADelegate sharedAppDelegate] pushViewController:video animated:YES];

}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WYFindVideoCell *cell = (WYFindVideoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WYFindVideoCELL" forIndexPath:indexPath];
    NSDictionary* dic = dataArray[indexPath.row];
    WYVideoModel *model = [[WYVideoModel alloc]initWithDic:dic];
    cell.model = model;
    return cell;
}

- (CGSize)waterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary* dic = dataArray[indexPath.row];
    WYVideoModel *model = [[WYVideoModel alloc]initWithDic:dic];
    return CGSizeMake((_window_width-50)/2, (_window_width-50)/2 + (model.goods.count > 0 ? 55 : 0));

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
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"videolist&catid=0&page=%d",page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_videoCollectionView.mj_header endRefreshing];
        [_videoCollectionView.mj_footer endRefreshing];

        if (code == 200) {
            if (page == 1) {
                [dataArray removeAllObjects];
            }
            [dataArray addObjectsFromArray:info];
//            for (NSDictionary *dic in info) {
//                WYVideoModel *model = [[WYVideoModel alloc]initWithDic:dic];
//                [dataArray addObject:model];
//            }
            [_videoCollectionView reloadData];
//            if (dataArray.count == 0) {
//                _noDataView.hidden = NO;
//            }else{
//                _noDataView.hidden = YES;
//            }
        }
    } Fail:^{
        [_videoCollectionView.mj_header endRefreshing];
        [_videoCollectionView.mj_footer endRefreshing];

    }];

//    NSString *str = @"https://img0.baidu.com/it/u=1214085102,3715214476&fm=11&fmt=auto&gp=0.jpg";
//
//    NSDictionary *dic = @{@"thumb":str,@"goods":@[@"",@""]};
//    NSDictionary *dic1 = @{@"thumb":str,@"goods":@[]};
//    FindVideoModel *model = [[FindVideoModel alloc]initWithDic:dic];
//    FindVideoModel *model2 = [[FindVideoModel alloc]initWithDic:dic1];
//    [dataArray addObject:model];
//    [dataArray addObject:model2];
//    [dataArray addObject:model];
//    [dataArray addObject:model2];
//    [dataArray addObject:model];
//    [dataArray addObject:model2];
//    [dataArray addObject:model];
//    [dataArray addObject:model2];
//    [dataArray addObject:model];
//    [dataArray addObject:model2];
//    [dataArray addObject:model];
//    [dataArray addObject:model2];
//
//    [_videoCollectionView reloadData];
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
