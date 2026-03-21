//
//  commissionUserModel.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface commissionUserModel : NSObject
@property (nonatomic,strong) NSString *nickname;
@property (nonatomic,strong) NSString *avatar;
@property (nonatomic,strong) NSString *brokerage_price;
@property (nonatomic,strong) NSString *uid;
- (instancetype)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
