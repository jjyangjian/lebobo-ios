//
//  SWLinkApplyCell.h
//  WYLiveShopping
//
//  Created by iyz on 2026/1/21.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LinkApplyDelegate <NSObject>

-(void)linkToUser:(NSDictionary*)dic;

@end

@interface SWLinkApplyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarIV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UIButton *linkBtn;

@property(nonatomic,weak)id<LinkApplyDelegate> delegate;
@property(nonatomic,strong)NSDictionary *dataDic;


@end


