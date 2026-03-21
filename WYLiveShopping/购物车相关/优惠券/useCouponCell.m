//
//  useCouponCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/2.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "useCouponCell.h"

@implementation useCouponCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setModel:(couponModel *)model{
    _model = model;
    _moneyL.attributedText = [self getAttStr:_model.coupon_price];
    _conditionL.text = [NSString stringWithFormat:@"满%@元可用",_model.use_min_price];
    _nameL.text = _model.title;
    _timeL.text = [NSString stringWithFormat:@"%@%@",_model.end_time,_model.end_time.length<4?@"":@"到期"];
//    if (_model.isDraw) {
//        _lingquBtn.hidden = NO;
//        _statusBtn.hidden = YES;
//        if ([_model.is_use isEqual:@"1"]) {
//            _lingquBtn.selected = YES;
//            [_lingquBtn setBorderColor:RGB_COLOR(@"#d2d2d2", 1)];
//        }else{
//            _lingquBtn.selected = NO;
//            [_lingquBtn setBorderColor:normalColors];
//        }
//    }else{
//        _lingquBtn.hidden = YES;
//        _statusBtn.hidden = NO;
//    }
    switch ([_model.type intValue]) {
        case 0:
            _typeL.text = @"通用券";
            break;
        case 1:
            _typeL.text = @"品类券";
            break;
        case 2:
            _typeL.text = @"商品券";
            break;

        default:
            break;
    }

}
- (NSAttributedString *)getAttStr:(NSString *)nums{
    NSMutableAttributedString *mustr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"¥%@",nums]];
    [mustr setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13]} range:NSMakeRange(0, 1)];
    return mustr;
}
- (IBAction)doLingqu:(id)sender {
    if ([_model.is_use isEqual:@"1"]) {
        return;
    }
    [WYToolClass postNetworkWithUrl:@"coupon/receive" andParameter:@{@"couponId":_model.couponID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            _model.is_use = @"1";
            _lingquBtn.selected = YES;
            [_lingquBtn setBorderColor:RGB_COLOR(@"#d2d2d2", 1)];
        }
    } fail:^{
        
    }];
}

@end
