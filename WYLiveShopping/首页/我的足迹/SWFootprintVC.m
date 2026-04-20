//
//  SWFootprintVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWFootprintVC.h"
#import "SWFootprintGoodsCell.h"
#import "SWGoodsDetailsViewController.h"
@implementation SWFootprintHeader
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
@interface SWFootprintVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,copy) NSString *lastTime;

@end

@implementation SWFootprintVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"我的足迹";
    self.nothingImgV.image = [UIImage imageNamed:@"no-footprint"];
    self.nothingImgV.frame = CGRectMake((_window_width-83)/2, 100, 83, 54);
    self.nothingTitleL.text = @"暂无浏览记录，";
    self.nothingTitleL.textColor = color96;
    self.nothingMsgL.text = @"赶快去挑选喜欢的东西吧～";
    self.lastTime = @"0";
    self.dataArray = [NSMutableArray array];
    self.page = 1;
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake((_window_width-30)/3, (_window_width-30)/3+35);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 5;
    flow.sectionInset = UIEdgeInsetsMake(0, 10, 10, 10);
    flow.headerReferenceSize = CGSizeMake(_window_width, 40);
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,64+statusbarHeight, _window_width, _window_height-(64+statusbarHeight)) collectionViewLayout:flow];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SWFootprintGoodsCell" bundle:nil] forCellWithReuseIdentifier:@"footprintGoodsCELL"];
    [self.collectionView registerClass:[SWFootprintHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"footprintGoodsHeaderView"];

    self.collectionView.delegate =self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = RGB_COLOR(@"#FAFAFA", 1);
    self.collectionView.mj_footer  = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        [self requestData];
    }];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.lastTime = @"0";
        [self requestData];
    }];
    
    [self.view addSubview:self.collectionView];
    [self requestData];
}
- (void)requestData{
//    _collectionView.hidden = YES;
//    self.nothingView.hidden = NO;
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"productfoot&lasttime=%@",self.lastTime] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
        if (code == 200) {
            if ([self.lastTime isEqual:@"0"]) {
                [self.dataArray removeAllObjects];
            }
            NSMutableArray *infoArray = [info mutableCopy];
            if (self.dataArray.count > 0 && infoArray.count > 0) {
                NSMutableDictionary *dataLastDic = [self.dataArray lastObject];
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
                [self.dataArray addObject:mudic];
            }

            NSDictionary *lastItem = [self.dataArray lastObject];
            self.lastTime = [[[lastItem valueForKey:@"list"] lastObject] valueForKey:@"addtime"];
            [self.collectionView reloadData];
            if ([info count] == 0) {
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }

            if (self.dataArray.count > 0) {
                self.nothingView.hidden = YES;
                self.collectionView.hidden = NO;
            }else{
                self.collectionView.hidden = YES;
                self.nothingView.hidden = NO;
            }
        }
    } Fail:^{
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
    }];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.dataArray.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray *array = [self.dataArray[section] valueForKey:@"list"];
    return array.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [self.dataArray[indexPath.section] valueForKey:@"list"][indexPath.row];
    SWGoodsDetailsViewController *vc = [[SWGoodsDetailsViewController alloc]init];
    vc.goodsID = minstr([dic valueForKey:@"id"]);
    vc.liveUid = @"";
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SWFootprintGoodsCell *cell = (SWFootprintGoodsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"footprintGoodsCELL" forIndexPath:indexPath];
    [cell.thumbImgView sd_setImageWithURL:[NSURL URLWithString:[SWConfig getavatar]]];
    NSDictionary *dic = [self.dataArray[indexPath.section] valueForKey:@"list"][indexPath.row];
    [cell.thumbImgView sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"image"])]];
    cell.priceL.text = [NSString stringWithFormat:@"¥%@",minstr([dic valueForKey:@"price"])];
    return cell;
}

#pragma mark ================ collectionview头视图 ===============

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {

        SWFootprintHeader *header = (SWFootprintHeader *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"footprintGoodsHeaderView" forIndexPath:indexPath];
        NSDictionary *dic = self.dataArray[indexPath.section];
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
