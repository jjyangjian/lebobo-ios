//
//  SWHoverPageScrollView.h
//  WYLiveShopping
//
//  Created by 牛环环 on 2026/3/31.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWHoverPageScrollView : UIScrollView<UIGestureRecognizerDelegate>
@property(nonatomic, strong) NSArray *scrollViewWhites;
@end

NS_ASSUME_NONNULL_END
