//
//  liveMessageView.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface liveMessageView : UIView
- (instancetype)initWithFrame:(CGRect)frame andType:(NSString *)type;
@property (nonatomic,strong) NSDictionary *dic;
- (void)changePayState;
@end

NS_ASSUME_NONNULL_END
