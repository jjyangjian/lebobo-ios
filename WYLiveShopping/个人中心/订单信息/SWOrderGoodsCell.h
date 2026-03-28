//
//  SWOrderGoodsCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/6.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCartModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWOrderGoodsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *unitPriceL;
@property (weak, nonatomic) IBOutlet UILabel *numsL;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgView;
@property (nonatomic,strong) SWCartModel *model;

@end

NS_ASSUME_NONNULL_END
