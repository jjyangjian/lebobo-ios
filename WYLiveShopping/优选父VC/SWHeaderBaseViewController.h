//
//  SWHeaderBaseViewController.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/17.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWBadgeButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWHeaderBaseViewController : UIViewController
//顶部按钮
@property (nonatomic,strong) SWBadgeButton *messageBtn;
@property (nonatomic,strong) SWBadgeButton *carBtn;
@property (nonatomic,strong) UIButton *searchBtn;

@end

NS_ASSUME_NONNULL_END
