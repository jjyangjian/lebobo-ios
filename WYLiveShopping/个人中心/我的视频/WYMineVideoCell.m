//
//  WYMineVideoCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYMineVideoCell.h"

@implementation WYMineVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setModel:(WYVideoModel *)model{
    _model = model;
    [_thumbImgV sd_setImageWithURL: [NSURL URLWithString:_model.videoImage]];
    _titleL.text = _model.videoTitle;
    [_titleL sizeToFit];
    _nameL.text = _model.userName;
    [_storeIconImgV sd_setImageWithURL:[NSURL URLWithString:_model.userAvatar]];
    [_looksBtn setTitle:[NSString stringWithFormat:@" %@",_model.views] forState:0];
}
@end
