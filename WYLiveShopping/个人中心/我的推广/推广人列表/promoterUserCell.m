//
//  promoterUserCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/3.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "promoterUserCell.h"

@implementation promoterUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setModel:(promoterUserModel *)model{
    _model = model;
    [_iconimgV sd_setImageWithURL:[NSURL URLWithString:_model.avatar]];
    _nameL.text = _model.nickname;
    _timeL.text = _model.time;
    _numsL.attributedText = [self setAttText:_model.childCount];
    _numsL.textAlignment = NSTextAlignmentRight;
}
- (NSAttributedString *)setAttText:(NSString *)nums{
    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@人\n%@单\n%@元",_model.childCount,_model.orderCount,_model.numberCount]];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 3;

    [muStr addAttributes:@{NSForegroundColorAttributeName:normalColors} range:NSMakeRange(0, nums.length)];
    [muStr addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, muStr.length)];
    return muStr;
}

@end
