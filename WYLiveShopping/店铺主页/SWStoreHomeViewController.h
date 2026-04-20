//
//  SWStoreHomeViewController.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/6.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^storeReturnBlock)();
@interface SWStoreHomeViewController : SWBaseViewController
@property (nonatomic,strong) NSString *mer_id;
@property (nonatomic,copy) storeReturnBlock block;
@property (nonatomic,strong) NSString *mer_name;

@end

NS_ASSUME_NONNULL_END
