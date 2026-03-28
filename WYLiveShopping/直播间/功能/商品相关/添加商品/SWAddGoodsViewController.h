//
//  SWAddGoodsViewController.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^changeGoodsBlock)(NSDictionary *dic);
@interface SWAddGoodsViewController : SWBaseViewController
@property (nonatomic,copy) changeGoodsBlock block;
@property (nonatomic,assign) BOOL isVideo;
@property (nonatomic,assign) NSString *goodsID;

@end

NS_ASSUME_NONNULL_END
