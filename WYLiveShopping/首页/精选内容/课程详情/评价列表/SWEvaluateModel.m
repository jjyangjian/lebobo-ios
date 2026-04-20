//
//  SWEvaluateModel.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWEvaluateModel.h"

@implementation SWEvaluateModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.user_nickname = minstr([dic valueForKey:@"nickname"]);
        self.avatar = minstr([dic valueForKey:@"avatar"]);
        self.content = minstr([dic valueForKey:@"content"]);
        self.star = minstr([dic valueForKey:@"star"]);
        self.add_time = minstr([dic valueForKey:@"add_time"]);
        self.des = minstr([dic valueForKey:@"des"]);

    }
    return self;
}

@end
