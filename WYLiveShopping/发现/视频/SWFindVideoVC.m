//
//  SWFindVideoVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWFindVideoVC.h"
#import "SWFindVideoCell.h"
#import "SWWSLWaterFlowLayout.h"
#import "SWYBLookVideoVC.h"
@interface SWFindVideoVC ()<UICollectionViewDelegate,UICollectionViewDataSource,WSLWaterFlowLayoutDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) UICollectionView *videoCollectionView;

@end

@implementation SWFindVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor clearColor];

    self.dataArray = [NSMutableArray array];
    self.page = 1;
    [self.view addSubview:self.videoCollectionView];
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
    [self.videoCollectionView reloadData];
}

- (UICollectionView *)videoCollectionView{
    if (!_videoCollectionView) {
        SWWSLWaterFlowLayout *flow = [[SWWSLWaterFlowLayout alloc] init];
        flow.delegate = self;
        flow.flowLayoutStyle = 0;

        _videoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 0, _window_width-20, _window_height- (79+statusbarHeight + ShowDiff+48)) collectionViewLayout:flow];
        [_videoCollectionView registerNib:[UINib nibWithNibName:@"SWFindVideoCell" bundle:nil] forCellWithReuseIdentifier:@"WYFindVideoCELL"];
        _videoCollectionView.layer.cornerRadius = 10;
        _videoCollectionView.layer.masksToBounds = YES;
        _videoCollectionView.delegate =self;
        _videoCollectionView.dataSource = self;
        _videoCollectionView.backgroundColor = [UIColor whiteColor];
        _videoCollectionView.mj_footer  = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            self.page ++;
            [self requestData];
        }];

        _videoCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.page = 1;
            [self requestData];
        }];
    }
    return _videoCollectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SWYBLookVideoVC *video = [[SWYBLookVideoVC alloc]init];

    video.fromWhere = @"myVideoV";
    video.pushPlayIndex = indexPath.row;
    video.videoList = self.dataArray;
    video.pages = self.page;
    video.sourceBaseUrl = [NSString stringWithFormat:@"videolist&catid=%@",@"0"];
    [[SWMXBADelegate sharedAppDelegate] pushViewController:video animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SWFindVideoCell *cell = (SWFindVideoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WYFindVideoCELL" forIndexPath:indexPath];
    NSDictionary* dic = self.dataArray[indexPath.row];
    SWVideoModel *model = [[SWVideoModel alloc]initWithDic:dic];
    cell.model = model;
    return cell;
}

- (CGSize)waterFlowLayout:(SWWSLWaterFlowLayout *)waterFlowLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary* dic = self.dataArray[indexPath.row];
    SWVideoModel *model = [[SWVideoModel alloc]initWithDic:dic];
    return CGSizeMake((_window_width-50)/2, (_window_width-50)/2 + (model.goods.count > 0 ? 55 : 0));
}

- (CGFloat)columnCountInWaterFlowLayout:(SWWSLWaterFlowLayout *)waterFlowLayout{
    return 2;
}

- (CGFloat)columnMarginInWaterFlowLayout:(SWWSLWaterFlowLayout *)waterFlowLayout{
    return 10;
}

- (UIEdgeInsets)edgeInsetInWaterFlowLayout:(SWWSLWaterFlowLayout *)waterFlowLayout{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)requestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"videolist&catid=0&page=%ld",(long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.videoCollectionView.mj_header endRefreshing];
        [self.videoCollectionView.mj_footer endRefreshing];

        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            [self.dataArray addObjectsFromArray:info];
            [self.videoCollectionView reloadData];
        }
    } Fail:^{
        [self.videoCollectionView.mj_header endRefreshing];
        [self.videoCollectionView.mj_footer endRefreshing];

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
