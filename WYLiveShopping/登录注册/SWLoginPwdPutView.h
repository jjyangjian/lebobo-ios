//
//  SWLoginPwdPutView.h
//  YBEducation
//
//  Created by IOS1 on 2020/2/27.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^logSucesss)();

@interface SWLoginPwdPutView : UIView
@property (nonatomic,copy) logSucesss block;
@end

NS_ASSUME_NONNULL_END
