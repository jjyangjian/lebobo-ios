//
//  SWCouponTableViewCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCouponModel.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^delateCouponBlock)(SWCouponModel *mod);
@interface SWCouponTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeTipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *controlBtn;
@property (nonatomic,strong) SWCouponModel *model;
@property (weak, nonatomic) IBOutlet UIImageView *rightImgView;
@property (weak, nonatomic) IBOutlet UIButton *homeBtn;
@property (nonatomic,assign) BOOL isHome;
@property (weak, nonatomic) IBOutlet UIImageView *couponImgView;
@property (nonatomic,copy) delateCouponBlock block;

@end

NS_ASSUME_NONNULL_END
