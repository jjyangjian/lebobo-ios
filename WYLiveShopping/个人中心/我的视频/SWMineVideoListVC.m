//
//  SWMineVideoListVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWMineVideoListVC.h"
#import "SWMineVideoCell.h"
#import "SWPublishViewVC.h"
#import "SWVideoExportTool.h"
#import "SWYBLookVideoVC.h"
@interface SWMineVideoListVC ()<TZImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *noDataView;

@end

@implementation SWMineVideoListVC
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

- (void)rightBtnClick{
    TZImagePickerController *imagePC = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    imagePC.allowCameraLocation = YES;
    imagePC.allowTakeVideo = YES;
    imagePC.allowPickingVideo = YES;
    imagePC.allowPickingImage = NO;
    imagePC.videoMaximumDuration = 60;
    imagePC.allowPickingOriginalPhoto = NO;
    [self presentViewController:imagePC animated:YES completion:nil];
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset{
    NSLog(@"--------- 视频编码 ----------- 开始 ----------");
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMessage:@"正在转码"];
        [SWVideoExportTool convertMovToMp4FromPHAsset:asset
                          andAVAssetExportPresetQuality:ExportPresetMediumQuality
                      andMovEncodeToMpegToolResultBlock:^(NSString *mp4File, NSData *mp4Data, NSError *error) {
            NSLog(@"--------- 视频编码 ----------- 结束 ----------\n{\n  %@,\n   %ld,\n  %@\n}",mp4File,mp4Data.length,error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                if (error) {
                    [MBProgressHUD showError:@"转码失败"];
                }else{
                    SWPublishViewVC *vc = [[SWPublishViewVC alloc]init];
                    vc.coverImage = coverImage;
                    vc.videoPath = mp4File;
                    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
                }
            });
        }];
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_productID) {
        self.titleL.text = @"商品推荐视频";
    }else{
        self.titleL.text = @"我的视频";
        self.rightBtn.hidden = NO;
        [self.rightBtn setTitle:@"发布" forState:0];
    }

    self.dataArray = [NSMutableArray array];
    self.page = 1;
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake((_window_width-25)/2, (_window_width-25)/2 * 1.43);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 5;
    flow.sectionInset = UIEdgeInsetsMake(0, 10, 10, 10);
    flow.headerReferenceSize = CGSizeMake(_window_width, 5);
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,64+statusbarHeight, _window_width, _window_height-(64+statusbarHeight)) collectionViewLayout:flow];
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
    [self.collectionView addSubview:self.noDataView];
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
    [self.collectionView reloadData];
}

- (void)requestData{
    NSString *url;
    if (_productID) {
        url = [NSString stringWithFormat:@"productvideo&productid=%@",_productID];
    }else{
        url = @"myvideo";
    }
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"%@&page=%ld",url,(long)self.page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];

        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
            }
            [self.dataArray addObjectsFromArray:info];
            [self.collectionView reloadData];
            self.noDataView.hidden = (self.dataArray.count != 0);
        }
    } Fail:^{
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];

    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
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
    NSString *url;
    if (_productID) {
        url = [NSString stringWithFormat:@"myvideo&productid=%@",_productID];
    }else{
        url = @"myvideo";
    }
    video.sourceBaseUrl = url;
    [[SWMXBADelegate sharedAppDelegate] pushViewController:video animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
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
