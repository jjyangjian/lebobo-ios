#import "JJHomeShopRevenueModuleCell.h"

@interface JJHomeShopRevenueModuleCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIView *todayView;
@property (nonatomic, strong) UIView *totalView;
@property (nonatomic, strong) UIView *settledView;
@property (nonatomic, strong) UIView *unsettledView;
@property (nonatomic, strong) UILabel *todayTitleLabel;
@property (nonatomic, strong) UILabel *totalTitleLabel;
@property (nonatomic, strong) UILabel *settledTitleLabel;
@property (nonatomic, strong) UILabel *unsettledTitleLabel;
@property (nonatomic, strong) UILabel *todayValueLabel;
@property (nonatomic, strong) UILabel *totalValueLabel;
@property (nonatomic, strong) UILabel *settledValueLabel;
@property (nonatomic, strong) UILabel *unsettledValueLabel;

@end

@implementation JJHomeShopRevenueModuleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildUI];
        [self buildConstraints];
    }
    return self;
}

- (void)buildUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = RGB_COLOR(@"#F7F8FA", 1);
    self.contentView.backgroundColor = RGB_COLOR(@"#F7F8FA", 1);

    UIView *cardView = [[UIView alloc] init];
    cardView.backgroundColor = [UIColor whiteColor];
    cardView.layer.cornerRadius = 8;
    cardView.layer.masksToBounds = YES;
    cardView.tag = 100;
    [self.contentView addSubview:cardView];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textColor = color32;
    self.titleLabel.text = @"店铺收益";
    [cardView addSubview:self.titleLabel];

    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionButton.backgroundColor = JJAPPTHEMECOLOR;
    self.actionButton.layer.cornerRadius = 20;
    self.actionButton.layer.masksToBounds = YES;
    self.actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.actionButton setTitle:@"查看收益详情" forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.actionButton addTarget:self action:@selector(handleRevenueAction) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:self.actionButton];

    self.todayView = [self createMetricView];
    self.totalView = [self createMetricView];
    self.settledView = [self createMetricView];
    self.unsettledView = [self createMetricView];
    [cardView addSubview:self.todayView];
    [cardView addSubview:self.totalView];
    [cardView addSubview:self.settledView];
    [cardView addSubview:self.unsettledView];

    self.todayTitleLabel = [self createMetricTitleLabelWithText:@"今日收益"];
    self.totalTitleLabel = [self createMetricTitleLabelWithText:@"总收益"];
    self.settledTitleLabel = [self createMetricTitleLabelWithText:@"已结算"];
    self.unsettledTitleLabel = [self createMetricTitleLabelWithText:@"未结算"];
    [self.todayView addSubview:self.todayTitleLabel];
    [self.totalView addSubview:self.totalTitleLabel];
    [self.settledView addSubview:self.settledTitleLabel];
    [self.unsettledView addSubview:self.unsettledTitleLabel];

    self.todayValueLabel = [self createMetricValueLabel];
    self.totalValueLabel = [self createMetricValueLabel];
    self.settledValueLabel = [self createMetricValueLabel];
    self.unsettledValueLabel = [self createMetricValueLabel];
    [self.todayView addSubview:self.todayValueLabel];
    [self.totalView addSubview:self.totalValueLabel];
    [self.settledView addSubview:self.settledValueLabel];
    [self.unsettledView addSubview:self.unsettledValueLabel];
}

- (void)buildConstraints {
    UIView *cardView = [self.contentView viewWithTag:100];
    [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(15, 15, 0, 15));
        make.bottom.equalTo(self.contentView);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cardView).offset(15);
        make.left.equalTo(cardView).offset(15);
    }];

    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
        make.left.equalTo(cardView).offset(15);
        make.right.equalTo(cardView).offset(-15);
        make.height.mas_equalTo(40);
    }];

    [self.todayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.actionButton.mas_bottom).offset(15);
        make.left.equalTo(cardView).offset(15);
        make.height.mas_equalTo(58);
    }];

    [self.totalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.todayView.mas_right).offset(5);
        make.top.width.height.equalTo(self.todayView);
        make.right.equalTo(cardView).offset(-15);
    }];

    [self.settledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.todayView.mas_bottom).offset(8);
        make.left.equalTo(cardView).offset(15);
        make.width.height.equalTo(self.todayView);
        make.bottom.equalTo(cardView).offset(-15);
    }];

    [self.unsettledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.settledView.mas_right).offset(5);
        make.top.width.height.equalTo(self.settledView);
        make.right.equalTo(cardView).offset(-15);
    }];

    NSArray<UILabel *> *titleLabels = @[self.todayTitleLabel, self.totalTitleLabel, self.settledTitleLabel, self.unsettledTitleLabel];
    NSArray<UILabel *> *valueLabels = @[self.todayValueLabel, self.totalValueLabel, self.settledValueLabel, self.unsettledValueLabel];
    for (NSInteger index = 0; index < titleLabels.count; index++) {
        UILabel *titleLabel = titleLabels[index];
        UILabel *valueLabel = valueLabels[index];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.superview).offset(10);
            make.centerX.equalTo(titleLabel.superview);
        }];
        [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(6);
            make.centerX.equalTo(valueLabel.superview);
        }];
    }
}

- (UIView *)createMetricView {
    UIView *metricView = [[UIView alloc] init];
    metricView.backgroundColor = RGB_COLOR(@"#F7F8FA", 1);
    metricView.layer.cornerRadius = 8;
    metricView.layer.masksToBounds = YES;
    metricView.layer.borderWidth = 0.5;
    metricView.layer.borderColor = RGB_COLOR(@"#E8E8E8", 1).CGColor;
    return metricView;
}

- (UILabel *)createMetricTitleLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.font = SYS_Font(12);
    label.textColor = color64;
    label.text = text;
    return label;
}

- (UILabel *)createMetricValueLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:18];
    label.textColor = color32;
    label.text = @"0.00";
    return label;
}

- (void)updateWithTodayRevenue:(NSString *)todayRevenue
                  totalRevenue:(NSString *)totalRevenue
               settledRevenue:(NSString *)settledRevenue
             unsettledRevenue:(NSString *)unsettledRevenue {
    self.todayValueLabel.text = todayRevenue;
    self.totalValueLabel.text = totalRevenue;
    self.settledValueLabel.text = settledRevenue;
    self.unsettledValueLabel.text = unsettledRevenue;
}

- (void)handleRevenueAction {
    if (self.revenueActionBlock) {
        self.revenueActionBlock();
    }
}

@end
