//
//  promoterListViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/3.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "promoterListViewController.h"
#import "promoterUserCell.h"

@interface promoterListViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    UILabel *allNumsLabel;
    int page;
    NSMutableArray *dataArray;
    NSString *sortStr;
    NSString *gradeStr;//0一级 1二级
    UITextField *searchTextT;
    NSMutableArray *gradeBtnArray;
    NSMutableArray *sortBtnArray;
    UIView *moveLineView;
    UITableView *listTableView;
}

@end

@implementation promoterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.returnBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
    self.lineView.hidden = YES;
    self.naviView.backgroundColor = [UIColor clearColor];
    self.titleL.textColor = [UIColor whiteColor];
    self.titleL.text = @"推广人列表";
    dataArray = [NSMutableArray array];
    gradeBtnArray = [NSMutableArray array];
    sortBtnArray = [NSMutableArray array];

    page = 1;
    sortStr = @"";
    gradeStr = @"0";
    [self creatHeaderView];
    [self requestData];
}
- (void)creatHeaderView{
    UIImageView *headerImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_width*0.304+64+statusbarHeight)];
    headerImgView.image = [UIImage imageNamed:@"推广头部_背景"];
    headerImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:headerImgView];
    [self.view sendSubviewToBack:headerImgView];
    
    UIImageView *imgV = [[UIImageView alloc]init];
    imgV.image = [UIImage imageNamed:@"推广人"];
    [headerImgView addSubview:imgV];
    [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(60);
        make.right.equalTo(headerImgView).offset(-45);
        make.bottom.equalTo(headerImgView).offset(-20);
    }];
    UILabel *numsL = [[UILabel alloc]init];
    numsL.textColor = [UIColor whiteColor];
    numsL.numberOfLines = 0;
    numsL.font = SYS_Font(14);
    [headerImgView addSubview:numsL];
    [numsL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerImgView).offset(25);
        make.centerY.equalTo(imgV);
    }];
    allNumsLabel = numsL;
    
    UIView *controlView = [[UIView alloc]initWithFrame:CGRectMake(0, headerImgView.bottom, _window_width, 130)];
    controlView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:controlView];
    [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 43, _window_width, 1) andColor:colorf0 andView:controlView];
    [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 129, _window_width, 1) andColor:colorf0 andView:controlView];

    NSArray *array = @[@"一级(0)",@"二级(0)"];
    for (int i = 0; i < array.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        [btn setTitle:array[i] forState:0];
        [btn setTitleColor:normalColors forState:UIControlStateSelected];
        [btn setTitleColor:color32 forState:0];
        btn.titleLabel.font = SYS_Font(14);
        btn.tag = 1000 + i;
        [btn addTarget:self action:@selector(gradeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [controlView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(controlView).multipliedBy(0.5 + i *1);
            make.centerY.equalTo(controlView.mas_top).offset(22);
        }];
        if (i == 0) {
            btn.selected = YES;
        }
        [gradeBtnArray addObject:btn];
    }
    moveLineView = [[UIView alloc]initWithFrame:CGRectMake(_window_width*0.25-25, 43, 50, 1)];
    moveLineView.backgroundColor = normalColors;
    [controlView addSubview:moveLineView];
    
    searchTextT = [[UITextField alloc]initWithFrame:CGRectMake(15, moveLineView.bottom + 7, _window_width-60, 30)];
    searchTextT.textAlignment = NSTextAlignmentCenter;
    searchTextT.placeholder = @"点击搜索会员名称";
    searchTextT.font = SYS_Font(12);
    searchTextT.backgroundColor = colorf0;
    searchTextT.layer.cornerRadius = 15;
    searchTextT.layer.masksToBounds = YES;
    searchTextT.returnKeyType = UIReturnKeySearch;
    searchTextT.delegate = self;
    [controlView addSubview:searchTextT];
    UIButton *searchBtn = [UIButton buttonWithType:0];
    [searchBtn setImage:[UIImage imageNamed:@"推广搜索"] forState:0];
    searchBtn.frame = CGRectMake(searchTextT.right+5, searchTextT.top, 30, 30);
    [searchBtn addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:searchBtn];
    [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, searchTextT.bottom + 7, _window_width, 5) andColor:colorf0 andView:controlView];

    NSArray *array2 = @[@"团队排序",@"金额排序",@"订单排序"];
    for (int i = 0; i < array2.count; i ++) {
        
        UIButton *btn = [UIButton buttonWithType:0];
        [btn setTitle:array2[i] forState:0];
        [btn setTitleColor:color32 forState:0];
        [btn setImage:[UIImage imageNamed:@"promoter_nor"] forState:0];
        btn.titleLabel.font = SYS_Font(14);
        btn.tag = 2000 + i;
        [btn addTarget:self action:@selector(sortBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(_window_width/3*i, 90, _window_width/3, 40);
        [controlView addSubview:btn];
        CGRect rect = [array2[i] boundingRectWithSize:CGSizeMake(1000, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : SYS_Font(14)} context:nil];
        //button标题的偏移量，这个偏移量是相对于图片的
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -btn.imageView.image.size.width-2.5, 0, btn.imageView.image.size.width+2.5);
        //button图片的偏移量，这个偏移量是相对于标题的
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, rect.size.width+2.5, 0, -rect.size.width-2.5);

        [sortBtnArray addObject:btn];
    }
    listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, controlView.bottom, _window_width, _window_height-controlView.bottom) style:0];
    listTableView.delegate = self;
    listTableView.dataSource =self;
    listTableView.separatorStyle = 0;
    [self.view addSubview:listTableView];
    listTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        [self requestData];
    }];
    listTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        page ++;
        [self requestData];
    }];
}
- (void)gradeBtnClick:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    moveLineView.x = sender.x;
    for (int i = 0; i < gradeBtnArray.count; i ++) {
        UIButton *btn = gradeBtnArray[i];
        if (btn == sender) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
    }

    if (sender.tag == 1000) {
        gradeStr = @"0";
    }else{
        gradeStr = @"1";
    }
    page = 1;
    [self requestData];
}
- (void)sortBtnClick:(UIButton *)sender{
    for (UIButton *btn in sortBtnArray) {
        if (btn != sender) {
            [btn setImage:[UIImage imageNamed:@"promoter_nor"] forState:0];
        }
    }
    if (sender.tag == 2000) {
        if ([sortStr isEqual:@"childCount ASC"]) {
            sortStr = @"childCount DESC";
            [sender setImage:[UIImage imageNamed:@"promoter_down"] forState:0];
        }else if ([sortStr isEqual:@"childCount DESC"]) {
            sortStr = @"";
            [sender setImage:[UIImage imageNamed:@"promoter_nor"] forState:0];
        }else{
            sortStr = @"childCount ASC";
            [sender setImage:[UIImage imageNamed:@"promoter_up"] forState:0];
        }
    }else if (sender.tag == 2001){
        if ([sortStr isEqual:@"numberCount ASC"]) {
            sortStr = @"numberCount DESC";
            [sender setImage:[UIImage imageNamed:@"promoter_down"] forState:0];
        }else if ([sortStr isEqual:@"numberCount DESC"]) {
            sortStr = @"";
            [sender setImage:[UIImage imageNamed:@"promoter_nor"] forState:0];
        }else{
            sortStr = @"numberCount ASC";
            [sender setImage:[UIImage imageNamed:@"promoter_up"] forState:0];
        }

    }else{
        if ([sortStr isEqual:@"orderCount ASC"]) {
            sortStr = @"orderCount DESC";
            [sender setImage:[UIImage imageNamed:@"promoter_down"] forState:0];
        }else if ([sortStr isEqual:@"orderCount DESC"]) {
            sortStr = @"";
            [sender setImage:[UIImage imageNamed:@"promoter_nor"] forState:0];
        }else{
            sortStr = @"orderCount ASC";
            [sender setImage:[UIImage imageNamed:@"promoter_up"] forState:0];
        }
    }
    page = 1;
    [self requestData];
}

- (NSAttributedString *)setAttText:(NSString *)nums{
    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"推广人数\n%@人",nums]];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;

    [muStr addAttributes:@{NSFontAttributeName:SYS_Font(25)} range:NSMakeRange(5, nums.length)];
    [muStr addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, muStr.length)];
    return muStr;
}


- (void)doSearch{
    [searchTextT resignFirstResponder];
    if (searchTextT.text.length > 0) {
        page = 1;
        [self requestData];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    page = 1;
    [self requestData];
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    promoterUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"promoterUserCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"promoterUserCell" owner:nil options:nil] lastObject];
    }
    cell.model = dataArray[indexPath.row];
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)requestData{
    NSDictionary *dic = @{
        @"page":@(page),
        @"sort":sortStr,
        @"grade":gradeStr,
        @"keyword":minstr(searchTextT.text),
    };
    [WYToolClass postNetworkWithUrl:@"spread/people" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [listTableView.mj_header endRefreshing];
        [listTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (page == 1) {
                [dataArray removeAllObjects];
                int total = [minstr([info valueForKey:@"total"]) intValue];
                int totalLevel = [minstr([info valueForKey:@"totalLevel"]) intValue];
                allNumsLabel.attributedText = [self setAttText:[NSString stringWithFormat:@"%d",total+totalLevel]];
                for (int i = 0; i < gradeBtnArray.count; i ++) {
                    UIButton *btn = gradeBtnArray[i];
                    if (i == 0) {
                        [btn setTitle:[NSString stringWithFormat:@"一级(%d)",total] forState:0];
                    }else{
                        [btn setTitle:[NSString stringWithFormat:@"二级(%d)",totalLevel] forState:0];
                    }
                }
            }
            NSArray *list = [info valueForKey:@"list"];
            for (NSDictionary *dic in list) {
                promoterUserModel *model = [[promoterUserModel alloc]initWithDic:dic];
                [dataArray addObject:model];
            }
//            promoterUserModel *model = [[promoterUserModel alloc]initWithDic:@{}];
//            model.avatar = [Config getavatar];
//            model.nickname = @"sfsdfsd";
//            model.time = @"2020-12-12";
//            model.childCount = @"99";
//            model.orderCount = @"77";
//            model.numberCount = @"9999.00";
//            [dataArray addObject:model];
//            [dataArray addObject:model];
//            [dataArray addObject:model];
//            [dataArray addObject:model];
//            [dataArray addObject:model];
//            [dataArray addObject:model];
//            [dataArray addObject:model];
//            [dataArray addObject:model];
//            [dataArray addObject:model];
//            [dataArray addObject:model];
//            [dataArray addObject:model];
//            [dataArray addObject:model];

            [listTableView reloadData];
            if (page == 1) {
                [listTableView scrollsToTop];
            }
        }
    } fail:^{
        [listTableView.mj_header endRefreshing];
        [listTableView.mj_footer endRefreshing];

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
