//
//  SWCartGoodsCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/29.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCartModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SWCartGoodsCellDelegate <NSObject>

- (void)changeSelectedState:(BOOL)isSelected;

@end
@interface SWCartGoodsCell : UITableViewCell<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sukLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UITextField *numTextT;
@property (nonatomic,strong) SWCartModel *model;
@property (nonatomic,weak) id<SWCartGoodsCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
