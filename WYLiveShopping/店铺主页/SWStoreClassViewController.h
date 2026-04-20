//
//  SWStoreClassViewController.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWBaseViewController.h"
#import "SWStoreHomeViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWStoreClassViewController : SWBaseViewController
@property (nonatomic,copy) storeReturnBlock block;
@property (nonatomic,strong) NSString *mer_id;
@end

NS_ASSUME_NONNULL_END
