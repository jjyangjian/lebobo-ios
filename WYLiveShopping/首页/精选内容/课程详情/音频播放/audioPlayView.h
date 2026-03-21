//
//  audioPlayView.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/17.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMPlayer.h"

NS_ASSUME_NONNULL_BEGIN
@protocol audioPlayViewDelegate <NSObject>

- (void)tryPlayOver;

@end
@interface audioPlayView : UIView<WMPlayerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *allTimeL;
@property (nonatomic,strong) WMPlayer *voicePlayer;
//监听播放起状态的监听者
@property (nonatomic,strong) AVPlayerItem * currentItem;
@property (nonatomic,strong) NSString *playUrl;
@property (nonatomic,strong) NSDictionary *courseDic;

@property (nonatomic,assign) int allCount;
@property (nonatomic,weak) id<audioPlayViewDelegate> delegate;

- (void)playerReadyToPlay:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
