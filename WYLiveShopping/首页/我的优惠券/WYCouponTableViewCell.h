//
//  WYCouponTableViewCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "couponModel.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^delateCouponBlock)(couponModel *mod);
@interface WYCouponTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *storeNameL;
@property (weak, nonatomic) IBOutlet UILabel *typeL;
@property (weak, nonatomic) IBOutlet UILabel *typeTipsL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UILabel *fullLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyL;
@property (weak, nonatomic) IBOutlet UIButton *controlBtn;
@property (nonatomic,strong) couponModel *model;
@property (weak, nonatomic) IBOutlet UIImageView *rightImgView;
@property (weak, nonatomic) IBOutlet UIButton *homeBtn;
@property (nonatomic,assign) BOOL isHome;
@property (weak, nonatomic) IBOutlet UIImageView *couponImgView;
@property (nonatomic,copy) delateCouponBlock block;

@end

NS_ASSUME_NONNULL_END
