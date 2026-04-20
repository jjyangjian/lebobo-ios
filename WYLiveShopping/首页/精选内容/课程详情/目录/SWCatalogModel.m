//
//  SWCatalogModel.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/25.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWCatalogModel.h"

@implementation SWCatalogModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.name = minstr([dic valueForKey:@"name"]);
        self.type = minstr([dic valueForKey:@"type"]);
        self.istrial = minstr([dic valueForKey:@"istrial"]);
        self.type = minstr([dic valueForKey:@"type"]);
        self.url = minstr([dic valueForKey:@"url"]);
        self.status = minstr([dic valueForKey:@"status"]);
        self.islive = minstr([dic valueForKey:@"islive"]);
        self.time_date = minstr([dic valueForKey:@"time_date"]);
        self.lessonID = minstr([dic valueForKey:@"id"]);
        self.des = minstr([dic valueForKey:@"des"]);
        self.liveuid = minstr([dic valueForKey:@"uid"]);
        self.courseid = minstr([dic valueForKey:@"courseid"]);
        self.isenter = minstr([dic valueForKey:@"isenter"]);
        self.islast = minstr([dic valueForKey:@"islast"]);

//        id userinfo = [dic valueForKey:@"userinfo"];
//        if ([userinfo isKindOfClass:[NSDictionary class]]) {
//            self.avatar_thumb = minstr([userinfo valueForKey:@"avatar"]);
//            self.user_nickname = minstr([userinfo valueForKey:@"user_nickname"]);
//        }
    }
    return self;
}

@end
