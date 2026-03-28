//
//  SWHomeTeacherView.m
//  YBEducation
//
//  Created by IOS1 on 2020/2/28.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWHomeTeacherView.h"

@implementation SWHomeTeacherView
-(void)setModel:(SWTeacherModel *)model{
    _model = model;
    _backView.layer.shadowOpacity = 0.06;// 阴影透明度
    _backView.layer.shadowColor = [UIColor blackColor].CGColor;// 阴影的颜色
    _backView.layer.shadowRadius = 3;// 阴影扩散的范围控制
    _backView.layer.shadowOffset  = CGSizeMake(1, 1);// 阴影的范围
    _backView.clipsToBounds = NO;


    _nameLabel.text = _model.user_nickname;
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:_model.avatar]];
    if ([_model.identitys count] > 0) {
        _labelLabel.hidden = NO;
        _labelLabel.backgroundColor = RGB_COLOR(minstr([_model.identitys valueForKey:@"colour"]), 1);
        _labelLabel.text = minstr([_model.identitys valueForKey:@"name"]);
    }else{
        _labelLabel.hidden = YES;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
