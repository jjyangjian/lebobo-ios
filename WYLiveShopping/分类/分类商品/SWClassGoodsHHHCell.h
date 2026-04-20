//
//  SWClassGoodsHHHCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/23.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWLiveGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWClassGoodsHHHCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *salesLabel;
@property (weak, nonatomic) IBOutlet UILabel *vipPriceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *vipImgV;
@property (nonatomic,strong) SWLiveGoodsModel *model;

@end

NS_ASSUME_NONNULL_END
