//
//  SWLiveGoodsView.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWLiveGoodsView : UIView
- (instancetype)initWithFrame:(CGRect)frame andLiveUid:(NSString *)uid;
- (void)show;
@end

NS_ASSUME_NONNULL_END
