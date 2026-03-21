//
//  WYMineVideoListViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYMineVideoListViewController.h"
#import "WYMineVideoCell.h"
#import "WYPublishViewViewController.h"
#import "WYVideoExportTool.h"
#import "YBLookVideoVC.h"
@interface WYMineVideoListViewController ()<TZImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSMutableArray *dataArray;
    int page;
}
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIView *noDataView;

@end

@implementation WYMineVideoListViewController
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
//    imagePC.allowCrop = YES;
    imagePC.allowPickingOriginalPhoto = NO;
    [self presentViewController:imagePC animated:YES completion:nil];
//    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:@"选择上传方式" preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//    }];
//    [alertContro addAction:action1];
//    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    [alertContro addAction:action2];
//    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    [alertContro addAction:cancleAction];
//
//    [self presentViewController:alertContro animated:YES completion:nil];

}
-(void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 选择视频的回调
-(void)imagePickerController:(TZImagePickerController *)picker
       didFinishPickingVideo:(UIImage *)coverImage
                sourceAssets:(PHAsset *)asset{
    NSLog(@"--------- 视频编码 ----------- 开始 ----------");
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMessage:@"正在转码"];
        [WYVideoExportTool convertMovToMp4FromPHAsset:asset
                          andAVAssetExportPresetQuality:ExportPresetMediumQuality
                      andMovEncodeToMpegToolResultBlock:^(NSString *mp4File, NSData *mp4Data, NSError *error) {
            NSLog(@"--------- 视频编码 ----------- 结束 ----------\n{\n  %@,\n   %ld,\n  %@\n}",mp4File,mp4Data.length,error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                if (error) {
                    [MBProgressHUD showError:@"转码失败"];
                }else{
                    WYPublishViewViewController *vc = [[WYPublishViewViewController alloc]init];
                    vc.coverImage = coverImage;
                    vc.videoPath = mp4File;
                    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

                }

            });
        }];

    });

//    if (coverImage && outputPath.length > 0) {
//        TCVideoPublishController *vc = [[TCVideoPublishController alloc]init];
//        vc.coverImage = coverImage;
//        vc.videoPath = outputPath;
//        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
//    }
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

    dataArray = [NSMutableArray array];
    page = 1;
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake((_window_width-25)/2, (_window_width-25)/2 * 1.43);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 5;
    flow.sectionInset = UIEdgeInsetsMake(0, 10, 10, 10);
    flow.headerReferenceSize = CGSizeMake(_window_width, 5);
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,64+statusbarHeight, _window_width, _window_height-(64+statusbarHeight)) collectionViewLayout:flow];
    [self.collectionView registerNib:[UINib nibWithNibName:@"WYMineVideoCell" bundle:nil] forCellWithReuseIdentifier:@"WYMineVideoCELL"];

    self.collectionView.delegate =self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = RGB_COLOR(@"#ffffff", 1);
    self.collectionView.mj_footer  = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        page ++;
        [self requestData];
    }];

    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        [self requestData];
    }];
    
    [self.view addSubview:self.collectionView];
    [_collectionView addSubview:self.noDataView];
//    self.collectionView.layer.mask = [[WYToolClass sharedInstance] setViewLeftTop:10 andRightTop:10 andView:self.collectionView];
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
    [_collectionView reloadData];
}
- (void)requestData{
//    _collectionView.hidden = YES;
//    self.nothingView.hidden = NO;
    NSString *url;
    if (_productID) {
        url = [NSString stringWithFormat:@"productvideo&productid=%@",_productID];
    }else{
        url = @"myvideo";
    }
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"%@&page=%d",url,page] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];

        if (code == 200) {
            if (page == 1) {
                [dataArray removeAllObjects];
            }
            [dataArray addObjectsFromArray:info];
//            for (NSDictionary *dic in info) {
//                WYVideoModel *model = [[WYVideoModel alloc]initWithDic:dic];
//                [dataArray addObject:model];
//            }
            [_collectionView reloadData];
            if (dataArray.count == 0) {
                _noDataView.hidden = NO;
            }else{
                _noDataView.hidden = YES;
            }
        }
    } Fail:^{
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];

    }];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
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
    NSString *url;
    if (_productID) {
        url = [NSString stringWithFormat:@"myvideo&productid=%@",_productID];
    }else{
        url = @"myvideo";
    }
    video.sourceBaseUrl = url;
//    video.block = ^(NSMutableArray *array, NSInteger page,NSInteger index) {
//        page = page;
//        dataArray = array;
//        [self.collectionView reloadData];
//        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
//    };
    [[MXBADelegate sharedAppDelegate] pushViewController:video animated:YES];

}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WYMineVideoCell *cell = (WYMineVideoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WYMineVideoCELL" forIndexPath:indexPath];
    NSDictionary* dic = dataArray[indexPath.row];
    WYVideoModel *model = [[WYVideoModel alloc]initWithDic:dic];

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
