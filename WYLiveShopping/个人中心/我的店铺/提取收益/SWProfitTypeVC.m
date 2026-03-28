//
//  SWProfitTypeVC.m
//  yunbaolive
//
//  Created by Boom on 2018/10/11.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "SWProfitTypeVC.h"
#import "SWProfitTypeCell.h"
#import "SWAddTypeView.h"

@interface SWProfitTypeVC ()<UITableViewDelegate,UITableViewDataSource,cellDelegate>
@property (nonatomic, strong) UITableView *typeTable;
@property (nonatomic, strong) NSArray *typeArray;
@property (nonatomic, strong) UILabel *nothingLabel;
@property (nonatomic, strong) SWAddTypeView *addTypeView;

@end

@implementation SWProfitTypeVC

- (void)addBottomView {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _window_height - 60 - ShowDiff, _window_width, 60 + ShowDiff)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];

    UIButton *addButton = [UIButton buttonWithType:0];
    addButton.frame = CGRectMake(_window_width * 0.25, 12, _window_width * 0.5, 36);
    [addButton setTitle:@"添加提现账户" forState:0];
    [addButton setTitleColor:normalColors forState:0];
    addButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    addButton.layer.cornerRadius = 18;
    addButton.layer.masksToBounds = YES;
    addButton.layer.borderColor = normalColors.CGColor;
    addButton.layer.borderWidth = 0.5;
    [addButton addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:addButton];
}

- (void)addBtnClick:(UIButton *)sender {
    if (!self.addTypeView) {
        self.addTypeView = [[SWAddTypeView alloc] init];
        [self.view addSubview:self.addTypeView];
    } else {
        self.addTypeView.hidden = NO;
    }
    __weak typeof(self) weakSelf = self;
    self.addTypeView.block = ^{
        [weakSelf requestData];
        [weakSelf.addTypeView removeFromSuperview];
        weakSelf.addTypeView = nil;
    };
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"提现账户";
    self.view.backgroundColor = RGB_COLOR(@"#f4f5f6", 1);

    self.typeTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + statusbarHeight, _window_width, _window_height - 64 - statusbarHeight - 60 - ShowDiff) style:UITableViewStylePlain];
    self.typeTable.delegate = self;
    self.typeTable.dataSource = self;
    self.typeTable.separatorStyle = 0;
    [self.view addSubview:self.typeTable];

    self.nothingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, _window_width, 20)];
    self.nothingLabel.text = @"您当前还没有设置提现账户";
    self.nothingLabel.textAlignment = NSTextAlignmentCenter;
    self.nothingLabel.font = [UIFont systemFontOfSize:14];
    self.nothingLabel.textColor = RGB_COLOR(@"#333333", 1);
    self.nothingLabel.hidden = YES;
    [self.view addSubview:self.nothingLabel];

    [self addBottomView];
    [self requestData];
}

- (void)requestData {
    [SWToolClass getQCloudWithUrl:@"account" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.typeArray = info;
            if (self.typeArray.count > 0) {
                self.nothingLabel.hidden = YES;
                self.typeTable.hidden = NO;
                [self.typeTable reloadData];
            } else {
                self.nothingLabel.hidden = NO;
                self.typeTable.hidden = YES;
            }
        }
    } Fail:^{
        self.nothingLabel.hidden = NO;
        self.typeTable.hidden = YES;
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.typeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWProfitTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profitTypeCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SWProfitTypeCell" owner:nil options:nil] lastObject];
    }
    cell.delegate = self;
    cell.indexRow = indexPath.row;
    NSDictionary *dic = self.typeArray[indexPath.row];
    if ([minstr([dic valueForKey:@"id"]) isEqual:self.selectID]) {
        cell.stateImgView.image = [UIImage imageNamed:@"preClassS"];
    } else {
        cell.stateImgView.image = [UIImage imageNamed:@"jubao_nor"];
    }
    int type = [minstr([dic valueForKey:@"type"]) intValue];
    switch (type) {
        case 1:
            cell.typeImgView.image = [UIImage imageNamed:@"profit_alipay"];
            cell.nameL.text = [NSString stringWithFormat:@"%@(%@)", minstr([dic valueForKey:@"account"]), minstr([dic valueForKey:@"name"])];
            break;
        case 2:
            cell.typeImgView.image = [UIImage imageNamed:@"profit_wx"];
            cell.nameL.text = [NSString stringWithFormat:@"%@", minstr([dic valueForKey:@"account"])];
            break;
        case 3:
            cell.typeImgView.image = [UIImage imageNamed:@"profit_card"];
            cell.nameL.text = [NSString stringWithFormat:@"%@(%@)", minstr([dic valueForKey:@"account"]), minstr([dic valueForKey:@"name"])];
            break;
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = self.typeArray[indexPath.row];
    if (![minstr([dic valueForKey:@"id"]) isEqual:self.selectID]) {
        self.block(dic);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self delateIndex:indexPath.row];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)delateIndex:(NSInteger)index {
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否确定删除此提现账号？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertContro addAction:cancleAction];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *dic = self.typeArray[index];
        [SWToolClass postNetworkWithUrl:@"accountdel" andParameter:@{@"accountid": minstr([dic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [MBProgressHUD showError:msg];
            if (code == 200) {
                [self requestData];
            }
        } fail:^{
        }];
    }];
    [alertContro addAction:sureAction];
    [self presentViewController:alertContro animated:YES completion:nil];
}

@end
