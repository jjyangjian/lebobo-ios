//
//  SWHomeViewController.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/10.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWHeaderBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
@interface SWHoverPageScrollView : UIScrollView<UIGestureRecognizerDelegate>
@property(nonatomic, strong) NSArray *scrollViewWhites;
@end

@interface SWHomeViewController : SWHeaderBaseViewController

@end

NS_ASSUME_NONNULL_END
