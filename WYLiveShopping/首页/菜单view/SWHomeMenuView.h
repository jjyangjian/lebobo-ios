//
//  SWHomeMenuView.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/13.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWHomeMenuView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *classLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIView *classView;
@property (nonatomic,strong) NSDictionary *msgDic;

@end

NS_ASSUME_NONNULL_END
