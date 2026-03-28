//
//  SWAdminGoodsCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/22.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWLiveGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SWAdminGoodsCellDelegate <NSObject>

- (void)shangjiaGoods:(SWLiveGoodsModel *)model;
- (void)xiajiaGoods:(SWLiveGoodsModel *)model;
- (void)delateGoods:(SWLiveGoodsModel *)model;

@end
@interface SWAdminGoodsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *priceL;
@property (weak, nonatomic) IBOutlet UILabel *salesL;
@property (weak, nonatomic) IBOutlet UILabel *profitL;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *delateBtn;
@property (nonatomic,strong) SWLiveGoodsModel *model;
@property (nonatomic,weak) id<SWAdminGoodsCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
