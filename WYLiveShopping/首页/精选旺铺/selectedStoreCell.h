//
//  selectedStoreCell.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/3.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface selectedStoreCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *fansL;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImgV1;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImgV2;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImgV3;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImgV4;
@property (nonatomic,strong) NSArray *imageArray;
@property (nonatomic,strong) NSDictionary *subDic;
@property (weak, nonatomic) IBOutlet UILabel *typeView;

@end

NS_ASSUME_NONNULL_END
