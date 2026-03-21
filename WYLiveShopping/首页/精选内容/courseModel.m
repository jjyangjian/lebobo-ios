//
//  courseModel.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/17.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "courseModel.h"

@implementation courseModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.user_nickname = minstr([dic valueForKey:@"user_nickname"]);
        self.avatar = minstr([dic valueForKey:@"avatar"]);
        self.userID = minstr([dic valueForKey:@"uid"]);
        self.type = minstr([dic valueForKey:@"type"]);
        self.courseID = minstr([dic valueForKey:@"id"]);
        self.sort = minstr([dic valueForKey:@"sort"]);
        self.thumb = minstr([dic valueForKey:@"thumb"]);
        self.courseName = minstr([dic valueForKey:@"name"]);
        self.paytype = minstr([dic valueForKey:@"paytype"]);
        self.payval = minstr([dic valueForKey:@"payval"]);
        self.lesson = minstr([dic valueForKey:@"lesson"]);
        self.islive = minstr([dic valueForKey:@"islive"]);
        self.ifbuy = minstr([dic valueForKey:@"isbuy"]);
        self.ismaterial = minstr([dic valueForKey:@"ismaterial"]);
        self.isSelected = [minstr([dic valueForKey:@"isselect"]) intValue];
        self.cartid = minstr([dic valueForKey:@"cartid"]);
        self.isvip = minstr([dic valueForKey:@"isvip"]);
        self.ifvip = minstr([dic valueForKey:@"ifvip"]);
        self.money_vip = minstr([dic valueForKey:@"money_vip"]);
        self.money = minstr([dic valueForKey:@"money"]);
        self.isseckill = minstr([dic valueForKey:@"isseckill"]);
        self.money_seckill = minstr([dic valueForKey:@"money_seckill"]);
        self.seckill_wait = [minstr([dic valueForKey:@"seckill_wait"]) intValue];
        self.seckill_ing = [minstr([dic valueForKey:@"seckill_ing"]) intValue];
        self.ispink = minstr([dic valueForKey:@"ispink"]);
        self.money_pink = minstr([dic valueForKey:@"money_pink"]);
        self.lessons = minstr([dic valueForKey:@"lessons"]);
        self.addTime = minstr([dic valueForKey:@"add_time"]);

    }
    return self;
}
@end
