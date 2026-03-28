//
//  SWGoodsListVC.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/22.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^adminGoodsBlock)();
@interface SWGoodsListVC : UIViewController
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,copy) adminGoodsBlock block;

@end

NS_ASSUME_NONNULL_END
