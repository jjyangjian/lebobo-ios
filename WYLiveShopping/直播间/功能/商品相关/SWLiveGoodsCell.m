//
//  SWLiveGoodsCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWLiveGoodsCell.h"

@implementation SWLiveGoodsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setModel:(SWLiveGoodsModel *)model{
    _model = model;
    [_thumbImageView sd_setImageWithURL:[NSURL URLWithString:_model.thumb]];
    _nameLabel.text = _model.name;
    _priceLabel.text = _model.price;
}
- (IBAction)xiajiaClick:(id)sender {
    if (self.delegate) {
        [self.delegate DismountGoods:_model];
    }
}

@end
