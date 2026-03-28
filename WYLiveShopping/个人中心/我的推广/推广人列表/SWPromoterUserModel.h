//
//  SWPromoterUserModel.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/3.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWPromoterUserModel : NSObject
@property (nonatomic,strong) NSString *nickname;
@property (nonatomic,strong) NSString *avatar;
@property (nonatomic,strong) NSString *time;
@property (nonatomic,strong) NSString *childCount;
@property (nonatomic,strong) NSString *orderCount;
@property (nonatomic,strong) NSString *numberCount;
@property (nonatomic,strong) NSString *uid;
- (instancetype)initWithDic:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
