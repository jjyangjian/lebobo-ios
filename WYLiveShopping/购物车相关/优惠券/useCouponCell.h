//
//  useCouponCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/2.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "couponModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface useCouponCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *moneyL;
@property (weak, nonatomic) IBOutlet UILabel *conditionL;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (weak, nonatomic) IBOutlet UIButton *lingquBtn;
@property (nonatomic,strong) couponModel *model;
@property (weak, nonatomic) IBOutlet UILabel *typeL;

@end

NS_ASSUME_NONNULL_END
