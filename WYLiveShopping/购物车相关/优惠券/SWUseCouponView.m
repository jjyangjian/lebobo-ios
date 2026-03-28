//
//  SWUseCouponView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/2.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWUseCouponView.h"
#import "SWUseCouponCell.h"
#import "SWCartModel.h"
#import "SWCouponTableViewCell.h"

@interface SWUseCouponView()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIView *showView;
@property (nonatomic, assign) BOOL isDraw;
@property (nonatomic, copy) NSString *selectedID;
@property (nonatomic, copy) NSString *minPrice;
@property (nonatomic, strong) NSDictionary *cartMessage;
@property (nonatomic, strong) UITableView *couponTbaleView;
@property (nonatomic, strong) NSMutableArray *dataArrat;
@property (nonatomic, strong) NSArray *infoArray;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIImageView *nothingImgView;
@end

@implementation SWUseCouponView
- (void)doHide{
    [UIView animateWithDuration:0.3 animations:^{
        self.showView.y = _window_height;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        if (!self.isDraw) {
            self.block(nil);
        }
    }];
}

- (instancetype)initWithCouponID:(NSString *)sid andIsDraw:(BOOL)isd andUsePrice:(NSString *)price andCart:(NSDictionary *)cart{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, _window_width, _window_height);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.dataArrat = [NSMutableArray array];
        self.isDraw = isd;
        self.selectedID = sid;
        self.minPrice = price;
        self.cartMessage = cart;
        [self creatUI];
        [self requestData];
    }
    return self;
}

- (void)requestData{
    NSString *url;
    if (self.isDraw) {
        url = [NSString stringWithFormat:@"coupons?type=1&product_id=%@", self.selectedID];
    } else {
        NSString *cartids = @"";
        for (SWCartModel *model in [self.cartMessage valueForKey:@"model"]) {
            if (cartids.length == 0) {
                cartids = model.cart_id;
            } else {
                cartids = [NSString stringWithFormat:@"%@,%@", cartids, model.cart_id];
            }
        }
        url = [NSString stringWithFormat:@"coupons/order/%@?mer_id=%@&cartId=%@", self.minPrice, minstr([self.cartMessage valueForKey:@"mer_id"]), cartids];
    }
    [SWToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.infoArray = info;
            for (NSDictionary *dic in self.infoArray) {
                SWCouponModel *model = [[SWCouponModel alloc] initWithDic:dic];
                model.isDraw = self.isDraw;
                [self.dataArrat addObject:model];
            }

            [self.couponTbaleView reloadData];
            if (self.dataArrat.count == 0) {
                self.bottomView.hidden = YES;
                self.nothingImgView.hidden = NO;
            }
        }
    } Fail:^{

    }];
}

- (void)creatUI{
    UIButton *hideButton = [UIButton buttonWithType:0];
    hideButton.frame = CGRectMake(0, 0, _window_width, _window_height - _window_width - ShowDiff);
    [hideButton addTarget:self action:@selector(doHide) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:hideButton];

    self.showView = [[UIView alloc] initWithFrame:CGRectMake(0, _window_height, _window_width, _window_width + ShowDiff)];
    self.showView.backgroundColor = RGB_COLOR(@"#F5F5F5", 1);
    [self addSubview:self.showView];
    self.showView.layer.mask = [[SWToolClass sharedInstance] setViewLeftTop:10 andRightTop:10 andView:self.showView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"优惠券";
    titleLabel.textColor = color32;
    titleLabel.font = SYS_Font(16);
    [self.showView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.showView);
        make.centerY.equalTo(self.showView.mas_top).offset(28);
    }];

    UIButton *closeButton = [UIButton buttonWithType:0];
    [closeButton setImage:[UIImage imageNamed:@"userMsg_close"] forState:0];
    [closeButton addTarget:self action:@selector(doHide) forControlEvents:UIControlEventTouchUpInside];
    [self.showView addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.right.equalTo(self.showView).offset(-10);
        make.centerY.equalTo(titleLabel);
    }];

    [self.showView addSubview:self.couponTbaleView];
    if (self.isDraw) {
        self.couponTbaleView.height = self.showView.height - 55 - ShowDiff;
    } else {
        [self.showView addSubview:self.bottomView];
    }

    [self show];
}

- (void)show{
    self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.showView.y = _window_height - _window_width - ShowDiff;
    }];
}

- (UITableView *)couponTbaleView{
    if (!_couponTbaleView) {
        _couponTbaleView = [[UITableView alloc] initWithFrame:CGRectMake(0, 55, _window_width, self.showView.height - 55 - 60 - ShowDiff) style:0];
        _couponTbaleView.delegate = self;
        _couponTbaleView.dataSource = self;
        _couponTbaleView.separatorStyle = 0;
        _couponTbaleView.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
        [_couponTbaleView addSubview:self.nothingImgView];
    }
    return _couponTbaleView;
}

- (UIImageView *)nothingImgView{
    if (!_nothingImgView) {
        _nothingImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, _window_width, _window_width * 0.55)];
        _nothingImgView.image = [UIImage imageNamed:@"noCoupon"];
        _nothingImgView.contentMode = UIViewContentModeScaleAspectFit;
        _nothingImgView.hidden = YES;
    }
    return _nothingImgView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArrat.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isDraw) {
        SWCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WYCouponTableViewCELL"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SWCouponTableViewCell" owner:nil options:nil] lastObject];
            cell.isHome = NO;
            [cell.controlBtn setTitle:@"已领取" forState:UIControlStateSelected];
            [cell.controlBtn setBackgroundImage:[SWToolClass getImgWithColor:[UIColor clearColor]] forState:UIControlStateSelected];
            [cell.controlBtn setBackgroundImage:[SWToolClass getImgWithColor:[UIColor whiteColor]] forState:0];
            [cell.controlBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        }
        cell.model = self.dataArrat[indexPath.row];
        return cell;
    } else {
        SWUseCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:@"useCouponCELL"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SWUseCouponCell" owner:nil options:nil] lastObject];
        }
        SWCouponModel *model = self.dataArrat[indexPath.row];
        cell.model = model;
        if ([self.selectedID isEqual:model.couponID]) {
            cell.statusButton.selected = YES;
        } else {
            cell.statusButton.selected = NO;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.isDraw && self.block) {
        self.block(self.infoArray[indexPath.row]);
    }
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.showView.height - 60 - ShowDiff, _window_width, 60 + ShowDiff)];
        _bottomView.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
        UIButton *createButton = [UIButton buttonWithType:0];
        [createButton setTitle:@"不使用优惠券" forState:0];
        [createButton setBackgroundColor:normalColors];
        createButton.titleLabel.font = SYS_Font(14);
        createButton.layer.cornerRadius = 20;
        createButton.layer.masksToBounds = YES;
        [createButton addTarget:self action:@selector(doNoSelected) forControlEvents:UIControlEventTouchUpInside];
        createButton.frame = CGRectMake(15, 10, _window_width - 30, 40);
        [_bottomView addSubview:createButton];
    }
    return _bottomView;
}

- (void)doNoSelected{
    if (self.block) {
        self.block(@{});
    }
}
@end
