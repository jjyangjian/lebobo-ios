//
//  SWAddressModel.m
//  YBEducation
//
//  Created by IOS1 on 2020/5/7.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWAddressModel.h"

@implementation SWAddressModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.aID = minstr([dic valueForKey:@"id"]);
        self.name = minstr([dic valueForKey:@"real_name"]);
        self.mobile = minstr([dic valueForKey:@"phone"]);
        self.province = minstr([dic valueForKey:@"province"]);
        self.city = minstr([dic valueForKey:@"city"]);
        self.area = minstr([dic valueForKey:@"district"]);
        self.detail = minstr([dic valueForKey:@"detail"]);
        self.isdef = minstr([dic valueForKey:@"is_default"]);
    }
    return self;
}
@end
