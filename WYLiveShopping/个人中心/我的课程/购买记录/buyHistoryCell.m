//
//  buyHistoryCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/11.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "buyHistoryCell.h"

@implementation buyHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setModel:(courseModel *)model{
    _model = model;
    [_thumbImgV sd_setImageWithURL:[NSURL URLWithString:_model.thumb]];
    _nameL.text = _model.courseName;
    _contentL.text = _model.lessons;
    _timeL.text = _model.addTime;

    _priceL.attributedText = [self getATTStr];
}
- (NSAttributedString *)getATTStr{
    NSMutableAttributedString *muAtt = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"¥%@",_model.payval]];
    [muAtt addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(0, 1)];
    return muAtt;
}

@end
