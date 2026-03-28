//
//  SWHomeShopColCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/17.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWHomeShopColCell.h"
#import <Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface SWHomeShopColCell ()
@property (nonatomic, strong) UIImageView *thumbImgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@end

@implementation SWHomeShopColCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UIImageView *thumbImgView = [[UIImageView alloc] init];
    thumbImgView.contentMode = UIViewContentModeScaleAspectFill;
    thumbImgView.clipsToBounds = YES;
    thumbImgView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:thumbImgView];
    self.thumbImgView = thumbImgView;
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont systemFontOfSize:13];
    nameLabel.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    nameLabel.numberOfLines = 2;
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    UILabel *priceLabel = [[UILabel alloc] init];
    priceLabel.font = [UIFont boldSystemFontOfSize:15];
    priceLabel.textColor = [UIColor redColor];
    [self.contentView addSubview:priceLabel];
    self.priceLabel = priceLabel;
    
    [thumbImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(self.contentView.mas_width).multipliedBy(8.0/5.0);
    }];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(thumbImgView.mas_bottom).offset(8);
        make.left.right.equalTo(self.contentView).inset(8);
    }];
    
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(4);
        make.left.right.equalTo(self.contentView).inset(8);
        make.bottom.lessThanOrEqualTo(self.contentView).offset(-8);
    }];
}

- (void)setModel:(SWLiveGoodsModel *)model {
    _model = model;
    
    [self.thumbImgView sd_setImageWithURL:[NSURL URLWithString:model.thumb] placeholderImage:nil];
    self.nameLabel.text = model.name;
    self.priceLabel.text = [NSString stringWithFormat:@"¥%@", model.price];
}

@end
