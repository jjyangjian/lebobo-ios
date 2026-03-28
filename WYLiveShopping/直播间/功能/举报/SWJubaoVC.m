//
//  SWJubaoVC.m
//  iphoneLive
//
//  Created by Boom on 2017/7/14.
//  Copyright © 2017年 cat. All rights reserved.
//

#import "SWJubaoVC.h"
#import "SWJubaoCell.h"
@interface SWJubaoVC ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
@property(nonatomic,strong) NSMutableArray *dataArr;
@property(nonatomic,strong) UITableView *table;
@property(nonatomic,strong) NSDictionary *selectedDictionary;
@property(nonatomic,assign) NSInteger selectedIndex;
@property(nonatomic,assign) CGFloat textHeight;
@property(nonatomic,strong) UITextView *reportTextView;
@property(nonatomic,strong) UILabel *placeholderLabel;
@property(nonatomic,strong) UILabel *headerLabel;
@property(nonatomic,strong) UIColor *backgroundColorRef;
@property(nonatomic,strong) UIView *sectionFooterView;

@end

@implementation SWJubaoVC

- (void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArr = [NSMutableArray array];
    self.titleL.text = @"举报";
    self.backgroundColorRef = RGB_COLOR(@"#f4f5f6", 1);
    self.table = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight-ShowDiff) style:UITableViewStylePlain];
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.backgroundColor = self.backgroundColorRef;
    if (@available(iOS 15.0, *)) {
        self.table.sectionHeaderTopPadding = 0;
    } else {
        // Fallback on earlier versions
    }

    self.selectedIndex = 100000;
    self.textHeight = 0.0;
    self.view.backgroundColor = self.backgroundColorRef;
    [self.view addSubview:self.table];
    [self requetData];
}

- (void)requetData{
    WeakSelf;
    [SWToolClass getQCloudWithUrl:@"livereportcat" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            weakSelf.dataArr = [info mutableCopy];
            [weakSelf.table reloadData];
        }
    } Fail:^{

    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (!self.headerLabel) {
        self.headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _window_width, 40)];
        self.headerLabel.text = @"   选择举报的理由";
        self.headerLabel.textColor = RGB_COLOR(@"#959697", 1);
        self.headerLabel.font = [UIFont systemFontOfSize:13];
        self.headerLabel.backgroundColor = RGB_COLOR(@"#f4f5f6", 1);
    }
    return self.headerLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (!self.sectionFooterView) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 80+110)];
        view.backgroundColor = self.backgroundColorRef;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, _window_width-20, 30)];
        label.textColor = RGB_COLOR(@"#959697", 1);
        label.text = @"更多详细信息请在说明框中描述（选填）";
        label.font = [UIFont systemFontOfSize:13];
        [view addSubview:label];
        self.reportTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, label.bottom, _window_width-20, 90)];
        self.reportTextView.layer.masksToBounds = YES;
        self.reportTextView.layer.cornerRadius = 5.0;
        self.reportTextView.font = SYS_Font(13);
        self.reportTextView.textColor = RGB_COLOR(@"#333333", 1);
        self.reportTextView.backgroundColor = [UIColor whiteColor];
        self.reportTextView.delegate = self;
        [view addSubview:self.reportTextView];
        self.placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 120, 15)];
        self.placeholderLabel.font = SYS_Font(12);
        self.placeholderLabel.textColor = RGB_COLOR(@"#999999", 1);
        [self.reportTextView addSubview:self.placeholderLabel];
        UIButton *submitButton = [UIButton buttonWithType:0];
        submitButton.frame = CGRectMake(20, self.reportTextView.bottom+10, _window_width-40, 40);
        submitButton.layer.masksToBounds = YES;
        submitButton.layer.cornerRadius = 20.0;
        [submitButton setBackgroundColor:normalColors];
        [submitButton setTitle:@"提交" forState:0];
        [submitButton addTarget:self action:@selector(dojubao) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:submitButton];
        self.sectionFooterView = view;
    }
    return self.sectionFooterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 80+110;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWJubaoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SWJubaoCell"];
    if (!cell) {
        cell = [[SWJubaoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SWJubaoCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.leftLabel.text = [self.dataArr[indexPath.row] valueForKey:@"name"];
    if (indexPath.row == self.selectedIndex) {
        cell.rightImage.image = [UIImage imageNamed:@"jubao_sel"];
    }else{
        cell.rightImage.image = [UIImage imageNamed:@"jubao_nor"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedDictionary = [NSDictionary dictionaryWithDictionary:self.dataArr[indexPath.row]];
    self.selectedIndex = indexPath.row;
    [self.table reloadData];
}

- (void)dojubao{
    if (self.selectedIndex == 100000) {
        [MBProgressHUD showError:@"请选择举报理由"];
        return;
    }
    NSString *content = [NSString stringWithFormat:@"%@%@", minstr([self.selectedDictionary valueForKey:@"name"]), self.reportTextView.text];

    NSMutableDictionary *parameterDic = @{
        @"touid":_liveuid,
        @"content":content
    }.mutableCopy;
    [SWToolClass postNetworkWithUrl:@"livereport" andParameter:parameterDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [MBProgressHUD showError:msg];
            [self doReturn];
        }
    } fail:^{

    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (![text isEqualToString:@""]) {
        self.placeholderLabel.hidden = YES;
    }

    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1) {
        self.placeholderLabel.hidden = NO;
    }

    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
