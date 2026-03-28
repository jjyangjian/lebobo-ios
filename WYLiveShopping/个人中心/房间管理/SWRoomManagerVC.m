//
//  SWRoomManagerVC.m
//  WYLiveShopping
//
//  Created by apple on 2020/8/15.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWRoomManagerVC.h"
#import "SWRoomUserTypeCell.h"
#import "SWRoomUserListViewController.h"
#import "SWLiveUserManagerVC.h"

@interface SWRoomManagerVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UIButton *leftButton;
@property (nonatomic,strong) UIButton *rightButton;
@property (nonatomic,strong) UIView *lineViewRef;
@property (nonatomic,strong) UITableView *leftTableView;
@property (nonatomic,strong) UITableView *rightTableView;
@property (nonatomic,strong) NSArray *leftArray;
@property (nonatomic,strong) NSMutableArray *rightArray;
@property (nonatomic,assign) NSInteger page;

@end

@implementation SWRoomManagerVC
- (void)navi{
    NSArray *arr = @[@"我的直播间",@"我的房间"];
    for (int i = 0; i < arr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(_window_width/2-90+i*90, 24+statusbarHeight, 90, 40);
        [btn setTitle:arr[i] forState:0];
        [btn setTitleColor:RGB_COLOR(@"#323232", 1) forState:UIControlStateSelected];
        [btn setTitleColor:RGB_COLOR(@"#969696", 1) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(topBtnclick:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = SYS_Font(15);
        [self.naviView addSubview:btn];
        if (i == 0) {
            btn.selected = YES;
            self.leftButton = btn;
            self.lineViewRef = [[UIView alloc]initWithFrame:CGRectMake(btn.centerX-7.5, 60+statusbarHeight, 15, 4)];
            self.lineViewRef.layer.cornerRadius = 2;
            self.lineViewRef.layer.masksToBounds = YES;
            [self.naviView addSubview:self.lineViewRef];
        }else{
            btn.selected = NO;
            self.rightButton = btn;
        }
    }
}
- (void)topBtnclick:(UIButton *)sender{
    if (!sender.selected) {
        sender.selected = YES;
        [UIView animateWithDuration:0.2 animations:^{
            self.lineViewRef.centerX = sender.centerX;
        }];
        if (sender == self.leftButton) {
            self.rightButton.selected = NO;
            self.leftTableView.hidden = NO;
            self.rightTableView.hidden = YES;
        }else{
            self.leftButton.selected = NO;
            self.leftTableView.hidden = YES;
            self.rightTableView.hidden = NO;
            if (self.rightArray.count == 0) {
                [self requestData];
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navi];
    self.page = 1;
    self.leftArray = @[@"管理员",@"禁言用户",@"拉黑用户"];
    self.leftTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight-ShowDiff) style:0];
    self.leftTableView.delegate = self;
    self.leftTableView.dataSource = self;
    self.leftTableView.separatorStyle = 0;
    self.leftTableView.backgroundColor = RGB_COLOR(@"#fafafa", 1);
    [self.view addSubview:self.leftTableView];
    
    self.rightTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight-ShowDiff) style:0];
    self.rightTableView.delegate = self;
    self.rightTableView.dataSource = self;
    self.rightTableView.separatorStyle = 0;
    self.rightTableView.hidden = YES;
    self.rightTableView.backgroundColor = RGB_COLOR(@"#fafafa", 1);
    self.rightArray = [NSMutableArray array];
    [self.view addSubview:self.rightTableView];
    [self requestData];
}
#pragma mark-TODO
- (void)requestData{
    [SWToolClass postNetworkWithUrl:@"managelist" andParameter:@{@"p":@(self.page)} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            NSArray *infoA = info;
            if (self.page == 1) {
                [self.rightArray removeAllObjects];
            }
            [self.rightArray addObjectsFromArray:infoA];
            if (infoA.count < 20) {
                [self.rightTableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                self.rightTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                    self.page += 1;
                    [self requestData];
                }];
            }
            [self.rightTableView reloadData];
        }
    } fail:^{
        
    }];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.leftTableView) {
        return self.leftArray.count;
    }
    return self.rightArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWRoomUserTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomUserTypeCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWRoomUserTypeCell" owner:nil options:nil] lastObject];
    }
    if (tableView == self.leftTableView) {
        cell.titleL.text = self.leftArray[indexPath.row];
    }else{
        
        cell.titleL.text = [NSString stringWithFormat:@"%@ 的直播间",minstr([self.rightArray[indexPath.row] valueForKey:@"nickname"])];
    }
    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.leftTableView) {
        SWRoomUserListViewController *vc = [[SWRoomUserListViewController alloc]init];
        vc.type = indexPath.row;
        vc.titleStr = self.leftArray[indexPath.row];
        vc.liveuid = [SWConfig getOwnID];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        NSDictionary *userinfo = self.rightArray[indexPath.row];
        SWLiveUserManagerVC *vc = [[SWLiveUserManagerVC alloc]init];
        vc.titleStr = [NSString stringWithFormat:@"%@ 的直播间",minstr([userinfo valueForKey:@"nickname"])];
        vc.liveuid = minstr([userinfo valueForKey:@"liveuid"]);
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
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
