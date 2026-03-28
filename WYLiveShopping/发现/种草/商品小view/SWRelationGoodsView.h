//
//  SWRelationGoodsView.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/30.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWRelationGoodsView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *priceL;
@property (nonatomic,strong) NSDictionary *subDic;
@property (nonatomic,assign) BOOL isLive;

@end

NS_ASSUME_NONNULL_END
