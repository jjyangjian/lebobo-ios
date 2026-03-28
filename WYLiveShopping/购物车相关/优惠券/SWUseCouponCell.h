//
//  SWUseCouponCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/2.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCouponModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWUseCouponCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *conditionLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UIButton *lingquButton;
@property (nonatomic,strong) SWCouponModel *model;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@end

NS_ASSUME_NONNULL_END
