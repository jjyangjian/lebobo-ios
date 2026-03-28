//
//  SWWHUCalendarItem.m
//  TEST_Calendar
//
//  Created by SuperNova(QQ:422596694) on 15/11/5.
//  Copyright (c) 2015年 SuperNova(QQ:422596694). All rights reserved.
//

#import "SWWHUCalendarItem.h"

@implementation SWWHUCalendarItem
-(BOOL)isEqual:(SWWHUCalendarItem*)object{
    return [object.dateStr isEqualToString:self.dateStr];
}

-(NSUInteger) hash{
    return [_dateStr hash];
}
@end
