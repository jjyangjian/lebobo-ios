#import "JJHomeGoodsManagerModuleCell.h"

@interface JJHomeGoodsManagerModuleCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *actionButton;

@end

@implementation JJHomeGoodsManagerModuleCell

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
    self.titleLabel.text = @"商品管理";
    [cardView addSubview:self.titleLabel];

    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionButton.backgroundColor = JJAPPTHEMECOLOR;
    self.actionButton.layer.cornerRadius = 20;
    self.actionButton.layer.masksToBounds = YES;
    self.actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.actionButton setTitle:@"进入商品管理" forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.actionButton addTarget:self action:@selector(handleGoodsAction) forControlEvents:UIControlEventTouchUpInside];
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

    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
        make.left.equalTo(cardView).offset(15);
        make.right.equalTo(cardView).offset(-15);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(cardView).offset(-15);
    }];
}

- (void)handleGoodsAction {
    if (self.goodsManagerActionBlock) {
        self.goodsManagerActionBlock();
    }
}

@end
