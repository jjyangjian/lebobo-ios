//
//  SWCartGoodsCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/29.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWCartGoodsCell.h"

@implementation SWCartGoodsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)selectBtnClick:(id)sender {
    _model.isSelected = !_model.isSelected;
    _selectButton.selected = _model.isSelected;
    [self.delegate changeSelectedState:_model.isSelected];
}
- (IBAction)addBtnClick:(id)sender {
    NSString *nums = [NSString stringWithFormat:@"%d",[_model.cart_num intValue] + 1];
    [self changecartNums:nums];
}
- (IBAction)delBtnClick:(id)sender {
    if ([_model.cart_num intValue] > 1) {
        NSString *nums = [NSString stringWithFormat:@"%d",[_model.cart_num intValue] - 1];
        [self changecartNums:nums];
    }

}
- (void)changecartNums:(NSString *)nums{
    [SWToolClass postNetworkWithUrl:@"cart/num" andParameter:@{@"id":_model.cart_id,@"number":nums} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            _model.cart_num = nums;
            [[NSNotificationCenter defaultCenter] postNotificationName:WYCarNumChange object:nil];
        }
        _numTextT.text = _model.cart_num;
        [self changeBtnState];
        [self.delegate changeSelectedState:_model.isSelected];
    } fail:^{
        
    }];
}

-(void)setModel:(SWCartModel *)model{
    _model = model;
    [_thumbImgView sd_setImageWithURL:[NSURL URLWithString:_model.image]];
    _nameLabel.text = _model.store_name;
    _sukLabel.text = [NSString stringWithFormat:@"属性：%@",_model.suk];
    _priceLabel.text = [NSString stringWithFormat:@"¥ %@",_model.price];
    _numTextT.text = _model.cart_num;
    _selectButton.selected = _model.isSelected;
}
- (void)changeBtnState{
    if ([_model.cart_num intValue] == 1) {
        _deleteButton.alpha = 0.5;
    }else{
        _deleteButton.alpha = 1;
        if ([_model.cart_num intValue] == [_model.stock intValue]) {
            _addButton.alpha = 0.5;
        }else{
            _addButton.alpha = 1;
        }
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self changecartNums:textField.text];
}
@end
