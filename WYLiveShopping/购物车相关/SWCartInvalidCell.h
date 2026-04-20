//
//  SWCartInvalidCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/30.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCartModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWCartInvalidCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (nonatomic,strong) SWCartModel *model;

@end

NS_ASSUME_NONNULL_END
