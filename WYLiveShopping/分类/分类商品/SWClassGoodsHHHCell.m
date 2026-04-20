//
//  SWClassGoodsHHHCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/23.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWClassGoodsHHHCell.h"

@implementation SWClassGoodsHHHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setModel:(SWLiveGoodsModel *)model{
    _model = model;
    [_thumbImgV sd_setImageWithURL:[NSURL URLWithString:_model.thumb]];
    _titleLabel.text = _model.name;
    _salesLabel.text = [NSString stringWithFormat:@"已售%@件",_model.sales];
    if (model.vip_price.length > 0) {
        _priceLabel.hidden = NO;
        _vipImgV.hidden = NO;
        _vipPriceLabel.font = [UIFont boldSystemFontOfSize:15];
        _vipPriceLabel.textColor = color32;
        _vipPriceLabel.text = [NSString stringWithFormat:@"¥%@",_model.vip_price];
        _priceLabel.text = [NSString stringWithFormat:@"¥%@",_model.price];

    }else{
        _priceLabel.text = @"";
        _priceLabel.hidden = YES;
        _vipImgV.hidden = YES;
        _vipPriceLabel.font = [UIFont boldSystemFontOfSize:17];
        _vipPriceLabel.textColor = normalColors;
        _vipPriceLabel.text = [NSString stringWithFormat:@"¥%@",_model.price];
    }
}

@end
