//
//  SWEvaluateWriteVC.h
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/7.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWBaseViewController.h"
#import "SWCartModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface SWPhotoView : UIView
@property(nonatomic, strong) UIImageView *thumbImgView;
@property (nonatomic,strong) UIButton *delateBtn;

@end

typedef void(^evaluateSucessBlock)();
@interface SWEvaluateWriteVC : SWBaseViewController
@property (nonatomic,strong) SWCartModel *goodsModel;
@property (nonatomic,copy) evaluateSucessBlock block;

@end

NS_ASSUME_NONNULL_END
