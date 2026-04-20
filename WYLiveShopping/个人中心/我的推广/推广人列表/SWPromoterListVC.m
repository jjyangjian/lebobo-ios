//
//  SWPromoterListVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/3.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWPromoterListVC.h"
#import "SWPromoterUserCell.h"

@interface SWPromoterListVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic,strong) UILabel *allNumsLabel;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,copy) NSString *sortString;
@property (nonatomic,copy) NSString *gradeString;
@property (nonatomic,strong) UITextField *searchTextField;
@property (nonatomic,strong) NSMutableArray *gradeButtonArray;
@property (nonatomic,strong) NSMutableArray *sortButtonArray;
@property (nonatomic,strong) UIView *moveLineView;
@property (nonatomic,strong) UITableView *listTableView;

@end

@implementation SWPromoterListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.returnBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
    self.lineView.hidden = YES;
    self.naviView.backgroundColor = [UIColor clearColor];
    self.titleL.textColor = [UIColor whiteColor];
    self.titleL.text = @"推广人列表";
    self.dataArray = [NSMutableArray array];
    self.gradeButtonArray = [NSMutableArray array];
    self.sortButtonArray = [NSMutableArray array];

    self.page = 1;
    self.sortString = @"";
    self.gradeString = @"0";
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
    self.allNumsLabel = numsL;
    
    UIView *controlView = [[UIView alloc]initWithFrame:CGRectMake(0, headerImgView.bottom, _window_width, 130)];
    controlView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:controlView];
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 43, _window_width, 1) andColor:colorf0 andView:controlView];
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 129, _window_width, 1) andColor:colorf0 andView:controlView];

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
        [self.gradeButtonArray addObject:btn];
    }
    self.moveLineView = [[UIView alloc]initWithFrame:CGRectMake(_window_width*0.25-25, 43, 50, 1)];
    self.moveLineView.backgroundColor = normalColors;
    [controlView addSubview:self.moveLineView];
    
    self.searchTextField = [[UITextField alloc]initWithFrame:CGRectMake(15, self.moveLineView.bottom + 7, _window_width-60, 30)];
    self.searchTextField.textAlignment = NSTextAlignmentCenter;
    self.searchTextField.placeholder = @"点击搜索会员名称";
    self.searchTextField.font = SYS_Font(12);
    self.searchTextField.backgroundColor = colorf0;
    self.searchTextField.layer.cornerRadius = 15;
    self.searchTextField.layer.masksToBounds = YES;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.delegate = self;
    [controlView addSubview:self.searchTextField];
    UIButton *searchBtn = [UIButton buttonWithType:0];
    [searchBtn setImage:[UIImage imageNamed:@"推广搜索"] forState:0];
    searchBtn.frame = CGRectMake(self.searchTextField.right+5, self.searchTextField.top, 30, 30);
    [searchBtn addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:searchBtn];
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, self.searchTextField.bottom + 7, _window_width, 5) andColor:colorf0 andView:controlView];

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
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -btn.imageView.image.size.width-2.5, 0, btn.imageView.image.size.width+2.5);
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, rect.size.width+2.5, 0, -rect.size.width-2.5);

        [self.sortButtonArray addObject:btn];
    }
    self.listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, controlView.bottom, _window_width, _window_height-controlView.bottom) style:0];
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    self.listTableView.separatorStyle = 0;
    [self.view addSubview:self.listTableView];
    self.listTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        [self requestData];
    }];
    self.listTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        self.page ++;
        [self requestData];
    }];
}
- (void)gradeBtnClick:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    self.moveLineView.x = sender.x;
    for (UIButton *btn in self.gradeButtonArray) {
        btn.selected = (btn == sender);
    }

    if (sender.tag == 1000) {
        self.gradeString = @"0";
    }else{
        self.gradeString = @"1";
    }
    self.page = 1;
    [self requestData];
}
- (void)sortBtnClick:(UIButton *)sender{
    for (UIButton *btn in self.sortButtonArray) {
        if (btn != sender) {
            [btn setImage:[UIImage imageNamed:@"promoter_nor"] forState:0];
        }
    }
    if (sender.tag == 2000) {
        if ([self.sortString isEqual:@"childCount ASC"]) {
            self.sortString = @"childCount DESC";
            [sender setImage:[UIImage imageNamed:@"promoter_down"] forState:0];
        }else if ([self.sortString isEqual:@"childCount DESC"]) {
            self.sortString = @"";
            [sender setImage:[UIImage imageNamed:@"promoter_nor"] forState:0];
        }else{
            self.sortString = @"childCount ASC";
            [sender setImage:[UIImage imageNamed:@"promoter_up"] forState:0];
        }
    }else if (sender.tag == 2001){
        if ([self.sortString isEqual:@"numberCount ASC"]) {
            self.sortString = @"numberCount DESC";
            [sender setImage:[UIImage imageNamed:@"promoter_down"] forState:0];
        }else if ([self.sortString isEqual:@"numberCount DESC"]) {
            self.sortString = @"";
            [sender setImage:[UIImage imageNamed:@"promoter_nor"] forState:0];
        }else{
            self.sortString = @"numberCount ASC";
            [sender setImage:[UIImage imageNamed:@"promoter_up"] forState:0];
        }

    }else{
        if ([self.sortString isEqual:@"orderCount ASC"]) {
            self.sortString = @"orderCount DESC";
            [sender setImage:[UIImage imageNamed:@"promoter_down"] forState:0];
        }else if ([self.sortString isEqual:@"orderCount DESC"]) {
            self.sortString = @"";
            [sender setImage:[UIImage imageNamed:@"promoter_nor"] forState:0];
        }else{
            self.sortString = @"orderCount ASC";
            [sender setImage:[UIImage imageNamed:@"promoter_up"] forState:0];
        }
    }
    self.page = 1;
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
    [self.searchTextField resignFirstResponder];
    if (self.searchTextField.text.length > 0) {
        self.page = 1;
        [self requestData];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.page = 1;
    [self requestData];
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWPromoterUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"promoterUserCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWPromoterUserCell" owner:nil options:nil] lastObject];
    }
    cell.model = self.dataArray[indexPath.row];
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
        @"page":@(self.page),
        @"sort":self.sortString,
        @"grade":self.gradeString,
        @"keyword":minstr(self.searchTextField.text),
    };
    [SWToolClass postNetworkWithUrl:@"spread/people" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [self.listTableView.mj_header endRefreshing];
        [self.listTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (self.page == 1) {
                [self.dataArray removeAllObjects];
                int total = [minstr([info valueForKey:@"total"]) intValue];
                int totalLevel = [minstr([info valueForKey:@"totalLevel"]) intValue];
                self.allNumsLabel.attributedText = [self setAttText:[NSString stringWithFormat:@"%d", total + totalLevel]];
                for (int i = 0; i < self.gradeButtonArray.count; i ++) {
                    UIButton *btn = self.gradeButtonArray[i];
                    if (i == 0) {
                        [btn setTitle:[NSString stringWithFormat:@"一级(%d)", total] forState:0];
                    }else{
                        [btn setTitle:[NSString stringWithFormat:@"二级(%d)", totalLevel] forState:0];
                    }
                }
            }
            NSArray *list = [info valueForKey:@"list"];
            for (NSDictionary *dic in list) {
                SWPromoterUserModel *model = [[SWPromoterUserModel alloc]initWithDic:dic];
                [self.dataArray addObject:model];
            }
            [self.listTableView reloadData];
            if (self.page == 1) {
                [self.listTableView scrollsToTop];
            }
        }
    } fail:^{
        [self.listTableView.mj_header endRefreshing];
        [self.listTableView.mj_footer endRefreshing];

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
