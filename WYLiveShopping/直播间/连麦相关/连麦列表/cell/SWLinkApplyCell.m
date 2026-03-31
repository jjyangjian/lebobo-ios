//
//  SWLinkApplyCell.m
//  WYLiveShopping
//
//  Created by iyz on 2026/1/21.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import "SWLinkApplyCell.h"

@implementation SWLinkApplyCell

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


- (void)setDataMap:(NSDictionary *)dataMap {
    _dataMap = dataMap;

    [_avatarIV sd_setImageWithURL:[NSURL URLWithString:minstr([_dataMap valueForKey:@"avatar"])]];
    _nameL.text = minstr([_dataMap valueForKey:@"nickname"]);

}

- (IBAction)clickLinkBtn:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(linkToUser:)]) {
        [_delegate linkToUser:_dataMap];
    }
}




@end
