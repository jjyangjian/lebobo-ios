//
//  rankUserCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "rankUserCell.h"

@implementation rankUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setModel:(rankUserModel *)model{
    _model = model;
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:_model.avatar]];
    _nameL.text = _model.nickname;
    _peopleL.text = [NSString stringWithFormat:@"%@人",_model.count];
}
-(void)setComModel:(commissionUserModel *)comModel{
    _comModel = comModel;
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:_comModel.avatar]];
    _nameL.text = _comModel.nickname;
    _peopleL.text = [NSString stringWithFormat:@"¥ %@",_comModel.brokerage_price];

}
@end
