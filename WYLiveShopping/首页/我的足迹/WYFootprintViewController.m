//
//  WYFootprintViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYFootprintViewController.h"
#import "footprintGoodsCell.h"
#import "GoodsDetailsViewController.h"
@implementation footprintHeader
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _nameL = [[UILabel alloc]initWithFrame:CGRectMake(8, 0, self.width-16, self.height)];
        _nameL.font = [UIFont boldSystemFontOfSize:12];
        _nameL.textColor = color32;
        [self addSubview:_nameL];
    }
    return self;
}
@end
@interface WYFootprintViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSMutableArray *dataArray;
    int page;
    NSString *lasttime;
}
@property (nonatomic,strong) UICollectionView *collectionView;

@end

@implementation WYFootprintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"我的足迹";
    self.nothingImgV.image = [UIImage imageNamed:@"no-footprint"];
    self.nothingImgV.frame = CGRectMake((_window_width-83)/2, 100, 83, 54);
    self.nothingTitleL.text = @"暂无浏览记录，";
    self.nothingTitleL.textColor = color96;
    self.nothingMsgL.text = @"赶快去挑选喜欢的东西吧～";
    lasttime = @"0";
    dataArray = [NSMutableArray array];
    page = 1;
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake((_window_width-30)/3, (_window_width-30)/3+35);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 5;
    flow.sectionInset = UIEdgeInsetsMake(0, 10, 10, 10);
    flow.headerReferenceSize = CGSizeMake(_window_width, 40);
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,64+statusbarHeight, _window_width, _window_height-(64+statusbarHeight)) collectionViewLayout:flow];
    [self.collectionView registerNib:[UINib nibWithNibName:@"footprintGoodsCell" bundle:nil] forCellWithReuseIdentifier:@"footprintGoodsCELL"];
    [self.collectionView registerClass:[footprintHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"footprintGoodsHeaderView"];

    self.collectionView.delegate =self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = RGB_COLOR(@"#FAFAFA", 1);
    self.collectionView.mj_footer  = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        [self requestData];
    }];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        lasttime = @"0";
        [self requestData];
    }];
    
    [self.view addSubview:self.collectionView];
    [self requestData];
}
- (void)requestData{
//    _collectionView.hidden = YES;
//    self.nothingView.hidden = NO;
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"productfoot&lasttime=%@",lasttime] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        if (code == 200) {
            if ([lasttime isEqual:@"0"]) {
                [dataArray removeAllObjects];
            }
            NSMutableArray *infoArray = [info mutableCopy];
            if (dataArray.count > 0 && infoArray.count > 0) {
                NSMutableDictionary *dataLastDic = [dataArray lastObject];
                NSDictionary *infoFirstDic = [infoArray firstObject];
                if ([minstr([dataLastDic valueForKey:@"day"]) isEqual:minstr([infoFirstDic valueForKey:@"day"])]) {
                    NSMutableArray *muArray = [dataLastDic valueForKey:@"list"];
                    [muArray addObjectsFromArray:[infoFirstDic valueForKey:@"list"]];
                    [dataLastDic setObject:muArray forKey:@"list"];
                    [infoArray removeObjectAtIndex:0];
                }
            }
            for (NSDictionary *dic in infoArray) {
                NSMutableDictionary *mudic = @{
                    @"day":minstr([dic valueForKey:@"day"]),
                    @"list":[[dic valueForKey:@"list"] mutableCopy]
                }.mutableCopy;
                [dataArray addObject:mudic];
            }

            NSDictionary *lastItem = [dataArray lastObject];
            lasttime = [[[lastItem valueForKey:@"list"] lastObject] valueForKey:@"addtime"];
            [_collectionView reloadData];
            if ([info count] == 0) {
                [_collectionView.mj_footer endRefreshingWithNoMoreData];
            }

            if (dataArray.count > 0) {
                self.nothingView.hidden = YES;
                _collectionView.hidden = NO;
            }else{
                _collectionView.hidden = YES;
                self.nothingView.hidden = NO;
            }
        }
    } Fail:^{
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
    }];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return dataArray.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray *array = [dataArray[section] valueForKey:@"list"];
    return array.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [dataArray[indexPath.section] valueForKey:@"list"][indexPath.row];
    GoodsDetailsViewController *vc = [[GoodsDetailsViewController alloc]init];
    vc.goodsID = minstr([dic valueForKey:@"id"]);
    vc.liveUid = @"";
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    footprintGoodsCell *cell = (footprintGoodsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"footprintGoodsCELL" forIndexPath:indexPath];
    [cell.thumbImgView sd_setImageWithURL:[NSURL URLWithString:[Config getavatar]]];
    NSDictionary *dic = [dataArray[indexPath.section] valueForKey:@"list"][indexPath.row];
    [cell.thumbImgView sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"image"])]];
    cell.priceL.text = [NSString stringWithFormat:@"¥%@",minstr([dic valueForKey:@"price"])];
    return cell;
}

#pragma mark ================ collectionview头视图 ===============

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {

        footprintHeader *header = (footprintHeader *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"footprintGoodsHeaderView" forIndexPath:indexPath];
        NSDictionary *dic = dataArray[indexPath.section];
        header.nameL.text = minstr([dic valueForKey:@"day"]);
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
