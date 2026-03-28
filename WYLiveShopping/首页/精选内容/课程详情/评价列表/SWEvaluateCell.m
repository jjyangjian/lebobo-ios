//
//  SWEvaluateCell.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWEvaluateCell.h"

@implementation SWEvaluateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setModel:(SWEvaluateModel *)model{
    _model = model;
    [_starView setCurIndex:[_model.star intValue] andStartingDirectionLeft:NO];
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:_model.avatar]];
    _nameLabel.text = _model.user_nickname;
//    if (_model.iscourse) {
//        _numLabel.text = _model.des;
//    }else{
        _numLabel.text = @"";
//    }
    _contentLabel.text = _model.content;
    _timeLabel.text = _model.add_time;
}

@end
