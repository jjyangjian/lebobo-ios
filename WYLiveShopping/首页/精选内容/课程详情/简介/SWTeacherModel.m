//
//  SWTeacherModel.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/2.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWTeacherModel.h"

@implementation SWTeacherModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.user_nickname = minstr([dic valueForKey:@"user_nickname"]);
        self.avatar = minstr([dic valueForKey:@"avatar"]);
        self.sex = minstr([dic valueForKey:@"sex"]);
        self.userID = minstr([dic valueForKey:@"id"]);
        self.type = minstr([dic valueForKey:@"type"]);
        self.isattent = minstr([dic valueForKey:@"isattent"]);
        self.experience = minstr([dic valueForKey:@"experience"]);
        id ident = [dic valueForKey:@"identitys"];
        if ([ident isKindOfClass:[NSArray class]] && [ident count] > 0) {
            self.identitys = [ident firstObject];
        }else{
            self.identitys = @{};
        }
    }
    return self;
}

@end
