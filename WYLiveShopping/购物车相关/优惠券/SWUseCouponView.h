//
//  SWUseCouponView.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/2.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^couponBlock)(NSDictionary *dic);
@interface SWUseCouponView : UIView
- (instancetype)initWithCouponID:(NSString *)sid andIsDraw:(BOOL)isd andUsePrice:(NSString *)price andCart:(NSDictionary *)cart;
@property (nonatomic,copy) couponBlock block;
- (void)show;
@end

NS_ASSUME_NONNULL_END
