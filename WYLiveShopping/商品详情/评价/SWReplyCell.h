//
//  SWReplyCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/29.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWStarView.h"
#import "SWReplyModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWReplyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet SWStarView *starView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIView *picsView;
@property (weak, nonatomic) IBOutlet UIView *huifuView;
@property (weak, nonatomic) IBOutlet UILabel *huifuLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picViewHeightCon;

@property (nonatomic,strong) SWReplyModel *model;

@end

NS_ASSUME_NONNULL_END
