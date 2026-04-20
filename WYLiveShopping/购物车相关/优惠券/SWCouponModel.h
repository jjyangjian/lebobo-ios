//
//  SWCouponModel.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/2.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWCouponModel : NSObject
///优惠券编号
@property (nonatomic,strong) NSString *c_id;
///优惠券领取编号
@property (nonatomic,strong) NSString *couponID;
@property (nonatomic,strong) NSString *coupon_title;
@property (nonatomic,strong) NSString *coupon_price;
@property (nonatomic,strong) NSString *use_min_price;
@property (nonatomic,strong) NSString *add_time;
@property (nonatomic,strong) NSString *end_time;
@property (nonatomic,strong) NSString *use_time;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *is_use;
@property (nonatomic,strong) NSString *shop_name;
@property (nonatomic,strong) NSString *mer_id;
@property (nonatomic,strong) NSString *shoptype;

@property (nonatomic,assign) BOOL isDraw;

-(instancetype)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
