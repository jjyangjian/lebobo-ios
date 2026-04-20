//
//  SWTeacherModel.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/2.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWTeacherModel : NSObject
-(instancetype)initWithDic:(NSDictionary *)dic;
@property (nonatomic,strong) NSString *user_nickname;
@property (nonatomic,strong) NSString *avatar;
@property (nonatomic,strong) NSString *sex;
@property (nonatomic,strong) NSDictionary *identitys;//身份标识
@property (nonatomic,strong) NSString *userID;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *isattent;
@property (nonatomic,strong) NSString *signature;
@property (nonatomic,strong) NSString *experience;
@end

NS_ASSUME_NONNULL_END
