//
//  SWAddGoodsViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWAddGoodsViewController.h"
#import "SWAddGoodsCell.h"

@interface SWAddGoodsViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,AddGoodsCellDelegate>{
    NSMutableArray *dataArray;
    int page;
    UITextField *searchTextF;
    NSMutableArray *originalArray;//用这个数组记录最开始数据
    NSString *searchKeywords;
}
@property (nonatomic,strong) UITableView *godsTableView;

@end

@implementation SWAddGoodsViewController
-(UITableView *)godsTableView{
    if (!_godsTableView) {
        _godsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+46+statusbarHeight, _window_width, _window_height-ShowDiff-(64+46+statusbarHeight)) style:0];
        _godsTableView.delegate = self;
        _godsTableView.dataSource = self;
        _godsTableView.separatorStyle = 0;
        _godsTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            page = 1;
            [self requestData:searchKeywords];
        }];
        _godsTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            page ++;
            [self requestData:searchKeywords];
        }];
    }
    return _godsTableView;
}
- (void)addSearchView{
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, 46)];
    searchView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:searchView];
    
    searchTextF = [[UITextField alloc]initWithFrame:CGRectMake(15, 8, _window_width-30, 30)];
    searchTextF.font = SYS_Font(14);
    searchTextF.placeholder = @"搜索商品";
    searchTextF.delegate = self;
    searchTextF.leftViewMode = UITextFieldViewModeAlways;
    searchTextF.layer.cornerRadius = 15;
    searchTextF.layer.masksToBounds = YES;
    searchTextF.backgroundColor = RGB_COLOR(@"#F5F5F5", 1);
//    searchTextF.keyboardType = UIKeyboardTypeWebSearch;
    [searchView addSubview:searchTextF];
    UIView *leftV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(8, 5, 20, 20)];
    imgV.image = [UIImage imageNamed:@"搜索"];
    [leftV addSubview:imgV];
    searchTextF.leftView = leftV;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (_isVideo) {
        self.titleL.text = @"关联商品";
    }else{
        self.titleL.text = @"添加商品";
    }
    page = 1;
    dataArray = [NSMutableArray array];
    originalArray = [NSMutableArray array];
    searchKeywords = @"";
    [self addSearchView];
    [self.view addSubview:self.godsTableView];
    [self requestData:searchKeywords];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keywordsChanged) name:UITextFieldTextDidChangeNotification object:nil];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWAddGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddGoodsCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWAddGoodsCell" owner:nil options:nil] lastObject];
        cell.delegate = self;
        if (_isVideo) {
            cell.selectedBtn.hidden = NO;
            cell.addBtn.hidden = YES;
            cell.daixiaoL.text = @"";
            cell.jiageLabel.hidden = YES;
//            [cell.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.right.equalTo(cell.contentView).offset(-50);
//                make.left.equalTo(cell.thumbImageView.mas_right).offset(15);
//                make.top.equalTo(cell.thumbImageView).offset(3);
//            }];
        }
    }
    SWLiveGoodsModel *model = dataArray[indexPath.row];
    cell.model = model;
    if ([model.goodsID isEqual:_goodsID]) {
        cell.selectedBtn.selected = YES;
    }else{
        cell.selectedBtn.selected = NO;
    }
    if (_isVideo) {
        cell.priceLabel.text = model.price;
    }
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isVideo) {
        SWLiveGoodsModel *model = dataArray[indexPath.row];
        NSDictionary *dic = @{
            @"id":model.goodsID,
            @"name":model.name
        };
        if (self.block) {
            self.block(dic);
        }
        [self doReturn];
    }
}
- (void)requestData:(NSString *)keyword{
    NSString *url = [NSString stringWithFormat:@"shoplist?liveuid=%@&page=%d&keyword=%@",[SWConfig getOwnID],page,keyword];

    [SWToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_godsTableView.mj_header endRefreshing];
        [_godsTableView.mj_footer endRefreshing];

        if (code == 200) {
            if (page == 1) {
                [dataArray removeAllObjects];
                [originalArray removeAllObjects];
            }
            for (NSDictionary *dci in info) {
                SWLiveGoodsModel *model = [[SWLiveGoodsModel alloc]initWithDic:dci];
                [dataArray addObject:model];
                [originalArray addObject:model];
            }
            [_godsTableView reloadData];
            if ([info count] < 20) {
                [_godsTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } Fail:^{
        [_godsTableView.mj_header endRefreshing];
        [_godsTableView.mj_footer endRefreshing];
    }];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    return YES;
}
- (void)keywordsChanged{
    page = 1;
    searchKeywords = searchTextF.text;
    [self requestData:searchKeywords];
}
- (void)doReturn{
    [super doReturn];
}
-(void)addGoodsChange:(SWLiveGoodsModel *)model
{
    if (self.block) {
        self.block(@{});
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
