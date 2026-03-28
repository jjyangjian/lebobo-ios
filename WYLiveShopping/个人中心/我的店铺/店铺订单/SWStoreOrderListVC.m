//
//  SWStoreOrderListVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWStoreOrderListVC.h"
#import "SWOrderDetailsVC.h"
#import "SWReturnOrderDetailsVC.h"
#import "JJOrderPendingPaymentListView.h"
#import "JJOrderPendingShipmentListView.h"
#import "JJOrderShippedListView.h"
#import "JJOrderReceivedListView.h"
#import "JJOrderCompletedListView.h"
#import "JJOrderRefundListView.h"

@interface SWStoreOrderListVC ()

@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) UIScrollView *headerScrollView;
@property (nonatomic, strong) UIStackView *headerStackView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) JJOrderPendingPaymentListView *pendingPaymentView;
@property (nonatomic, strong) JJOrderPendingShipmentListView *pendingShipmentView;
@property (nonatomic, strong) JJOrderShippedListView *shippedListView;
@property (nonatomic, strong) JJOrderReceivedListView *receivedListView;
@property (nonatomic, strong) JJOrderCompletedListView *completedListView;
@property (nonatomic, strong) JJOrderRefundListView *refundListView;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation SWStoreOrderListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.statusType isEqual:@"1"]) {
        self.titleL.text = @"代销订单";
    } else {
        self.titleL.text = @"店铺订单";
    }
    
    self.view.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
    self.buttonArray = [NSMutableArray array];
    self.selectedIndex = 0;
    
    [self configUI];
    [self requestCount];
    [self showOrderViewAtIndex:0 shouldRequest:YES];
}

- (void)configUI {
    {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.naviView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(50);
        }];
        
        {
            UIScrollView *scrollView = [[UIScrollView alloc] init];
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.alwaysBounceHorizontal = YES;
            [view addSubview:scrollView];
            [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(view);
            }];
            self.headerScrollView = scrollView;
        }
        
        {
            UIStackView *stackView = [[UIStackView alloc] init];
            stackView.axis = UILayoutConstraintAxisHorizontal;
            stackView.alignment = UIStackViewAlignmentFill;
            stackView.distribution = UIStackViewDistributionFill;
            stackView.spacing = 0;
            [self.headerScrollView addSubview:stackView];
            [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.headerScrollView);
                make.height.equalTo(self.headerScrollView);
            }];
            self.headerStackView = stackView;
        }
        
        NSArray *array = @[@"待付款 0", @"待发货 0", @"已发货 0", @"已收货 0", @"已完成 0", @"退款 0"];
        CGFloat buttonWidth = _window_width / 4.5;
        
        for (NSInteger i = 0; i < array.count; i++) {
            {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setTitle:array[i] forState:UIControlStateNormal];
                [btn setTitleColor:color96 forState:UIControlStateNormal];
                [btn setTitleColor:JJAPPTHEMECOLOR forState:UIControlStateSelected];
                btn.titleLabel.font = SYS_Font(15);
                btn.tag = 1000 + i;
                [btn addTarget:self action:@selector(typeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [self.headerStackView addArrangedSubview:btn];
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(buttonWidth);
                }];
                [self.buttonArray addObject:btn];
            }
        }
        
        [self updateSelectedButtonAtIndex:0];
    }
    
    {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.naviView.mas_bottom).offset(50);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
        self.contentView = view;
    }
    
    {
        JJOrderPendingPaymentListView *view = [[JJOrderPendingPaymentListView alloc] init];
        view.statusType = self.statusType;
        [self.contentView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        self.pendingPaymentView = view;
        view.hidden = YES;
        
        __weak typeof(self) weakSelf = self;
        view.selectBlock = ^(SWOrderModel *model) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf handleOrderSelect:model];
        };
        view.refreshBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf requestCount];
        };
    }
    
    {
        JJOrderPendingShipmentListView *view = [[JJOrderPendingShipmentListView alloc] init];
        view.statusType = self.statusType;
        [self.contentView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        self.pendingShipmentView = view;
        view.hidden = YES;
        
        __weak typeof(self) weakSelf = self;
        view.selectBlock = ^(SWOrderModel *model) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf handleOrderSelect:model];
        };
        view.refreshBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf requestCount];
        };
    }
    
    {
        JJOrderShippedListView *view = [[JJOrderShippedListView alloc] init];
        view.statusType = self.statusType;
        [self.contentView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        self.shippedListView = view;
        view.hidden = YES;
        
        __weak typeof(self) weakSelf = self;
        view.selectBlock = ^(SWOrderModel *model) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf handleOrderSelect:model];
        };
        view.refreshBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf requestCount];
        };
    }
    
    {
        JJOrderReceivedListView *view = [[JJOrderReceivedListView alloc] init];
        view.statusType = self.statusType;
        [self.contentView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        self.receivedListView = view;
        view.hidden = YES;
        
        __weak typeof(self) weakSelf = self;
        view.selectBlock = ^(SWOrderModel *model) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf handleOrderSelect:model];
        };
        view.refreshBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf requestCount];
        };
    }
    
    {
        JJOrderCompletedListView *view = [[JJOrderCompletedListView alloc] init];
        view.statusType = self.statusType;
        [self.contentView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        self.completedListView = view;
        view.hidden = YES;
        
        __weak typeof(self) weakSelf = self;
        view.selectBlock = ^(SWOrderModel *model) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf handleOrderSelect:model];
        };
        view.refreshBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf requestCount];
        };
    }
    
    {
        JJOrderRefundListView *view = [[JJOrderRefundListView alloc] init];
        view.statusType = self.statusType;
        [self.contentView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        self.refundListView = view;
        view.hidden = YES;
        
        __weak typeof(self) weakSelf = self;
        view.selectBlock = ^(SWOrderModel *model) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf handleOrderSelect:model];
        };
        view.refreshBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf requestCount];
        };
    }
}

- (void)typeBtnClick:(UIButton *)sender {
    NSInteger index = sender.tag - 1000;
    if (index < 0 || index >= self.buttonArray.count || sender.selected) {
        return;
    }
    [self showOrderViewAtIndex:index shouldRequest:YES];
}

- (void)showOrderViewAtIndex:(NSInteger)index shouldRequest:(BOOL)shouldRequest {
    self.selectedIndex = index;
    [self updateSelectedButtonAtIndex:index];
    
    self.pendingPaymentView.hidden = index != 0;
    self.pendingShipmentView.hidden = index != 1;
    self.shippedListView.hidden = index != 2;
    self.receivedListView.hidden = index != 3;
    self.completedListView.hidden = index != 4;
    self.refundListView.hidden = index != 5;
    
    if (shouldRequest) {
        switch (index) {
            case 0:
                [self.pendingPaymentView requestFirstPageData];
                break;
            case 1:
                [self.pendingShipmentView requestFirstPageData];
                break;
            case 2:
                [self.shippedListView requestFirstPageData];
                break;
            case 3:
                [self.receivedListView requestFirstPageData];
                break;
            case 4:
                [self.completedListView requestFirstPageData];
                break;
            case 5:
                [self.refundListView requestFirstPageData];
                break;
            default:
                break;
        }
    }
}

- (void)updateSelectedButtonAtIndex:(NSInteger)index {
    for (NSInteger i = 0; i < self.buttonArray.count; i++) {
        UIButton *btn = self.buttonArray[i];
        BOOL selected = i == index;
        btn.selected = selected;
        btn.titleLabel.font = selected ? SYS_Font(16) : SYS_Font(15);
    }
    
    if (index >= 0 && index < self.buttonArray.count) {
        UIButton *selectedButton = self.buttonArray[index];
        CGFloat minOffsetX = MAX(0, CGRectGetMidX(selectedButton.frame) - _window_width * 0.5);
        CGFloat maxOffsetX = MAX(0, self.headerScrollView.contentSize.width - _window_width);
        CGFloat targetOffsetX = MIN(minOffsetX, maxOffsetX);
        [self.headerScrollView setContentOffset:CGPointMake(targetOffsetX, 0) animated:YES];
    }
}

- (void)handleOrderSelect:(SWOrderModel *)model {
    [MBProgressHUD showMessage:@""];
    NSString *orderType = @"0";
    if (self.selectedIndex == 5) {
        orderType = @"-3";
    } else {
        orderType = [NSString stringWithFormat:@"%ld", (long)self.selectedIndex];
    }
    
    __weak typeof(self) weakSelf = self;
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"order/detail/%@?status=%@", model.orderNums, self.statusType] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        if (!strongSelf) return;
        
        if (code == 200) {
            if ([orderType isEqual:@"-3"]) {
                SWReturnOrderDetailsVC *vc = [[SWReturnOrderDetailsVC alloc] init];
                vc.orderMessage = info;
                [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
            } else {
                SWOrderDetailsVC *vc = [[SWOrderDetailsVC alloc] init];
                vc.orderMessage = info;
                vc.isCart = NO;
                vc.orderType = 1;
                [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
            }
        }
    } Fail:^{
        [MBProgressHUD hideHUD];
    }];
}

- (void)requestCount {
    __weak typeof(self) weakSelf = self;
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"order/data?status=%@", self.statusType] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (code == 200) {
            NSArray<NSString *> *titles = @[
                [NSString stringWithFormat:@"待付款 %@", minstr([info valueForKey:@"unpaid_count"])],
                [NSString stringWithFormat:@"待发货 %@", minstr([info valueForKey:@"unshipped_count"])],
                [NSString stringWithFormat:@"已发货 %@", minstr([info valueForKey:@"received_count"])],
                [NSString stringWithFormat:@"已收货 %@", minstr([info valueForKey:@"evaluated_count"])],
                [NSString stringWithFormat:@"已完成 %@", minstr([info valueForKey:@"complete_count"])],
                [NSString stringWithFormat:@"退款 %@", minstr([info valueForKey:@"refund_count"])]
            ];
            
            for (NSInteger i = 0; i < MIN(self.buttonArray.count, titles.count); i++) {
                UIButton *btn = self.buttonArray[i];
                [btn setTitle:titles[i] forState:UIControlStateNormal];
            }
        }
    } Fail:^{
        
    }];
}

@end
