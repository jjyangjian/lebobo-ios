//
//  SWHomeLiveCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/12.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWHomeLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWHomeLiveCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goodsThumbImgView;
@property (weak, nonatomic) IBOutlet UILabel *goodsNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (nonatomic,strong) SWHomeLiveModel *model;
@property (weak, nonatomic) IBOutlet UILabel *lookNumsLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeNumsLabel;

@end

NS_ASSUME_NONNULL_END
