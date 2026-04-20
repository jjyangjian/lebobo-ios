//
//  SWFindVideoCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWFindVideoCell.h"
#import "SWGoodsDetailsViewController.h"
@implementation SWFindVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)buttonCLick:(id)sender {
    NSDictionary *dic = [_model.goods firstObject];
    SWGoodsDetailsViewController *vc = [[SWGoodsDetailsViewController alloc]init];
    vc.goodsID = minstr([dic valueForKey:@"id"]);
    vc.liveUid = _model.userUid;
    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

}
- (void)setModel:(SWVideoModel *)model{
    _model = model;
    [_thumbImgV sd_setImageWithURL:[NSURL URLWithString:_model.videoImage]];
    _vDesL.text = _model.videoTitle;
    [_vDesL sizeToFit];
    if (_model.goods.count > 0) {
        _goodsView.hidden = NO;
        NSDictionary *dic = [_model.goods firstObject];
        [_thumbImgView sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"image"])]];
        _nameL.text = minstr([dic valueForKey:@"store_name"]);
        _priceL.text = [NSString stringWithFormat:@"¥%@",minstr([dic valueForKey:@"price"])];

    }else{
        _goodsView.hidden = YES;
    }
}
@end
