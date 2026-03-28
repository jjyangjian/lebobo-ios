//
//  SWMineVideoCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWMineVideoCell.h"

@implementation SWMineVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setModel:(SWVideoModel *)model{
    _model = model;
    [_thumbImgV sd_setImageWithURL: [NSURL URLWithString:_model.videoImage]];
    _titleLabel.text = _model.videoTitle;
    [_titleLabel sizeToFit];
    _nameLabel.text = _model.userName;
    [_storeIconImgV sd_setImageWithURL:[NSURL URLWithString:_model.userAvatar]];
    [_looksBtn setTitle:[NSString stringWithFormat:@" %@",_model.views] forState:0];
}
@end
