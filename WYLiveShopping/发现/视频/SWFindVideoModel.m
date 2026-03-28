//
//  SWFindVideoModel.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWFindVideoModel.h"

@implementation SWFindVideoModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        _videoid = minstr([dic valueForKey:@"id"]);
        _thumb = minstr([dic valueForKey:@"thumb"]);
        _goods = [dic valueForKey:@"goods"];
    }
    return self;
}

@end
