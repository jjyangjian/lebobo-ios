//
//  writeEvaluateViewController.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/12.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "WYBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^evaluateSucess)();
@interface writeEvaluateViewController : WYBaseViewController
@property (nonatomic,strong) NSDictionary *courseMsgDic;
@property (nonatomic,copy) evaluateSucess block;

@end

NS_ASSUME_NONNULL_END
