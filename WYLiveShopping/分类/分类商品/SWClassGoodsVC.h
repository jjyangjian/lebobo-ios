//
//  SWClassGoodsVC.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/23.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWClassGoodsVC : SWBaseViewController
@property (nonatomic,strong) NSString *cid;//一级分类ID
@property (nonatomic,strong) NSString *sid;//二级分类ID
@property (nonatomic,strong) NSString *cate_name;
@property (nonatomic,strong) NSString *normalSearchStr;

@end

NS_ASSUME_NONNULL_END
