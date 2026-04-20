//
//  SWVideoPauseView.h
//  iphoneLive
//
//  Created by Boom on 2017/12/14.
//  Copyright © 2017年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol videoPauseDelegate <NSObject>
- (void)goPlay;

@end

@interface SWVideoPauseView : UIView<UIAlertViewDelegate>
@property(nonatomic,weak) id<videoPauseDelegate> delegate;
@property (nonatomic,strong) NSString *fromWhere;
-(instancetype)initWithFrame:(CGRect)frame andVideoMsg:(NSDictionary *)videoDic;

@end
