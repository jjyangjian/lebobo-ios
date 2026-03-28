//
//  SWTwEmojiView.h
//  TaiWanEight
//
//  Created by Boom on 2017/11/23.
//  Copyright © 2017年 YangBiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWLWLCollectionViewHorizontalLayout.h"

#define EmojiHeight 200

@protocol SWTwEmojiViewDelegate <NSObject>

- (void)sendimage:(NSString *)str;
-(void)clickSendEmojiBtn;

@end
@interface SWTwEmojiView : UIView<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,weak)id <SWTwEmojiViewDelegate> delegate;

@property(nonatomic,strong)UIButton *sendEmojiBtn;

@end
