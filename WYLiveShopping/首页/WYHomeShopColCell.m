//
//  WYHomeShopColCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/17.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "WYHomeShopColCell.h"
#import <Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface WYHomeShopColCell ()
@property (nonatomic, strong) UIImageView *thumbImgView;
@property (nonatomic, strong) UILabel *nameL;
@property (nonatomic, strong) UILabel *priceL;
@end

@implementation WYHomeShopColCell

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
    
    UILabel *nameL = [[UILabel alloc] init];
    nameL.font = [UIFont systemFontOfSize:13];
    nameL.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    nameL.numberOfLines = 2;
    [self.contentView addSubview:nameL];
    self.nameL = nameL;
    
    UILabel *priceL = [[UILabel alloc] init];
    priceL.font = [UIFont boldSystemFontOfSize:15];
    priceL.textColor = [UIColor redColor];
    [self.contentView addSubview:priceL];
    self.priceL = priceL;
    
    [thumbImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(self.contentView.mas_width).multipliedBy(8.0/5.0);
    }];
    
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(thumbImgView.mas_bottom).offset(8);
        make.left.right.equalTo(self.contentView).inset(8);
    }];
    
    [priceL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameL.mas_bottom).offset(4);
        make.left.right.equalTo(self.contentView).inset(8);
        make.bottom.lessThanOrEqualTo(self.contentView).offset(-8);
    }];
}

- (void)setModel:(liveGoodsModel *)model {
    _model = model;
    
    [self.thumbImgView sd_setImageWithURL:[NSURL URLWithString:model.thumb] placeholderImage:nil];
    self.nameL.text = model.name;
    self.priceL.text = [NSString stringWithFormat:@"¥%@", model.price];
}

@end