//
//  SWPromoterUserCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/3.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWPromoterUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWPromoterUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconimgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UILabel *numsL;
@property (nonatomic,strong) SWPromoterUserModel *model;

@end

NS_ASSUME_NONNULL_END
