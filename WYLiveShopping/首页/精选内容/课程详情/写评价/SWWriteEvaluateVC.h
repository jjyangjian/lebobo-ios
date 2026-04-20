//
//  SWWriteEvaluateVC.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/12.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^evaluateSucess)();
@interface SWWriteEvaluateVC : SWBaseViewController
@property (nonatomic,strong) NSDictionary *courseMsgDic;
@property (nonatomic,copy) evaluateSucess block;

@end

NS_ASSUME_NONNULL_END
