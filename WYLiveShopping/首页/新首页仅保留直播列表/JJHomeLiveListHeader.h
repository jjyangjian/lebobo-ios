//
//  JJHomeLiveListHeader.h
//  WYLiveShopping
//
//  Created by 牛环环 on 2026/3/25.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ButtonClickBlock)(void);

@interface JJHomeLiveListHeader : UITableViewHeaderFooterView
@property(nonatomic,copy)ButtonClickBlock doMoreAction;
@end

NS_ASSUME_NONNULL_END
