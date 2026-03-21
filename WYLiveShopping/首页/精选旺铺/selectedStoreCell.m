//
//  selectedStoreCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/3.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "selectedStoreCell.h"

@implementation selectedStoreCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setSubDic:(NSDictionary *)subDic{
    _subDic = subDic;
    _nameL.text = minstr([_subDic valueForKey:@"nickname"]);
    _fansL.text = [NSString stringWithFormat:@"粉丝：%@",minstr([_subDic valueForKey:@"fans"])];
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:minstr([_subDic valueForKey:@"avatar"])]];
    if ([minstr([_subDic valueForKey:@"shoptype"]) isEqual:@"2"]) {
        _typeView.hidden = NO;
    }else{
        _typeView.hidden = YES;
    }
    NSArray *array = [subDic valueForKey:@"list"];
    for (UIImageView *imgV in _imageArray) {
        imgV.hidden = YES;
        imgV.backgroundColor = [UIColor clearColor];
    }
    for (int i = 0; i < (array.count>_imageArray.count ? _imageArray.count : array.count); i ++) {
        UIImageView *imgV = _imageArray[i];
        NSDictionary *dic = array[i];
        [imgV sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"image"])]];
        imgV.hidden = NO;
    }
}
@end
