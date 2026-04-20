//
//  SWLiveUserManagerVC.m
//  WYLiveShopping
//
//  Created by apple on 2020/8/15.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWLiveUserManagerVC.h"

#import "SWRoomUserTypeCell.h"
#import "SWRoomUserListViewController.h"
@interface SWLiveUserManagerVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *leftTableView;
@property (nonatomic, strong) NSArray *listArray;

@end

@implementation SWLiveUserManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.titleL.text = _titleStr;
    self.listArray = @[@"禁言用户",@"拉黑用户"];
    self.leftTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight-ShowDiff) style:0];
    self.leftTableView.delegate = self;
    self.leftTableView.dataSource = self;
    self.leftTableView.separatorStyle = 0;
    self.leftTableView.backgroundColor = RGB_COLOR(@"#fafafa", 1);
    [self.view addSubview:self.leftTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWRoomUserTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomUserTypeCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWRoomUserTypeCell" owner:nil options:nil] lastObject];
    }
    cell.titleL.text = self.listArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SWRoomUserListViewController *vc = [[SWRoomUserListViewController alloc]init];
    vc.type = indexPath.row + 1;
    vc.titleStr = self.listArray[indexPath.row];
    vc.liveuid = _liveuid;
    [self.navigationController pushViewController:vc animated:YES];
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
