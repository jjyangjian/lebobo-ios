//
//  SWOrderDetailsVC.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/6.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWBaseViewController.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^controlOrderSucess)();
@interface SWOrderDetailsVC : SWBaseViewController
@property (nonatomic,strong) NSDictionary *orderMessage;
@property (nonatomic,assign) BOOL isCart;
@property (nonatomic,copy) controlOrderSucess block;
//0用户正常订单 1用户退款订单
@property (nonatomic,assign) int orderType;

@end

NS_ASSUME_NONNULL_END
