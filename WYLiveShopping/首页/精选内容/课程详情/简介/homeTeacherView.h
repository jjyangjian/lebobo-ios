//
//  homeTeacherView.h
//  YBEducation
//
//  Created by IOS1 on 2020/2/28.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "teacherModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface homeTeacherView : UIView
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *vImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *labelL;
@property (nonatomic,strong) NSDictionary *userMsg;
@property (nonatomic,strong) teacherModel *model;

@end

NS_ASSUME_NONNULL_END
