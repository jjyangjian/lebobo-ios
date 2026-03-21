//
//  WYMineVideoCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WYMineVideoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UIImageView *storeIconImgV;
@property (weak, nonatomic) IBOutlet UIButton *looksBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (nonatomic,strong) WYVideoModel *model;
@end

NS_ASSUME_NONNULL_END
