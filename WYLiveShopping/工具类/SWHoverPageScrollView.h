//
//  SWHoverPageScrollView.h
//  WYLiveShopping
//
//  Extracted from deprecated SWHomeViewController.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWHoverPageScrollView : UIScrollView <UIGestureRecognizerDelegate>

@property (nonatomic, strong, nullable) NSArray<UIScrollView *> *scrollViewWhites;

@end

NS_ASSUME_NONNULL_END
