//
//  SWPromoterUserModel.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/3.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWPromoterUserModel.h"

@implementation SWPromoterUserModel
- (instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.uid = minstr([dic valueForKey:@"uid"]);
        self.nickname = minstr([dic valueForKey:@"nickname"]);
        self.avatar = minstr([dic valueForKey:@"avatar"]);
        self.time = minstr([dic valueForKey:@"time"]);
        self.childCount = minstr([dic valueForKey:@"childCount"]);
        self.orderCount = minstr([dic valueForKey:@"orderCount"]);
        self.numberCount = minstr([dic valueForKey:@"numberCount"]);
    }
    return self;
}
@end
