//
//  SWHomeLiveCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/12.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWHomeLiveCell.h"

@implementation SWHomeLiveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setModel:(SWHomeLiveModel *)model{
    _model = model;
    [_thumbImgView sd_setImageWithURL:[NSURL URLWithString:_model.thumb]];
    _titleLabel.text = _model.titleStr;
    [_iconImgView sd_setImageWithURL:[NSURL URLWithString:_model.avatar]];
    _userNameLabel.text = _model.nickname;
    [_goodsThumbImgView sd_setImageWithURL:[NSURL URLWithString:_model.goods_img]];
    _goodsNumLabel.text = [NSString stringWithFormat:@"%@\n宝贝",_model.goodsnum];
    _lookNumsLabel.text = [NSString stringWithFormat:@"%@人观看",_model.nums];
    _likeNumsLabel.text = _model.likes;
}
@end
