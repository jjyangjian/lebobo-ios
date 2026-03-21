//
//  optimizationModel.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/17.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "optimizationModel.h"

@implementation optimizationModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.thumb = minstr([dic valueForKey:@"image"]);
        self.name = minstr([dic valueForKey:@"store_name"]);
        self.goodsID = minstr([dic valueForKey:@"id"]);
        self.price = minstr([dic valueForKey:@"price"]);
        self.cate_id = minstr([dic valueForKey:@"cate_id"]);
        self.sales = minstr([dic valueForKey:@"sales"]);
        self.unit_name = minstr([dic valueForKey:@"unit_name"]);
        self.vip_price = minstr([dic valueForKey:@"vip_price"]);
        self.activity = [dic valueForKey:@"activity"];
    }
    return self;
}

@end
