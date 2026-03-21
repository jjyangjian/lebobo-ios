//
//  OptimizationCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/17.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "OptimizationCell.h"
#import "SubmitOrderViewController.h"
@implementation OptimizationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)shareBuyButtonClick:(id)sender {
    [MBProgressHUD showMessage:@""];
    //new 0:加入购物车 1:立即购买的时候加入购物车
    NSDictionary *dic = @{
        @"productId":_model.goodsID,
        @"cartNum": @"1",
        @"uniqueId":@"",
        @"new":@"1"
    };
    [WYToolClass postNetworkWithUrl:@"cart/add" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [self doBuyAndPayView:minstr([info valueForKey:@"cartId"])];
        }
    } fail:^{
        
    }];

}
- (void)doBuyAndPayView:(NSString *)cartID{
    [WYToolClass postNetworkWithUrl:@"order/confirm" andParameter:@{@"cartId":cartID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [MBProgressHUD hideHUD];
            SubmitOrderViewController *vc = [[SubmitOrderViewController alloc]init];
            vc.orderMessage = [info mutableCopy];
            vc.liveUid = @"";
            [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
        }
    } fail:^{
        
    }];

}

- (void)setModel:(optimizationModel *)model{
    _model = model;
    [_thumbImgView sd_setImageWithURL:[NSURL URLWithString:_model.thumb]];
    _nameL.attributedText = [self setTextSpeace:_model.name];
    _priceLabel.text = _model.price;
    _salesL.text = [NSString stringWithFormat:@"%@人已买",_model.sales];
}
- (NSAttributedString *)setTextSpeace:(NSString *)str{
    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc]initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];        //设置行间距
    [muStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [muStr length])];

    return muStr;
}
@end
