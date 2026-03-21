//
//  WYLiveCourseCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/3.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "courseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface WYLiveCourseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UILabel *priceL;
@property (nonatomic,strong) courseModel *model;

@end

NS_ASSUME_NONNULL_END
