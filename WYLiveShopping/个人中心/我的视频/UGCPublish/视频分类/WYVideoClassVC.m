//
//  YBVideoClassVC.m
//  iphoneLive
//
//  Created by YB007 on 2019/11/27.
//  Copyright © 2019 cat. All rights reserved.
//

#import "WYVideoClassVC.h"
#import "videoTopicCell.h"

@interface WYVideoClassVC ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *allArray;
    int p;
}
@property (nonatomic,strong) UITableView *videoClassTableView;

@end

@implementation WYVideoClassVC

- (UITableView *)videoClassTableView{
    if (!_videoClassTableView) {
        _videoClassTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, _window_height-64-statusbarHeight)];
        _videoClassTableView.backgroundColor = [UIColor whiteColor];
        _videoClassTableView.delegate = self;
        _videoClassTableView.dataSource = self;
        _videoClassTableView.separatorStyle = 0;
        [self.view addSubview:_videoClassTableView];
//        _videoClassTableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
//            p = 1;
//            [self requestData];
//        }];
//        _videoClassTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
//            p++;
//            [self requestData];
//        }];
    }
    return _videoClassTableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"选择分类";
    allArray = [NSMutableArray array];
    p = 1;
    [self.view addSubview:self.videoClassTableView];
    [self requestData];
}
- (void)requestData{
    [WYToolClass getQCloudWithUrl:@"videocat&type=0" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            allArray = [info mutableCopy];
            [_videoClassTableView reloadData];
        }
    } Fail:^{
        
    }];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return allArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    videoTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoTopicCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"videoTopicCell" owner:nil options:nil] lastObject];
    }
    cell.imgView.hidden = YES;
    [cell.topicTitleL mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.contentView).offset(15);
        make.centerY.equalTo(cell.contentView);
    }];
    cell.topicTitleL.text = minstr([allArray[indexPath.row] valueForKey:@"name"]);
    
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.videoClassEvent) {
        self.videoClassEvent(allArray[indexPath.row]);
        [self doReturn];
//        [self.view endEditing:YES];
//        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
