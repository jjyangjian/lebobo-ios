//
//  SWCouponTableViewCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWCouponTableViewCell.h"
#import "SWStoreHomeTbabarViewController.h"
@implementation SWCouponTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)doStoreHome:(id)sender {
    SWStoreHomeTbabarViewController *vc = [[SWStoreHomeTbabarViewController alloc]initWithID:_model.mer_id];
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
- (IBAction)controlButtonClick:(id)sender {

    if ([_model.is_use isEqual:@"1"]) {
        if ([_controlBtn.titleLabel.text isEqual:@"删除"]) {
            [SWToolClass postNetworkWithUrl:@"couponsdel" andParameter:@{@"couponId":_model.couponID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                if (code == 200) {
                    if (self.block) {
                        self.block(_model);
                    }
                }
            } fail:^{
                
            }];

        }else{
            if (_isHome) {
                [self doStoreHome:nil];
            }
        }
    }else{
        [SWToolClass postNetworkWithUrl:@"coupon/receive" andParameter:@{@"couponId":_model.couponID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 200) {
                _model.is_use = @"1";
                _controlBtn.selected = YES;
            }
        } fail:^{
            
        }];
    }
}
-(void)setModel:(SWCouponModel *)model{
    _model = model;
    _moneyLabel.attributedText = [self getAttStr:_model.coupon_price];
    switch ([_model.type intValue]) {
        case 0:
            _typeLabel.text = @"通用券";
            break;
        case 1:
            _typeLabel.text = @"品类券";
            break;
        case 2:
            _typeLabel.text = @"商品券";
            break;

        default:
            break;
    }
    _typeTipsLabel.text = _model.title;
    
    _storeNameLabel.attributedText = [self getPicAndWord:_model.shop_name];
    _timeLabel.text = [NSString stringWithFormat:@"%@%@",_model.end_time,_model.end_time.length<4?@"":@"到期"];
    _fullLabel.text = [NSString stringWithFormat:@"满%@元可用",_model.use_min_price];
    _controlBtn.selected = [_model.is_use intValue];
//    _nameL.text = _model.title;
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
}
- (NSAttributedString *)getAttStr:(NSString *)nums{
    NSMutableAttributedString *mustr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"¥%@",nums]];
    [mustr setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10]} range:NSMakeRange(0, 1)];
    return mustr;
}
- (NSAttributedString *)getPicAndWord:(NSString *)str{
    NSMutableAttributedString *muArr;
    if ([_model.shoptype isEqual:@"2"]) {
        muArr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",str]];
        UIImage *image = [UIImage imageNamed:@"store-ziying"];
        NSTextAttachment *typeAttchment = [[NSTextAttachment alloc]init];
        typeAttchment.bounds = CGRectMake(1, -3, 24, 14);//设置frame
        typeAttchment.image = image;//设置图片
        NSAttributedString *typeString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(typeAttchment)];
        [muArr appendAttributedString:typeString];
    }else{
        muArr = [[NSMutableAttributedString alloc]initWithString:str];
    }
    return muArr;
}
@end
