//
//  SWFindVideoCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWFindVideoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UIView *goodsView;
@property (nonatomic,strong) SWVideoModel *model;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *priceL;
@property (weak, nonatomic) IBOutlet UILabel *vDesL;

@end

NS_ASSUME_NONNULL_END
