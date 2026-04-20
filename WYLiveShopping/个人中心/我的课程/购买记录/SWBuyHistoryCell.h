//
//  SWBuyHistoryCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/11.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCourseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWBuyHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (nonatomic,strong) SWCourseModel *model;

@end

NS_ASSUME_NONNULL_END
