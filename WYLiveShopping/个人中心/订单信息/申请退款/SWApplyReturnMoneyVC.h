//
//  SWApplyReturnMoneyVC.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/7.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^ApplyReturnMoneyBlock)();

@interface SWApplyReturnMoneyVC : SWBaseViewController
@property (nonatomic,strong) NSDictionary *orderMessage;
@property (nonatomic,copy) ApplyReturnMoneyBlock block;

@end

NS_ASSUME_NONNULL_END
