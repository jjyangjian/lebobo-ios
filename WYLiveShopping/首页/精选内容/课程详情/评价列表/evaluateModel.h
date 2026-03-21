//
//  evaluateModel.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface evaluateModel : NSObject
@property (nonatomic,strong) NSString *user_nickname;
@property (nonatomic,strong) NSString *avatar;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *star;
@property (nonatomic,strong) NSString *add_time;
@property (nonatomic,strong) NSString *des;
@property (nonatomic,assign) BOOL iscourse;
-(instancetype)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
