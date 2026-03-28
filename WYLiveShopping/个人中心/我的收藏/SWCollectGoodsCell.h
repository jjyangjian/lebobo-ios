//
//  SWCollectGoodsCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/9.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCollectGoodsModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol SWCollectGoodsCellDelegate <NSObject>

- (void)removeCollected:(SWCollectGoodsModel *)model;

@end
@interface SWCollectGoodsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *priceL;
@property (nonatomic,strong) SWCollectGoodsModel *model;
@property (nonatomic,weak) id<SWCollectGoodsCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
