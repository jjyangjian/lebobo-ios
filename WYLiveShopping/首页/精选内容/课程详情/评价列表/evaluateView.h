//
//  evaluateView.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface evaluateView : UIView
- (instancetype)initWithFrame:(CGRect)frame andCourse:(NSDictionary *)course andIsCourse:(BOOL)isC;
- (void)selfDowvaluateSucessToReload;
@property (nonatomic,strong) NSDictionary *courseDiccccc;

@end

NS_ASSUME_NONNULL_END
