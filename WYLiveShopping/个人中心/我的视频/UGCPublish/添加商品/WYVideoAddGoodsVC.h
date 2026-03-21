//
//  YBVideoAddGoodsVC.h
//  iphoneLive
//
//  Created by YB007 on 2019/11/28.
//  Copyright © 2019 cat. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

typedef void(^AddGoodsBlock)(NSDictionary *originDic,NSString *formatJson);

@interface WYVideoAddGoodsVC : WYBaseViewController

@property (nonatomic,copy) AddGoodsBlock addGoodsEvent;

@end

NS_ASSUME_NONNULL_END
