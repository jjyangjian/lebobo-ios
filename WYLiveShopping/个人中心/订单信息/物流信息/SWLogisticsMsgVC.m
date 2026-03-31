//
//  SWLogisticsMsgVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/9.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWLogisticsMsgVC.h"
#import "SWRecommendView.h"
#import "SWHoverPageScrollView.h"
#import "SWCartModel.h"

@interface SWLogisticsMsgVC ()
@property (nonatomic, strong) UIView *logisticsView;
@property (nonatomic, strong) UIView *listMessageView;
@property (nonatomic, strong) SWHoverPageScrollView *backScrollView;
@property (nonatomic, strong) SWRecommendView *recommendV;

@end

@implementation SWLogisticsMsgVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"物流信息";
    [self.view addSubview:self.backScrollView];
    [self addSubViews];
    [self requestData];
}

- (SWHoverPageScrollView *)backScrollView{
    if (!_backScrollView) {
        _backScrollView = [[SWHoverPageScrollView alloc]init];
        _backScrollView.frame = CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight);
        _backScrollView.backgroundColor = [UIColor whiteColor];
        _backScrollView.bounces = NO;
        _backScrollView.contentSize = CGSizeMake(0, (_window_width-30) * 0.48 + 112 + _backScrollView.height);
        if (@available(iOS 11.0, *)){
            _backScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _backScrollView;
}

- (void)addSubViews{
    NSMutableArray *goodsArray = [NSMutableArray array];
    for (NSDictionary *dic in [self.orderMessage valueForKey:@"cartInfo"]) {
        SWCartModel *model = [[SWCartModel alloc]initWithDic:dic];
        [goodsArray addObject:model];
    }

    UIView *allGoodsView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, goodsArray.count * 80)];
    allGoodsView.backgroundColor = [UIColor whiteColor];
    [self.backScrollView addSubview:allGoodsView];
    for (int i = 0; i < goodsArray.count; i++) {
        SWCartModel *model = goodsArray[i];
        UIView *goodsView = [[UIView alloc]initWithFrame:CGRectMake(0, i * 80, _window_width, 80)];
        [allGoodsView addSubview:goodsView];
        UIImageView *thumbImgV = [[UIImageView alloc]init];
        thumbImgV.contentMode = UIViewContentModeScaleAspectFill;
        [thumbImgV sd_setImageWithURL:[NSURL URLWithString:model.image]];
        thumbImgV.layer.cornerRadius = 5;
        thumbImgV.layer.masksToBounds = YES;
        [goodsView addSubview:thumbImgV];
        [thumbImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(goodsView).offset(15);
            make.centerY.equalTo(goodsView);
            make.width.height.mas_equalTo(60);
        }];
        UILabel *pricelabel = [[UILabel alloc]init];
        pricelabel.text = [NSString stringWithFormat:@"¥%@",model.price];
        pricelabel.font = SYS_Font(14);
        pricelabel.textColor = color96;
        [goodsView addSubview:pricelabel];
        [pricelabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(goodsView).offset(-15);
            make.top.equalTo(thumbImgV).offset(2);
        }];

        UILabel *namelabel = [[UILabel alloc]init];
        namelabel.text = model.store_name;
        namelabel.font = SYS_Font(14);
        namelabel.textColor = color32;
        namelabel.numberOfLines = 2;
        [goodsView addSubview:namelabel];
        [namelabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(thumbImgV.mas_right).offset(8);
            make.top.equalTo(thumbImgV).offset(2);
            make.right.lessThanOrEqualTo(pricelabel.mas_left).offset(-10);
        }];
        UILabel *numsLabel = [[UILabel alloc]init];
        numsLabel.text = [NSString stringWithFormat:@"x%@",model.cart_num];
        numsLabel.font = SYS_Font(14);
        numsLabel.textColor = color96;
        [goodsView addSubview:numsLabel];
        [numsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(pricelabel);
            make.top.equalTo(pricelabel.mas_bottom).offset(8);
        }];
    }
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, allGoodsView.bottom, _window_width, 5) andColor:colorf0 andView:self.backScrollView];

    self.logisticsView = [[UIView alloc]initWithFrame:CGRectMake(0, allGoodsView.bottom + 5, _window_width, 60)];
    self.logisticsView.backgroundColor = [UIColor whiteColor];
    [self.backScrollView addSubview:self.logisticsView];
    UIImageView *imgV = [[UIImageView alloc]init];
    imgV.image = [UIImage imageNamed:@"物流"];
    [self.logisticsView addSubview:imgV];
    [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.logisticsView);
        make.left.equalTo(self.logisticsView).offset(15);
        make.height.width.mas_equalTo(24);
    }];
    UILabel *wuliuNamel = [[UILabel alloc]init];
    wuliuNamel.font = SYS_Font(14);
    wuliuNamel.textColor = color32;
    wuliuNamel.attributedText = [self getAttStr:[NSString stringWithFormat:@"物流公司：%@",minstr([self.orderMessage valueForKey:@"delivery_name"])]];
    [self.logisticsView addSubview:wuliuNamel];
    [wuliuNamel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgV.mas_right).offset(8);
        make.centerY.equalTo(imgV.mas_top);
    }];
    UILabel *wuliuNuml = [[UILabel alloc]init];
    wuliuNuml.textColor = color32;
    wuliuNuml.font = SYS_Font(14);
    wuliuNuml.attributedText = [self getAttStr:[NSString stringWithFormat:@"快递单号：%@",minstr([self.orderMessage valueForKey:@"delivery_id"])]];
    [self.logisticsView addSubview:wuliuNuml];
    [wuliuNuml mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgV.mas_right).offset(8);
        make.centerY.equalTo(imgV.mas_bottom);
    }];
    UIButton *copyBtn = [UIButton buttonWithType:0];
    [copyBtn setTitle:@"复制单号" forState:0];
    [copyBtn setTitleColor:color32 forState:0];
    copyBtn.titleLabel.font = SYS_Font(11);
    [copyBtn setBorderColor:color96];
    [copyBtn setBorderWidth:1];
    [copyBtn setCornerRadius:3];
    copyBtn.layer.masksToBounds = YES;
    [copyBtn addTarget:self action:@selector(doCopy) forControlEvents:UIControlEventTouchUpInside];
    [self.logisticsView addSubview:copyBtn];
    [copyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.logisticsView).offset(-15);
        make.centerY.equalTo(self.logisticsView);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(60);
    }];
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, self.logisticsView.bottom, _window_width, 5) andColor:colorf0 andView:self.backScrollView];

    [self.backScrollView addSubview:self.recommendV];
    self.backScrollView.contentSize = CGSizeMake(0, self.recommendV.bottom);
}

- (void)requestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"order/express/%@", minstr([self.orderMessage valueForKey:@"order_id"])] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            NSArray *list = [[[info valueForKey:@"express"] valueForKey:@"result"] valueForKey:@"list"];
            if (list.count > 0) {
                [self showLogisticsMessage:list];
            }
        }
    } Fail:^{

    }];
}

- (void)showLogisticsMessage:(NSArray *)list{
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, self.logisticsView.bottom, _window_width, 5) andColor:colorf0 andView:self.backScrollView];

    self.listMessageView = [[UIView alloc]init];
    self.listMessageView.backgroundColor = [UIColor whiteColor];
    [self.backScrollView addSubview:self.listMessageView];
    [self.listMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self.backScrollView);
        make.top.equalTo(self.logisticsView.mas_bottom).offset(5);
    }];

    MASViewAttribute *masTop = self.listMessageView.mas_top;
    for (int i = 0; i < list.count; i ++) {
        NSDictionary *dic = list[i];
        UIView *yuanView = [[UIView alloc]init];
        yuanView.layer.cornerRadius = 5;
        [self.listMessageView addSubview:yuanView];
        [yuanView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.listMessageView).offset(15);
            make.width.height.mas_equalTo(10);
            make.top.equalTo(masTop).offset(20);
        }];
        UILabel *titleL = [[UILabel alloc]init];
        titleL.font = SYS_Font(13);
        titleL.textColor = color32;
        titleL.numberOfLines = 0;
        titleL.text = minstr([dic valueForKey:@"status"]);
        [self.listMessageView addSubview:titleL];
        [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(yuanView.mas_right).offset(10);
            make.top.equalTo(yuanView);
            make.right.equalTo(self.listMessageView).offset(-15);
        }];
        UILabel *timeL = [[UILabel alloc]init];
        timeL.font = SYS_Font(11);
        timeL.textColor = color96;
        timeL.numberOfLines = 0;
        timeL.text = minstr([dic valueForKey:@"time"]);
        [self.listMessageView addSubview:timeL];
        [timeL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(titleL);
            make.top.equalTo(titleL.mas_bottom).offset(5);
        }];
        masTop = timeL.mas_bottom;
        UIView *lineView = [[UIView alloc]init];
        [self.listMessageView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(yuanView);
            make.top.equalTo(yuanView.mas_bottom);
            make.bottom.equalTo(masTop).offset(20);
            make.width.mas_equalTo(1);
        }];
        if (i == 0) {
            yuanView.backgroundColor = normalColors;
            titleL.textColor = normalColors;
            timeL.textColor = normalColors;
            lineView.backgroundColor = normalColors;
        }else{
            yuanView.backgroundColor = RGB_COLOR(@"#bfbfbf", 1);
            lineView.backgroundColor = RGB_COLOR(@"#dcdcdc", 1);
            titleL.textColor = color32;
            timeL.textColor = color96;
        }
        if (i == list.count - 1) {
            [self.listMessageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(lineView);
            }];
        }
    }
    [self.backScrollView layoutIfNeeded];

    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, self.logisticsView.bottom + self.listMessageView.height, _window_width, 5) andColor:colorf0 andView:self.backScrollView];
    self.recommendV.y = self.listMessageView.bottom + 5;
    self.backScrollView.contentSize = CGSizeMake(0, self.recommendV.bottom);
}

- (NSMutableAttributedString *)getAttStr:(NSString *)str{
    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc]initWithString:str];
    [muStr setAttributes:@{NSForegroundColorAttributeName:color96} range:NSMakeRange(0, 5)];
    return muStr;
}

- (SWRecommendView *)recommendV{
    if (!_recommendV) {
        _recommendV = [[SWRecommendView alloc]initWithFrame:CGRectMake(0, self.logisticsView.bottom + 5, _window_width, self.backScrollView.height) andNothingImage:nil];
    }
    return _recommendV;
}

- (void)doCopy{
    UIPasteboard *paste = [UIPasteboard generalPasteboard];
    paste.string = minstr([self.orderMessage valueForKey:@"delivery_id"]);
    [MBProgressHUD showError:@"复制成功"];
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
