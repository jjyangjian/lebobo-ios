//
//  catalogCell.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/12.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "catalogModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface catalogCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *typeL;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *statusL;
@property (weak, nonatomic) IBOutlet UIImageView *lockImgV;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (nonatomic,strong) catalogModel *model;
@property (weak, nonatomic) IBOutlet UIImageView *typeImgV;

@end

NS_ASSUME_NONNULL_END
