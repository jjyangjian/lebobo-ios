//
//  SWAddressCell.h
//  YBEducation
//
//  Created by IOS1 on 2020/5/7.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWAddressModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SWAddressCellDeleagte <NSObject>

- (void)delateAddress:(SWAddressModel *)model;
- (void)editAddress:(SWAddressModel *)model;
- (void)setDefault:(SWAddressModel *)model;
@end
@interface SWAddressCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *defaultButton;
@property (nonatomic,weak) id<SWAddressCellDeleagte> delegate;
@property (nonatomic,strong) SWAddressModel *model;

@end

NS_ASSUME_NONNULL_END
