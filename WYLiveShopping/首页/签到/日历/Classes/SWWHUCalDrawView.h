//
//  SWWHUCalDrawView.h
//  Created by SuperNova on 16/4/3.
//  Copyright (c) 2015年 SuperNova(QQ:422596694). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWWHUCalendarCal.h"
#import "SWWHUCalendarItem.h"
typedef void (^SelectDateBlock) (SWWHUCalendarItem *item);
@interface SWWHUCalDrawView : UIView
@property(nonatomic,strong) UIColor* bgColor;
@property(nonatomic,strong) NSDictionary* dataDic;
@property(nonatomic,strong) NSDate* currentMonthDate;
@property(nonatomic,strong,readonly)  NSDate* selectedDate;//用户选择的日期.
@property(nonatomic,strong) void(^onDateSelectBlk)(NSDate* dateItem);
@property(nonatomic,strong) BOOL(^canSelectDate)(NSDate* dateItem);
@property(nonatomic,strong) NSString*(^tagStringOfDate)(NSArray* calMonth,NSArray* itemDate);
@property(nonatomic,strong) SWWHUCalendarCal* calcal;
@property (nonatomic,strong) SWWHUCalendarItem* selectedDateItem;
@property (nonatomic,copy) SelectDateBlock blockkkkkkkkk;
@property (nonatomic,assign) BOOL isSignIn;

-(void)reloadData;
@end
