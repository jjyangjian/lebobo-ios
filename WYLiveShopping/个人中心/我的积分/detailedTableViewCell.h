//
//  detailedTableViewCell.h
//  YBEducation
//
//  Created by IOS1 on 2021/1/13.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface detailedTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UILabel *numL;

@end

NS_ASSUME_NONNULL_END
