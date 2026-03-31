#import "JJHomeShopOrderModuleCell.h"

@interface JJHomeShopOrderModuleCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIView *unshippedView;
@property (nonatomic, strong) UIView *receivedView;
@property (nonatomic, strong) UIView *evaluatedView;
@property (nonatomic, strong) UILabel *unshippedTitleLabel;
@property (nonatomic, strong) UILabel *receivedTitleLabel;
@property (nonatomic, strong) UILabel *evaluatedTitleLabel;
@property (nonatomic, strong) UILabel *unshippedValueLabel;
@property (nonatomic, strong) UILabel *receivedValueLabel;
@property (nonatomic, strong) UILabel *evaluatedValueLabel;

@end

@implementation JJHomeShopOrderModuleCell

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
    self.titleLabel.text = @"店铺订单";
    [cardView addSubview:self.titleLabel];

    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionButton.backgroundColor = JJAPPTHEMECOLOR;
    self.actionButton.layer.cornerRadius = 20;
    self.actionButton.layer.masksToBounds = YES;
    self.actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.actionButton setTitle:@"查看全部订单" forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.actionButton addTarget:self action:@selector(handleOrderAction) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:self.actionButton];

    self.unshippedView = [self createMetricView];
    self.receivedView = [self createMetricView];
    self.evaluatedView = [self createMetricView];
    [cardView addSubview:self.unshippedView];
    [cardView addSubview:self.receivedView];
    [cardView addSubview:self.evaluatedView];

    self.unshippedTitleLabel = [self createMetricTitleLabelWithText:@"待发货"];
    self.receivedTitleLabel = [self createMetricTitleLabelWithText:@"待收货"];
    self.evaluatedTitleLabel = [self createMetricTitleLabelWithText:@"待评价"];
    [self.unshippedView addSubview:self.unshippedTitleLabel];
    [self.receivedView addSubview:self.receivedTitleLabel];
    [self.evaluatedView addSubview:self.evaluatedTitleLabel];

    self.unshippedValueLabel = [self createMetricValueLabel];
    self.receivedValueLabel = [self createMetricValueLabel];
    self.evaluatedValueLabel = [self createMetricValueLabel];
    [self.unshippedView addSubview:self.unshippedValueLabel];
    [self.receivedView addSubview:self.receivedValueLabel];
    [self.evaluatedView addSubview:self.evaluatedValueLabel];
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

    [self.unshippedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.actionButton.mas_bottom).offset(15);
        make.left.equalTo(cardView).offset(15);
        make.height.mas_equalTo(56);
        make.bottom.equalTo(cardView).offset(-15);
    }];

    [self.receivedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.unshippedView.mas_right).offset(5);
        make.top.width.height.equalTo(self.unshippedView);
    }];

    [self.evaluatedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.receivedView.mas_right).offset(5);
        make.right.equalTo(cardView).offset(-15);
        make.top.width.height.equalTo(self.unshippedView);
    }];

    NSArray<UILabel *> *titleLabels = @[self.unshippedTitleLabel, self.receivedTitleLabel, self.evaluatedTitleLabel];
    NSArray<UILabel *> *valueLabels = @[self.unshippedValueLabel, self.receivedValueLabel, self.evaluatedValueLabel];
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
    label.text = @"0";
    return label;
}

- (void)updateWithUnshippedCount:(NSString *)unshippedCount
                   receivedCount:(NSString *)receivedCount
                  evaluatedCount:(NSString *)evaluatedCount {
    self.unshippedValueLabel.text = unshippedCount;
    self.receivedValueLabel.text = receivedCount;
    self.evaluatedValueLabel.text = evaluatedCount;
}

- (void)handleOrderAction {
    if (self.orderActionBlock) {
        self.orderActionBlock();
    }
}

@end
