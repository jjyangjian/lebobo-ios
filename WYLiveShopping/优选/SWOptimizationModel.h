//
//  SWOptimizationModel.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/17.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWOptimizationModel : NSObject
@property (nonatomic,strong) NSString *thumb;
@property (nonatomic,strong) NSString *goodsID;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *price;
@property (nonatomic,strong) NSString *cate_id;
@property (nonatomic,strong) NSString *sales;
@property (nonatomic,strong) NSString *unit_name;
@property (nonatomic,strong) NSString *vip_price;
@property (nonatomic,strong) NSArray *activity;


-(instancetype)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
