//
//  LinkApplyView.h
//  WYLiveShopping
//
//  Created by iyz on 2026/1/20.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LinkAncorDelegate<NSObject>

@optional

-(void)agreeUserLink:(NSDictionary *)userInfo;
-(void)closeLinkSwitch;

@end

@interface LinkApplyView : UIView

@property(nonatomic,weak)id<LinkAncorDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame andLiveUid:(NSString *)uid;
- (void)show;
- (void)diHide;
@end

