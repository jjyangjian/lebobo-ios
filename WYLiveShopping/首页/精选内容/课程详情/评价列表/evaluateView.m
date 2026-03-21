//
//  evaluateView.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "evaluateView.h"
#import "evaluateCell.h"
#import "WYCouserStarView.h"
#import "writeEvaluateViewController.h"

@interface evaluateView ()<UITableViewDelegate,UITableViewDataSource>{
    int p;
    UITableView *listTableView;
    NSMutableArray *dataArray;
    NSString *_courseID;
    BOOL isCourse;
    UIView *headerV;
    WYCouserStarView *star;
    UILabel *starNumL;
    UIButton *writeButton;

}
@property (nonatomic,strong) UIView *nothingView;

@end

@implementation evaluateView
- (void)doWrite{
    writeEvaluateViewController *vc = [[writeEvaluateViewController alloc]init];
    vc.courseMsgDic = _courseDiccccc;
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

}

- (void)setCourseDiccccc:(NSDictionary *)courseDiccccc{
    _courseDiccccc = courseDiccccc;
    int isbuy = [minstr([_courseDiccccc valueForKey:@"isbuy"]) intValue];
    if (isbuy == 1) {
        writeButton.hidden = NO;
    }else{
        writeButton.hidden = YES;
    }

}

- (instancetype)initWithFrame:(CGRect)frame andCourse:(NSDictionary *)course andIsCourse:(BOOL)isC{
    if (self = [super initWithFrame:frame]) {
        _courseID = minstr([course valueForKey:@"id"]);
        _courseDiccccc = course;
        isCourse = isC;
        p = 1;
        dataArray = [NSMutableArray array];
        [self creatUI:course];
        [self requestData];
    }
    return self;
}
- (void)creatUI:(NSDictionary *)course{
    listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _window_width, self.height) style:0];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    listTableView.separatorStyle = 0;
    listTableView.estimatedRowHeight = 100;
    [self addSubview:listTableView];
    listTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        p = 1;
        [self requestData];
    }];
    listTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        p ++;
        [self requestData];
    }];
    headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 60)];
    headerV.backgroundColor = [UIColor whiteColor];
    star = [[WYCouserStarView alloc]init];
    star.frame = CGRectMake(15, 20, 100, 20);
    [headerV addSubview:star];
    int starNum = [minstr([course valueForKey:@"star"]) intValue];
    [star setCurIndex:starNum andStartingDirectionLeft:YES];
    starNumL = [[UILabel alloc]init];
    starNumL.font = SYS_Font(14);
    starNumL.textColor = normalColors;
    starNumL.text = minstr([course valueForKey:@"star"]);
    [headerV addSubview:starNumL];
    [starNumL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(star);
        make.left.equalTo(star.mas_right).offset((starNum - 5) * 20 + 20);
    }];
    writeButton = [UIButton buttonWithType:0];
    writeButton.frame = CGRectMake(headerV.width-75, 20, 60, 20);
    [writeButton setTitle:@"写评价" forState:0];
    [writeButton setTitleColor:normalColors forState:0];
    writeButton.titleLabel.font = SYS_Font(10);
    [writeButton setCornerRadius:10];
    [writeButton setBorderWidth:1];
    [writeButton setBorderColor:normalColors];
    [writeButton addTarget:self action:@selector(doWrite) forControlEvents:UIControlEventTouchUpInside];
    [headerV addSubview:writeButton];
    int isbuy = [minstr([_courseDiccccc valueForKey:@"isbuy"]) intValue];
    if (isbuy == 1) {
        writeButton.hidden = NO;
    }else{
        writeButton.hidden = YES;
    }
    listTableView.tableHeaderView = headerV;

//    headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 90)];
//    headerV.backgroundColor = [UIColor whiteColor];
//    headerV.hidden = YES;
//    [self addSubview:headerV];
//    [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 0, _window_width, 5) andColor:colorf0 andView:headerV];
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, 100, 25)];
//    label.text = @"全部评价";
//    label.font = SYS_Font(16);
//    label.textColor = color32;
//    [headerV addSubview:label];
//    star = [[WYStarView alloc]init];
//    star.frame = CGRectMake(15, label.bottom + 5, 100, 20);
//    [headerV addSubview:star];
//    int starNum = [minstr([course valueForKey:@"star"]) intValue];
//    [star setCurIndex:starNum andStartingDirectionLeft:YES];
//    starNumL = [[UILabel alloc]init];
//    starNumL.font = SYS_Font(14);
//    starNumL.textColor = RGB_COLOR(@"#FFC822", 1);
//    starNumL.text = minstr([course valueForKey:@"star"]);
//    [headerV addSubview:starNumL];
//    [starNumL mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(star);
//        make.left.equalTo(star.mas_right).offset((starNum - 5) * 20 + 20);
//    }];
//    writeButton = [UIButton buttonWithType:0];
//    writeButton.frame = CGRectMake(headerV.width-75, 20, 60, 20);
//    [writeButton setTitle:@"写评价" forState:0];
//    [writeButton setTitleColor:normalColors forState:0];
//    writeButton.titleLabel.font = SYS_Font(10);
//    [writeButton setCornerRadius:10];
//    [writeButton setBorderWidth:1];
//    [writeButton setBorderColor:normalColors];
//    [writeButton addTarget:self action:@selector(doWrite) forControlEvents:UIControlEventTouchUpInside];
//    [headerV addSubview:writeButton];
//    if ([minstr([_courseDiccccc valueForKey:@"paytype"]) isEqual:@"1"]){
//        if ([minstr([_courseDiccccc valueForKey:@"isbuy"]) isEqual:@"1"]) {
//            writeButton.hidden = NO;
//        }else{
//            writeButton.hidden = YES;
//        }
//    }
//
//    listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, headerV.bottom, _window_width, self.height - 90) style:0];
//    listTableView.delegate = self;
//    listTableView.dataSource = self;
//    listTableView.separatorStyle = 0;
//    listTableView.estimatedRowHeight = 100;
//    [self addSubview:listTableView];
//    listTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        p = 1;
//        [self requestData];
//    }];
//    listTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
//        p ++;
//        [self requestData];
//    }];
    [self creatNothingView];
}
- (void)selfDowvaluateSucessToReload{
    p = 1;
    [self requestData];
}

- (void)requestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"coursecomment&courseid=%@&page=%d",_courseID,p] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [listTableView.mj_header endRefreshing];
        [listTableView.mj_footer endRefreshing];
        if (code == 200) {
            if (p == 1) {
                [dataArray removeAllObjects];
                int starNum = [minstr([info valueForKey:@"star"]) intValue];
                [star setCurIndex:starNum andStartingDirectionLeft:YES];
                starNumL.text = minstr([info valueForKey:@"star"]);
                [starNumL mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(star);
                    make.left.equalTo(star.mas_right).offset((starNum - 5) * 20 + 20);
                }];

            }
            NSArray *list = [info valueForKey:@"list"];
            for (NSDictionary *dic in list) {
                evaluateModel *model = [[evaluateModel alloc]initWithDic:dic];
                model.iscourse = isCourse;
                [dataArray addObject:model];
            }
            [listTableView reloadData];
            if (dataArray.count > 0) {
                _nothingView.hidden = YES;
            }else{
                _nothingView.hidden = NO;
            }

        }

    } Fail:^{
        [listTableView.mj_header endRefreshing];
        [listTableView.mj_footer endRefreshing];
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    evaluateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"evaluateCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"evaluateCell" owner:nil options:nil] lastObject];
    }
    cell.model = dataArray[indexPath.row];
    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)creatNothingView{
    _nothingView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, _window_width, listTableView.height-60)];
    _nothingView.backgroundColor = [UIColor whiteColor];
    _nothingView.hidden = YES;
    [listTableView addSubview:_nothingView];
    UIImageView *_nothingImgV = [[UIImageView alloc]initWithFrame:CGRectMake(_nothingView.width/2-40, 30, 80, 80)];
    _nothingImgV.contentMode = UIViewContentModeScaleAspectFit;
    _nothingImgV.image = [UIImage imageNamed:@"nothingImage"];
    [_nothingView addSubview:_nothingImgV];
    UILabel *_nothingTitleL = [[UILabel alloc]initWithFrame:CGRectMake(0, _nothingImgV.bottom+10, _window_width, 15)];
    _nothingTitleL.font = [UIFont systemFontOfSize:12];
    _nothingTitleL.textAlignment = NSTextAlignmentCenter;
    _nothingTitleL.text = @"还未收到评价";
    _nothingTitleL.textColor = colorCC;
    [_nothingView addSubview:_nothingTitleL];

}

@end
