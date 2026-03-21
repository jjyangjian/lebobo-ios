//
//  WYReatTypeView.h
//  YBEducation
//
//  Created by IOS1 on 2021/3/16.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ReatTypeSelectedBlock)(CGFloat rate);
@interface WYReatTypeView : UIView
@property (weak, nonatomic) IBOutlet UIButton *twoButton;
@property (weak, nonatomic) IBOutlet UIButton *oneFiveButton;
@property (weak, nonatomic) IBOutlet UIButton *oneButton;
@property (weak, nonatomic) IBOutlet UIButton *zeroFiveButton;
@property (nonatomic,strong) NSMutableArray *buttonArray;

@property (nonatomic,copy) ReatTypeSelectedBlock block;

@end

NS_ASSUME_NONNULL_END
