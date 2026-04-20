//
//  SWCouponModel.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/2.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWCouponModel.h"

@implementation SWCouponModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.c_id = minstr([dic valueForKey:@"c_id"]);
        self.couponID = minstr([dic valueForKey:@"id"]);
        self.coupon_title = minstr([dic valueForKey:@"coupon_title"]);
        self.coupon_price = minstr([dic valueForKey:@"coupon_price"]);
        self.use_min_price = minstr([dic valueForKey:@"use_min_price"]);
        self.add_time = minstr([dic valueForKey:@"add_time"]);
        self.end_time = minstr([dic valueForKey:@"end_time"]);
        self.use_time = minstr([dic valueForKey:@"use_time"]);
        self.title = minstr([dic valueForKey:@"title"]);
        self.type = minstr([dic valueForKey:@"type"]);
        self.is_use = minstr([dic valueForKey:@"is_use"]);
        self.shop_name = minstr([dic valueForKey:@"shop_name"]);
        self.mer_id = minstr([dic valueForKey:@"mer_id"]);
        self.shoptype = minstr([dic valueForKey:@"shoptype"]);

    }
    return self;
}

@end
