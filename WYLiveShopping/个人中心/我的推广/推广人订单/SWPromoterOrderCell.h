//
//  SWPromoterOrderCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWPromoterOrderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *tipsL;
@property (weak, nonatomic) IBOutlet UILabel *moneyl;
@property (weak, nonatomic) IBOutlet UILabel *orderNumL;

@end

NS_ASSUME_NONNULL_END
