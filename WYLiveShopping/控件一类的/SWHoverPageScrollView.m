//
//  SWHoverPageScrollView.m
//  WYLiveShopping
//
//  Created by 牛环环 on 2026/3/31.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import "SWHoverPageScrollView.h"

@implementation SWHoverPageScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (self.scrollViewWhites == nil) return YES;
    for (UIScrollView *item in self.scrollViewWhites) {
        if (otherGestureRecognizer.view == item){
            return YES;
        }
    }
    return NO;
}
@end

