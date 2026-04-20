#import "JJHomeMerchantBackendModuleCell.h"

@interface JJHomeMerchantBackendModuleCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UILabel *merchantURLLabel;
@property (nonatomic, strong) UIButton *actionButton;

@end

@implementation JJHomeMerchantBackendModuleCell

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
    self.titleLabel.text = @"商家后台";
    [cardView addSubview:self.titleLabel];

    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.font = SYS_Font(13);
    self.tipsLabel.textColor = color64;
    self.tipsLabel.numberOfLines = 0;
    self.tipsLabel.text = @"发布商品 / 管理订单请前往 PC 端商家后台";
    [cardView addSubview:self.tipsLabel];

    self.merchantURLLabel = [[UILabel alloc] init];
    self.merchantURLLabel.font = SYS_Font(12);
    self.merchantURLLabel.textColor = color32;
    self.merchantURLLabel.numberOfLines = 0;
    [cardView addSubview:self.merchantURLLabel];

    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionButton.backgroundColor = JJAPPTHEMECOLOR;
    self.actionButton.layer.cornerRadius = 16;
    self.actionButton.layer.masksToBounds = YES;
    self.actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.actionButton setTitle:@"复制地址" forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.actionButton addTarget:self action:@selector(handleMerchantAction) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:self.actionButton];
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

    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
        make.left.equalTo(cardView).offset(15);
        make.right.equalTo(cardView).offset(-15);
    }];

    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipsLabel.mas_bottom).offset(12);
        make.right.equalTo(cardView).offset(-15);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(32);
        make.bottom.lessThanOrEqualTo(cardView).offset(-15);
    }];

    [self.merchantURLLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cardView).offset(15);
        make.centerY.equalTo(self.actionButton);
        make.right.equalTo(self.actionButton.mas_left).offset(-10);
        make.top.greaterThanOrEqualTo(self.tipsLabel.mas_bottom).offset(12);
        make.bottom.equalTo(cardView).offset(-15);
    }];
}

- (void)updateWithMerchantURL:(NSString *)merchantURL {
    self.merchantURLLabel.text = merchantURL;
}

- (void)handleMerchantAction {
    if (self.merchantBackendActionBlock) {
        self.merchantBackendActionBlock();
    }
}

@end
