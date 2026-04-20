//
//  moneyBottomView.h
//  YBEducation
//
//  Created by IOS1 on 2020/5/6.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^moneyBottomViewBlock)(int type);
@interface SWCarBottomView : UIView
@property (weak, nonatomic) IBOutlet UIButton *allButton;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *numsLabel;
@property (weak, nonatomic) IBOutlet UIView *adminView;
@property (nonatomic,copy) moneyBottomViewBlock block;

@end

NS_ASSUME_NONNULL_END
