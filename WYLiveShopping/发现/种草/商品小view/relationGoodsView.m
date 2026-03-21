//
//  relationGoodsView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/30.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "relationGoodsView.h"
#import "GoodsDetailsViewController.h"
@implementation relationGoodsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)buttonClick:(id)sender {
    GoodsDetailsViewController *vc = [[GoodsDetailsViewController alloc]init];
    vc.goodsID = minstr([_subDic valueForKey:@"id"]);
    if (_isLive) {
        vc.liveUid = minstr([_subDic valueForKey:@"uid"]);
    }else{
        vc.liveUid = @"";
    }
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

}
- (void)setSubDic:(NSDictionary *)subDic{
    _subDic = subDic;
    [_thumbImgView sd_setImageWithURL:[NSURL URLWithString:minstr([_subDic valueForKey:@"image"])]];
    _nameL.text = minstr([_subDic valueForKey:@"store_name"]);
    _priceL.text = [NSString stringWithFormat:@"¥%@",minstr([_subDic valueForKey:@"price"])];
}
@end
