//
//  WYAnliCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/30.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYAnliModel.h"
#import "HomeLiveModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface WYAnliCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgVie;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UIView *showImgView;
@property (weak, nonatomic) IBOutlet UIScrollView *shopScrollView;
@property (weak, nonatomic) IBOutlet UILabel *viewsNumL;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showImgViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollHeight;
@property (nonatomic,strong) WYAnliModel *model;
@property (nonatomic,strong) HomeLiveModel *livemodel;
@property (weak, nonatomic) IBOutlet UILabel *typeView;

@end

NS_ASSUME_NONNULL_END
