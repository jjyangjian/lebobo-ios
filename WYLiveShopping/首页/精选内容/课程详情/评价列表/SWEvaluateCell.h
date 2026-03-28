//
//  SWEvaluateCell.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWEvaluateModel.h"
#import "SWCouserStarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWEvaluateCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet SWCouserStarView *starView;
@property (nonatomic,strong) SWEvaluateModel *model;

@end

NS_ASSUME_NONNULL_END
