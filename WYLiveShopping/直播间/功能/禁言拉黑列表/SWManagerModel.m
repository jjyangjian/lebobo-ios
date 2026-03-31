//
//  SWManagerModel.m
//  iphoneLive
//
//  Created by cat on 16/4/1.
//  Copyright © 2016年 cat. All rights reserved.
//
#import "SWManagerModel.h"
@implementation SWManagerModel
-(instancetype)initWithDictionary:(NSDictionary *)map{
    self = [super init];
    if (self) {
        self.time = [NSString stringWithFormat:@"%@",[map valueForKey:@"end_time"]];
        self.name = minstr(map[@"nickname"]);
        self.stream = minstr(map[@"stream"]);
       
        self.icon = [NSString stringWithFormat:@"%@",[map valueForKey:@"avatar"]];
        self.uid = [NSString stringWithFormat:@"%@",[map valueForKey:@"uid"]];
        self.isattention = [NSString stringWithFormat:@"%@",[map valueForKey:@"isattention"]];
        
       
        
    }
    return self;
}
+(instancetype)modelWithDictionary:(NSDictionary *)map{
    return  [[self alloc]initWithDictionary:map];
}
@end
