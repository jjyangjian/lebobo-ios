//
//  payView.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/21.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^orderInvalidBlock)();
@interface payView : UIView
@property (nonatomic,strong) NSString *addrid;
@property (nonatomic,strong) NSArray *goodsArray;
@property (nonatomic,strong) NSString *method;
@property (nonatomic,strong) NSString *deduct_integral;
@property (nonatomic,strong) NSString *moneyStr;
@property (nonatomic,strong) NSDictionary *vipMessage;
@property (nonatomic,strong) NSString *orderNum;
@property (nonatomic,strong) NSString *couponid;
@property (nonatomic,strong) NSDictionary *pinkMessage;
@property (nonatomic,copy) orderInvalidBlock block;

- (void)show;
@end

NS_ASSUME_NONNULL_END
