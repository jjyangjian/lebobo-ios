//
//  rankUserCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "rankUserModel.h"
#import "commissionUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface rankUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *numsL;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *peopleL;
@property (weak, nonatomic) IBOutlet UIImageView *numImgView;
@property (nonatomic,strong) rankUserModel *model;
@property (nonatomic,strong) commissionUserModel *comModel;

@end

NS_ASSUME_NONNULL_END
