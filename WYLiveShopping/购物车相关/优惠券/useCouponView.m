//
//  useCouponView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/2.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "useCouponView.h"
#import "useCouponCell.h"
#import "cartModel.h"
#import "WYCouponTableViewCell.h"
@interface useCouponView()<UITableViewDelegate,UITableViewDataSource>{
    UIView *showView;
    BOOL isDraw;
    NSString *selectedID;
    NSString *minPrice;
    NSDictionary *cart_msg;

}
@property (nonatomic,strong) UITableView *couponTbaleView;
@property (nonatomic,strong) NSMutableArray *dataArrat;
@property (nonatomic,strong) NSArray *infoArray;

@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UIImageView *nothingImgView;

@end
@implementation useCouponView
- (void)doHide{
    [UIView animateWithDuration:0.3 animations:^{
        showView.y = _window_height;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        if (!isDraw) {
            self.block(nil);
        }
    }];
}
- (instancetype)initWithCouponID:(NSString *)sid andIsDraw:(BOOL)isd andUsePrice:(NSString *)price andCart:(NSDictionary *)cart{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, _window_width, _window_height);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _dataArrat = [NSMutableArray array];
        isDraw = isd;
        selectedID = sid;
        minPrice = price;
        cart_msg = cart;
        [self creatUI];
        [self requestData];
    }
    return self;
}
- (void)requestData{
    NSString *url;
    if (isDraw) {
        url = [NSString stringWithFormat:@"coupons?type=1&product_id=%@",selectedID];
    }else{
        NSString *cartids = @"";
        for (cartModel *model in [cart_msg valueForKey:@"model"]) {
            if (cartids.length == 0) {
                cartids = model.cart_id;
            }else{
                cartids = [NSString stringWithFormat:@"%@,%@",cartids,model.cart_id];
            }
        }
        url = [NSString stringWithFormat:@"coupons/order/%@?mer_id=%@&cartId=%@",minPrice,minstr([cart_msg valueForKey:@"mer_id"]),cartids];
    }
    [WYToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            _infoArray = info;
            for (NSDictionary *dic in _infoArray) {
                couponModel *model = [[couponModel alloc]initWithDic:dic];
                model.isDraw = isDraw;
                [_dataArrat addObject:model];
            }
            
            [_couponTbaleView reloadData];
            if (_dataArrat.count == 0) {
                _bottomView.hidden = YES;
                _nothingImgView.hidden = NO;
            }
        }
    } Fail:^{
        
    }];
}
- (void)creatUI{
    UIButton *hideBtn = [UIButton buttonWithType:0];
    hideBtn.frame = CGRectMake(0, 0, _window_width, _window_height-_window_width-ShowDiff);
    [hideBtn addTarget:self action:@selector(doHide) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:hideBtn];
    showView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, _window_width+ShowDiff)];
    showView.backgroundColor = RGB_COLOR(@"#F5F5F5", 1);
    [self addSubview:showView];
    showView.layer.mask = [[WYToolClass sharedInstance] setViewLeftTop:10 andRightTop:10 andView:showView];
    UILabel *titleL = [[UILabel alloc]init];
    titleL.text = @"优惠券";
    titleL.textColor = color32;
    titleL.font = SYS_Font(16);
    [showView addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(showView);
        make.centerY.equalTo(showView.mas_top).offset(28);
    }];
    UIButton *closeBtn = [UIButton buttonWithType:0];
    [closeBtn setImage:[UIImage imageNamed:@"userMsg_close"] forState:0];
    [closeBtn addTarget:self action:@selector(doHide) forControlEvents:UIControlEventTouchUpInside];
    [showView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.right.equalTo(showView).offset(-10);
        make.centerY.equalTo(titleL);
    }];
    [showView addSubview:self.couponTbaleView];
    if (isDraw) {
        _couponTbaleView.height = showView.height-55-ShowDiff;
    }else{
        [showView addSubview:self.bottomView];
    }
    
    [self show];
}
- (void)show{
    self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        showView.y = _window_height-_window_width-ShowDiff;
    }];
}
- (UITableView *)couponTbaleView{
    if (!_couponTbaleView) {
        _couponTbaleView = [[UITableView alloc]initWithFrame:CGRectMake(0, 55, _window_width, showView.height-55-60-ShowDiff) style:0];
        _couponTbaleView.delegate = self;
        _couponTbaleView.dataSource = self;
        _couponTbaleView.separatorStyle = 0;
        _couponTbaleView.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
        [_couponTbaleView addSubview:self.nothingImgView];
    }
    return _couponTbaleView;
}
-(UIImageView *)nothingImgView{
    if (!_nothingImgView) {
        _nothingImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, _window_width, _window_width*0.55)];
        _nothingImgView.image = [UIImage imageNamed:@"noCoupon"];
        _nothingImgView.contentMode = UIViewContentModeScaleAspectFit;
        _nothingImgView.hidden = YES;
    }
    return _nothingImgView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArrat.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isDraw) {
        WYCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WYCouponTableViewCELL"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WYCouponTableViewCell" owner:nil options:nil] lastObject];
            cell.isHome = NO;
            [cell.controlBtn setTitle:@"已领取" forState:UIControlStateSelected];
            [cell.controlBtn setBackgroundImage:[WYToolClass getImgWithColor:[UIColor clearColor]] forState:UIControlStateSelected];
            [cell.controlBtn setBackgroundImage:[WYToolClass getImgWithColor:[UIColor whiteColor]] forState:0];
            [cell.controlBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

        }
        cell.model = _dataArrat[indexPath.row];
        return cell;

    }else{
        useCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:@"useCouponCELL"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"useCouponCell" owner:nil options:nil] lastObject];
        }
        couponModel *model = _dataArrat[indexPath.row];
        cell.model = model;
        if (!isDraw) {
            if ([selectedID isEqual:model.couponID]) {
                cell.statusBtn.selected = YES;
            }else{
                cell.statusBtn.selected = NO;
            }
        }
        return cell;
    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!isDraw) {
        if (self.block) {
            self.block(_infoArray[indexPath.row]);
        }
    }
}

-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, showView.height-60-ShowDiff, _window_width, 60+ShowDiff)];
        _bottomView.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
        UIButton *creatButton = [UIButton buttonWithType:0];
        [creatButton setTitle:@"不使用优惠券" forState:0];
        [creatButton setBackgroundColor:normalColors];
        creatButton.titleLabel.font = SYS_Font(14);
        creatButton.layer.cornerRadius = 20;
        creatButton.layer.masksToBounds = YES;
        [creatButton addTarget:self action:@selector(doNoSelected) forControlEvents:UIControlEventTouchUpInside];
        creatButton.frame = CGRectMake(15, 10, _window_width-30, 40);
        [_bottomView addSubview:creatButton];
    }
    return _bottomView;
}
- (void)doNoSelected{
    if (self.block) {
        self.block(@{});
    }
}
@end
