//
//  WYHomeShopColCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/31.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYHomeShopColCell.h"

@implementation WYHomeShopColCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setModel:(liveGoodsModel *)model{
    _model = model;
    _nameL.text = _model.name;
    [_thumbImgView sd_setImageWithURL:[NSURL URLWithString:_model.thumb]];
    _priceL.text = [NSString stringWithFormat:@"¥%@",_model.price];
    _salesL.text = [NSString stringWithFormat:@"已售%@件",_model.sales];

}
@end
