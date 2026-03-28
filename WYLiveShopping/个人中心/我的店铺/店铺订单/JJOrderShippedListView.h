//
//  JJOrderShippedListView.h
//  WYLiveShopping
//
//  Created by IOS1 on 2026/3/27.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "orderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JJOrderShippedListView : UIView
@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSString *statusType;
@property (nonatomic, copy) void (^selectBlock)(orderModel *model);
@property (nonatomic, copy) void (^refreshBlock)(void);
- (void)requestFirstPageData;

@end

NS_ASSUME_NONNULL_END
