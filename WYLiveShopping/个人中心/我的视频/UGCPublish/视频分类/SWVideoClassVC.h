//
//  YBVideoClassVC.h
//  iphoneLive
//
//  Created by YB007 on 2019/11/27.
//  Copyright © 2019 cat. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

typedef void(^VideoClassSelectBlock)(NSDictionary *dic);

@interface SWVideoClassVC : SWBaseViewController

@property(nonatomic,copy)VideoClassSelectBlock videoClassEvent;

@end

NS_ASSUME_NONNULL_END
