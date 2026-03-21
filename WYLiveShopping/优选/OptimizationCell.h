//
//  OptimizationCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/17.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "optimizationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OptimizationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgView;
@property (weak, nonatomic) IBOutlet UIButton *shareBuyBtn;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (nonatomic,strong) optimizationModel *model;
@property (weak, nonatomic) IBOutlet UILabel *salesL;

@end

NS_ASSUME_NONNULL_END
