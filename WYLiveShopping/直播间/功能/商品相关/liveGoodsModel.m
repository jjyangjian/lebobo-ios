//
//  liveGoodsModel.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "liveGoodsModel.h"

@implementation liveGoodsModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.thumb = minstr([dic valueForKey:@"image"]);
        self.name = minstr([dic valueForKey:@"store_name"]);
        self.goodsID = minstr([dic valueForKey:@"id"]);
        self.price = minstr([dic valueForKey:@"price"]);
        self.is_sale = minstr([dic valueForKey:@"is_sale"]);
        self.sales = minstr([dic valueForKey:@"sales"]);
        self.salenums = minstr([dic valueForKey:@"salenums"]);
        self.bring_price = minstr([dic valueForKey:@"bring_price"]);
        if ([dic valueForKey:@"vip_price"]) {
            self.vip_price = minstr([dic valueForKey:@"vip_price"]);
        }else{
            self.vip_price = @"";
        }
        CGFloat wwww = [[WYToolClass sharedInstance] widthOfString:self.name andFont:SYS_Font(14) andHeight:20];
        if (wwww < (_window_width-30)/2 -16) {
            _isDouble = NO;
        }else{
            _isDouble = YES;
        }
    }
    return self;
}

@end
