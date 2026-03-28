//
//  SWYBLookVideoCell.h
//  yunbaolive
//
//  Created by ybRRR on 2020/9/17.
//  Copyright © 2020 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZFPlayer/ZFPlayer.h>
//typedef void (^FrontBlock)(NSString *type);
//#define YZMsg(a) a

typedef void (^VideoCellBlock)(NSString *eventType ,NSDictionary *eventDic);

@interface SWYBLookVideoCell : UICollectionViewCell
@property (nonatomic, strong) ZFPlayerController *player;
@property(nonatomic,strong)NSDictionary *dataDic;
@property(nonatomic,strong) UIButton *commentBtn;

//@property (nonatomic, copy)FrontBlock frontEvent;
@property(nonatomic,copy)VideoCellBlock videoCellEvent;
@property (nonatomic, strong) UIImageView *bgImgView;

-(void)zhuboMessage;
@end
