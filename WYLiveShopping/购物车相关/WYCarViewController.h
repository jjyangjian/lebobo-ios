//
//  WYCarViewController.h
//  YBEducation
//
//  Created by IOS1 on 2020/5/6.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "WYBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^CarBackBlock)(BOOL isCar);
@interface WYCarViewController : WYBaseViewController
@property (nonatomic,strong) NSString *goodsIndefiter;
@property (nonatomic,copy) CarBackBlock block;
@property (nonatomic,assign) BOOL isTabbar;

@end

NS_ASSUME_NONNULL_END
