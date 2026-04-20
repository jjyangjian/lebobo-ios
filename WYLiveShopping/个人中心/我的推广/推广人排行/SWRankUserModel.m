//
//  SWRankUserModel.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWRankUserModel.h"

@implementation SWRankUserModel
- (instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.uid = minstr([dic valueForKey:@"uid"]);
        self.nickname = minstr([dic valueForKey:@"nickname"]);
        self.avatar = minstr([dic valueForKey:@"avatar"]);
        self.count = minstr([dic valueForKey:@"count"]);
    }
    return self;
}

@end
