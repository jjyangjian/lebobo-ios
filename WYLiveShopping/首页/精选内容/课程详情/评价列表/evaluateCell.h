//
//  evaluateCell.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "evaluateModel.h"
#import "WYCouserStarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface evaluateCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *numL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet WYCouserStarView *starView;
@property (nonatomic,strong) evaluateModel *model;

@end

NS_ASSUME_NONNULL_END
