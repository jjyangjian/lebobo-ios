//
//  SWCatalogCell.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/12.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCatalogModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWCatalogCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lockImgV;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic,strong) SWCatalogModel *model;
@property (weak, nonatomic) IBOutlet UIImageView *typeImgV;

@end

NS_ASSUME_NONNULL_END
