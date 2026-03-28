//
//  SWAnliCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/30.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWAnliModel.h"
#import "SWHomeLiveModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface SWAnliCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgVie;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *showImgView;
@property (weak, nonatomic) IBOutlet UIScrollView *shopScrollView;
@property (weak, nonatomic) IBOutlet UILabel *viewsNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showImgViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollHeight;
@property (nonatomic,strong) SWAnliModel *model;
@property (nonatomic,strong) SWHomeLiveModel *livemodel;
@property (weak, nonatomic) IBOutlet UILabel *typeView;

@end

NS_ASSUME_NONNULL_END
