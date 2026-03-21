//
//  LinkApplyCell.m
//  WYLiveShopping
//
//  Created by iyz on 2026/1/21.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import "LinkApplyCell.h"

@implementation LinkApplyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [_linkBtn setTitle:@"连麦" forState:0];
    [_linkBtn setTitleColor:normalColors forState:0];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setDataDic:(NSDictionary *)dataDic {
    _dataDic = dataDic;

    [_avatarIV sd_setImageWithURL:[NSURL URLWithString:minstr([_dataDic valueForKey:@"avatar"])]];
    _nameL.text = minstr([_dataDic valueForKey:@"nickname"]);

}

- (IBAction)clickLinkBtn:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(linkToUser:)]) {
        [_delegate linkToUser:_dataDic];
    }
}




@end
