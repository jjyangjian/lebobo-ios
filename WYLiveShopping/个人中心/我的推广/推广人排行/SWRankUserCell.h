//
//  SWRankUserCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRankUserModel.h"
#import "SWCommissionUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWRankUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *numsL;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *peopleL;
@property (weak, nonatomic) IBOutlet UIImageView *numImgView;
@property (nonatomic,strong) SWRankUserModel *model;
@property (nonatomic,strong) SWCommissionUserModel *comModel;

@end

NS_ASSUME_NONNULL_END
