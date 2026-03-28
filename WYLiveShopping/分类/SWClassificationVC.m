//
//  SWClassificationVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/15.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWClassificationVC.h"
#import "SWClassGoodsCell.h"
#import "SWClassGoodsTableCell.h"
#import "SWClassGoodsVC.h"

@interface SWClassHeaderView : UICollectionReusableView
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation SWClassHeaderView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)addShowView {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:14];
    _titleLabel.textColor = color32;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(80);
    }];

    UIView *leftLine = [[UIView alloc] init];
    leftLine.backgroundColor = color32;
    [self addSubview:leftLine];
    [leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.height.mas_equalTo(1);
        make.right.equalTo(_titleLabel.mas_left);
        make.width.equalTo(self).multipliedBy(0.25);
    }];

    UIView *rightLine = [[UIView alloc] init];
    rightLine.backgroundColor = color32;
    [self addSubview:rightLine];
    [rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.height.mas_equalTo(1);
        make.left.equalTo(_titleLabel.mas_right);
        make.width.equalTo(self).multipliedBy(0.25);
    }];
}

@end

@interface SWClassificationVC ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate>
@property (nonatomic, strong) UITableView *classTableView;
@property (nonatomic, strong) UICollectionView *classCollectionView;
@property (nonatomic, strong) NSArray *classArray;
@property (nonatomic, assign) NSInteger selectTableIndex;
@property (nonatomic, assign) BOOL isClickLeft;
@property (nonatomic, strong) UITextField *searchTextField;

@end

@implementation SWClassificationVC

- (void)addSearchView {
    UIView *navi = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight, _window_width, 50)];
    navi.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navi];

    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, _window_width - 65, 30)];
    self.searchTextField.font = SYS_Font(14);
    self.searchTextField.placeholder = @"搜索商品";
    self.searchTextField.delegate = self;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    self.searchTextField.layer.cornerRadius = 15;
    self.searchTextField.layer.masksToBounds = YES;
    self.searchTextField.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    [navi addSubview:self.searchTextField];
    [self.searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(navi).offset(15);
        make.right.equalTo(navi).offset(-15);
        make.centerY.equalTo(navi);
        make.height.mas_equalTo(30);
    }];

    UIView *leftV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(8, 5, 20, 20)];
    imgV.image = [UIImage imageNamed:@"搜索"];
    [leftV addSubview:imgV];
    self.searchTextField.leftView = leftV;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        SWClassGoodsVC *vc = [[SWClassGoodsVC alloc] init];
        vc.cid = @"";
        vc.sid = @"";
        vc.cate_name = @"默认";
        vc.normalSearchStr = textField.text;
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
    return YES;
}

- (void)doSearch {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.returnBtn.hidden = YES;
    self.titleL.text = @"商品分类";
    self.selectTableIndex = 0;
    [self addSearchView];
    [self.view addSubview:self.classTableView];
    [self.view addSubview:self.classCollectionView];
    [self requestData];
}

- (UITableView *)classTableView {
    if (!_classTableView) {
        _classTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + 50 + statusbarHeight, 110, _window_height - (64 + 44 + statusbarHeight + ShowDiff + 48)) style:0];
        _classTableView.delegate = self;
        _classTableView.dataSource = self;
        _classTableView.separatorStyle = 0;
        _classTableView.backgroundColor = colorf0;
    }
    return _classTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.classArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWClassGoodsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"classGoodsTableCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWClassGoodsTableCell" owner:nil options:nil] lastObject];
        [cell.titleBtn setBackgroundImage:[SWToolClass getImgWithColor:colorf0] forState:0];
        [cell.titleBtn setBackgroundImage:[SWToolClass getImgWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
    }
    NSDictionary *dic = self.classArray[indexPath.row];
    [cell.titleBtn setTitle:minstr([dic valueForKey:@"cate_name"]) forState:0];
    cell.titleBtn.selected = indexPath.row == self.selectTableIndex;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row != self.selectTableIndex) {
        self.isClickLeft = YES;
        self.selectTableIndex = indexPath.row;
        [tableView reloadData];
        [self.classCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.selectTableIndex] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        self.classCollectionView.contentOffset = CGPointMake(0, self.classCollectionView.contentOffset.y - 70);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isClickLeft = NO;
        });
    }
}

- (UICollectionView *)classCollectionView {
    if (!_classCollectionView) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        flow.scrollDirection = UICollectionViewScrollDirectionVertical;
        flow.itemSize = CGSizeMake((_window_width - 110) / 3 - 0.1, (_window_width - 110) / 3 - 0.1);
        flow.minimumLineSpacing = 0;
        flow.minimumInteritemSpacing = 0;
        flow.headerReferenceSize = CGSizeMake(_window_width - 110, 50);
        flow.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
        _classCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(110, self.classTableView.top, _window_width - 110, self.classTableView.height) collectionViewLayout:flow];
        [_classCollectionView registerNib:[UINib nibWithNibName:@"SWClassGoodsCell" bundle:nil] forCellWithReuseIdentifier:@"classGoodsCELL"];
        [_classCollectionView registerClass:[SWClassHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"classHeaderV"];
        _classCollectionView.delegate = self;
        _classCollectionView.dataSource = self;
        _classCollectionView.backgroundColor = [UIColor whiteColor];
    }
    return _classCollectionView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.classArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *array = [self.classArray[section] valueForKey:@"children"];
    return array.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSDictionary *oneDic = self.classArray[indexPath.section];
    NSDictionary *twoDic = [oneDic valueForKey:@"children"][indexPath.row];
    SWClassGoodsVC *vc = [[SWClassGoodsVC alloc] init];
    vc.cid = minstr([oneDic valueForKey:@"id"]);
    vc.sid = minstr([twoDic valueForKey:@"id"]);
    vc.cate_name = minstr([twoDic valueForKey:@"cate_name"]);
    vc.normalSearchStr = @"";
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SWClassGoodsCell *cell = (SWClassGoodsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"classGoodsCELL" forIndexPath:indexPath];
    NSArray *array = [self.classArray[indexPath.section] valueForKey:@"children"];
    NSDictionary *dic = array[indexPath.row];
    [cell.thumbImgView sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"pic"])]];
    cell.nameL.text = minstr([dic valueForKey:@"cate_name"]);
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SWClassHeaderView *header = (SWClassHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"classHeaderV" forIndexPath:indexPath];
        if (!header.titleLabel) {
            [header addShowView];
        }
        NSDictionary *dic = self.classArray[indexPath.section];
        header.titleLabel.text = minstr([dic valueForKey:@"cate_name"]);
        return header;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (self.isClickLeft) {
        return;
    }
    CGPoint point = [view convertPoint:CGPointZero toView:self.view];
    if (point.y < 100 && [elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        self.selectTableIndex = indexPath.section;
        [self.classTableView reloadData];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (self.isClickLeft) {
        return;
    }
    CGPoint point = [view convertPoint:CGPointZero toView:self.view];
    if (point.y < 100 && [elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        self.selectTableIndex = indexPath.section;
        [self.classTableView reloadData];
    }
}

- (void)requestData {
    [SWToolClass getQCloudWithUrl:@"category" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        self.classArray = info;
        [self.classTableView reloadData];
        [self.classCollectionView reloadData];
    } Fail:^{
    }];
}

@end
