//
//  SWReturnOrderCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWReturnOrderCell.h"

@implementation SWReturnOrderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setModel:(SWCartModel *)model{
    _model = model;
    [_thumbImgView sd_setImageWithURL:[NSURL URLWithString:_model.image]];
    _nameL.text = _model.store_name;
    _sukL.text = [NSString stringWithFormat:@"%@",_model.suk];
    _priceL.text = [NSString stringWithFormat:@"¥%@",_model.price];
    _numsL.text = [NSString stringWithFormat:@"x%@",_model.cart_num];
}

@end
