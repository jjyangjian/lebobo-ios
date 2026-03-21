//
//  CatalogView.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/12.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "CatalogView.h"
#import "XDMultTableView.h"
#import "catalogCell.h"
#import "courseContentViewController.h"
@interface CatalogView ()<UITableViewDelegate,UITableViewDataSource>{//<XDMultTableViewDatasource,XDMultTableViewDelegate>
    NSMutableArray *dataArray;
    NSString *courseID;
}

@property(nonatomic, readwrite, strong)UITableView *tableView;
@property (nonatomic,strong) UIView *nothingView;
@end

@implementation CatalogView

-(instancetype)initWithFrame:(CGRect)frame andCourseID:(NSString *)str{
    if (self = [super initWithFrame:frame]) {
        courseID = str;
        dataArray = [NSMutableArray array];
        [self creatUI];
        [self requestData];
    }
    return self;
}
- (void)creatUI{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:0];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = 0;
    _tableView.backgroundColor = [UIColor whiteColor];
//    _tableView.autoAdjustOpenAndClose = NO;
    [self addSubview:_tableView];
    _tableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        [self requestData];
    }];
    [self creatNothingView];

}
- (void)creatNothingView{
    _nothingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _tableView.height)];
    _nothingView.backgroundColor = [UIColor whiteColor];
    _nothingView.hidden = YES;
    [_tableView addSubview:_nothingView];
    UIImageView *_nothingImgV = [[UIImageView alloc]initWithFrame:CGRectMake(_nothingView.width/2-40, 120, 80, 80)];
    _nothingImgV.contentMode = UIViewContentModeScaleAspectFit;
    _nothingImgV.image = [UIImage imageNamed:@"nothingImage"];
    [_nothingView addSubview:_nothingImgV];
    UILabel *_nothingTitleL = [[UILabel alloc]initWithFrame:CGRectMake(0, _nothingImgV.bottom+10, _window_width, 15)];
    _nothingTitleL.font = [UIFont systemFontOfSize:12];
    _nothingTitleL.textAlignment = NSTextAlignmentCenter;
    _nothingTitleL.text = @"暂未添加课时";
    _nothingTitleL.textColor = colorCC;
    [_nothingView addSubview:_nothingTitleL];
    
}

-(void)setHomeDic:(NSDictionary *)homeDic{
    _homeDic = homeDic;
    if ([minstr([_homeDic valueForKey:@"mode"]) isEqual:@"1"]) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _tableView.width, 30)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-30, 30)];
        label.text = @"解锁模式课程，需按照课节顺序学习";
        label.textColor = color96;
        label.font = SYS_Font(11);
        [view addSubview:label];
        _tableView.tableHeaderView = view;
    }
}
- (void)reloadLIst:(NSDictionary *)dic{
    _homeDic = dic;
    [_tableView.mj_header beginRefreshing];
}

- (void)requestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"lessonlist&courseid=%@",courseID] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_tableView.mj_header endRefreshing];
        if (code == 200) {
            [dataArray removeAllObjects];
            for (NSDictionary *dic in info) {
                catalogModel *model = [[catalogModel alloc]initWithDic:dic];
                model.courseid = minstr([_homeDic valueForKey:@"id"]);
//                model.ifbuy = minstr([_homeDic valueForKey:@"isbuy"]);
//                model.avatar_thumb = minstr([[_homeDic valueForKey:@"userinfo"] valueForKey:@"avatar"]);
//                model.user_nickname = minstr([[_homeDic valueForKey:@"userinfo"] valueForKey:@"user_nickname"]);
                [dataArray addObject:model];

            }
            [_tableView reloadData];
            if (dataArray.count > 0) {
                _nothingView.hidden = YES;
            }else{
                _nothingView.hidden = NO;
            }

        }

    } Fail:^{
        [_tableView.mj_header endRefreshing];
    }];
}
#pragma mark - datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    catalogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"catalogCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"catalogCell" owner:nil options:nil] lastObject];
    }
    cell.model = dataArray[indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    catalogModel *model = dataArray[indexPath.row];
    CGFloat wordH = 0.0;
    if ([model.islast isEqual:@"1"]) {
        wordH = [self getSpaceLabelHeight:[NSString stringWithFormat:@"%@   上次学到  ",model.name] withFont:SYS_Font(14) withWidth:_window_width-131];
    }else{
        wordH = [self getSpaceLabelHeight:model.name withFont:SYS_Font(14) withWidth:_window_width-131];
    }
    if ([model.type intValue] > 3) {
        return wordH + 52;
    }
    return wordH + 35;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击cell");
    if ([minstr([_homeDic valueForKey:@"isbuy"]) isEqual:@"1"]) {
        
        catalogModel *model = dataArray[indexPath.row];
//        model.type = @"2";
        WeakSelf;
        courseContentViewController *vc = [[courseContentViewController alloc]init];
        vc.thumb = minstr([_homeDic valueForKey:@"thumb"]);
        vc.fromWhere = 1;
        vc.model = model;
        vc.block = ^{
            if ([minstr([weakSelf.homeDic valueForKey:@"mode"]) isEqual:@"1"]) {
                [weakSelf.tableView.mj_header beginRefreshing];
            }
        };
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }

}
/*
- (NSInteger)mTableView:(XDMultTableView *)mTableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = [dataArray[section] valueForKey:@"list"];
    return array.count;
}

- (XDMultTableViewCell *)mTableView:(XDMultTableView *)mTableView
              cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    catalogCell *cell = (catalogCell *)[mTableView dequeueReusableCellWithIdentifier:@"catalogCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"catalogCell" owner:nil options:nil] lastObject];
    }
//    NSArray *array = [dataArray[indexPath.section] valueForKey:@"list"];
    cell.model = dataArray[indexPath.row];
//    NSDictionary *subDic = array[indexPath.row];
//
//    cell.timeL.text = @"";
//    if (indexPath.row == 0) {
//        cell.lockImgV.hidden = YES;
//        cell.statusL.text = @"已学完";
//        cell.statusL.textColor = RGB_COLOR(@"#C7C7C7", 1);
//    }else if([minstr([subDic valueForKey:@"islive"]) isEqual:@"1"]){
//        cell.lockImgV.hidden = YES;
//        cell.statusL.text = @"正在直播";
//        cell.statusL.textColor = normalColors;
//        cell.timeL.text = minstr([subDic valueForKey:@"time_date"]);
//    }else{
//        cell.statusL.text = @"";
//        cell.lockImgV.hidden = NO;
//    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(XDMultTableView *)mTableView{
    return dataArray.count;
}

-(NSString *)mTableView:(XDMultTableView *)mTableView titleForHeaderInSection:(NSInteger)section{
    NSString *name = minstr([dataArray[section] valueForKey:@"name"]);
    return name;
}

#pragma mark - delegate
- (CGFloat)mTableView:(XDMultTableView *)mTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = [dataArray[indexPath.section] valueForKey:@"list"];
    catalogModel *model = array[indexPath.row];
    CGFloat wordH = 0.0;
    if ([model.islast isEqual:@"1"]) {
        wordH = [self getSpaceLabelHeight:[NSString stringWithFormat:@"%@   上次学到  ",model.name] withFont:SYS_Font(14) withWidth:_window_width-131];
    }else{
        wordH = [self getSpaceLabelHeight:model.name withFont:SYS_Font(14) withWidth:_window_width-131];
    }
    if ([model.type intValue] > 3) {
        return wordH + 52;
    }
    return wordH + 35;
}

- (CGFloat)mTableView:(XDMultTableView *)mTableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}


- (void)mTableView:(XDMultTableView *)mTableView willOpenHeaderAtSection:(NSInteger)section{
    NSLog(@"即将展开");
}


- (void)mTableView:(XDMultTableView *)mTableView willCloseHeaderAtSection:(NSInteger)section{
    NSLog(@"即将关闭");
}

- (void)mTableView:(XDMultTableView *)mTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击cell");
    NSArray *array = [dataArray[indexPath.section] valueForKey:@"list"];
    catalogModel *model = array[indexPath.row];
    if ([model.isenter isEqual:@"1"]) {
        if ([model.type intValue] > 3) {
//            //白板直播
//            if ([model.type intValue] == 7) {
                [self doEnterRoom:model];
//            }else{
//                [self doEnterRoom:model];
//            }
        }else{
//            if ([minstr([_homeDic valueForKey:@"isvip"]) isEqual:@"1"]) {
                [MBProgressHUD showMessage:@""];
                [WYToolClass postNetworkWithUrl:@"Vip.CheckCourse" andParameter:@{@"type":@"0",@"cid":minstr([_homeDic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                    [MBProgressHUD hideHUD];
                    if (code == 0) {
                        WeakSelf;
                        courseContentViewController *vc = [[courseContentViewController alloc]init];
                        vc.thumb = minstr([_homeDic valueForKey:@"thumb"]);
                        vc.fromWhere = 1;
                        vc.model = model;
                        vc.block = ^{
                            if ([minstr([weakSelf.homeDic valueForKey:@"mode"]) isEqual:@"1"]) {
                                [weakSelf.tableView.tableView.mj_header beginRefreshing];
                            }
                        };
                        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
                    }else if (code == 980 || code == 981){
                        [self showalertView:msg];
                    }else{
                        [MBProgressHUD showError:msg];
                    }
                } fail:^{
                    [MBProgressHUD hideHUD];
                }];

//            }else{
//                WeakSelf;
//                courseContentViewController *vc = [[courseContentViewController alloc]init];
//                vc.thumb = minstr([_homeDic valueForKey:@"thumb"]);
//                vc.fromWhere = 1;
//                vc.model = model;
//                vc.block = ^{
//                    if ([minstr([weakSelf.homeDic valueForKey:@"mode"]) isEqual:@"1"]) {
//                        [weakSelf.tableView.tableView.mj_header beginRefreshing];
//                    }
//                };
//                [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
//
//            }

        }

    }
}
 */
-(CGFloat)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 5;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f
    };
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.height;
}

- (void)doCourseDetaile:(NSString *)courseid{
    [MBProgressHUD showMessage:@""];
    [WYToolClass postNetworkWithUrl:@"Course.GetDetail" andParameter:@{@"courseid":courseid} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];

}

@end
