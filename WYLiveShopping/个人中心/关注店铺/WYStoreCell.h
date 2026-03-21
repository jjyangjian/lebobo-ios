//
//  WYStoreCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/3.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WYStoreCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *adressL;
@property (weak, nonatomic) IBOutlet UILabel *fansNumsL;
@property (weak, nonatomic) IBOutlet UILabel *typeView;

@end

NS_ASSUME_NONNULL_END
