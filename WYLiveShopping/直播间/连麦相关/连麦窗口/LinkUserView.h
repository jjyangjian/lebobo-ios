//
//  LinkUserView.h
//  WYLiveShopping
//
//  Created by iyz on 2026/1/24.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TXLiteAVSDK_Professional/TXLivePlayListener.h>
#import <TXLiteAVSDK_Professional/TXLivePlayConfig.h>
#import <TXLiteAVSDK_Professional/TXLivePlayer.h>
#import <TXLiteAVSDK_Professional/TXLivePush.h>


@protocol tx_play_linkmic <NSObject>
@optional;
-(void)tx_startConnectRtmpForLink_mic;//开始连麦推流
-(void)tx_stoppushlink;//停止推流
-(void)tx_closeuserconnect:(NSString *)uid;//主播关闭某人的连麦
-(void)tx_closeUserbyVideo:(NSDictionary *)subdic;//视频播放失败
@end


@interface LinkUserView : UIView<TXLivePlayListener,TXLivePushListener>
{
    UIImageView *loadingImage;
    BOOL _ishost;//判断是不是主播
}
@property(nonatomic,strong)NSDictionary *subdic;
@property(nonatomic,assign)id<tx_play_linkmic>delegate;
@property(nonatomic,strong)NSString *playurl;
@property(nonatomic,strong)NSString *pushurl;
@property(nonatomic,strong,readonly)UIView *videoContainerView;
@property(nonatomic,copy,readonly)NSString *remoteUserId;
-(instancetype)initWithRTMPURL:(NSDictionary *)dic andFrame:(CGRect)frames andisHOST:(BOOL)ishost andAnToAn:(BOOL)isAnchor;
/// TRTC 互动连麦：仅作为远端画面渲染容器，不走 URL 播放
-(instancetype)initWithTRTCRemoteUserId:(NSString *)userId andFrame:(CGRect)frames andisHOST:(BOOL)ishost;
-(void)stopConnect;
-(void)stopPush;
//混流
-(void)hunliu:(NSDictionary *)hunDic andHost:(BOOL)isHost;//是否是主播连麦
-(void)ctrCloseBtn:(BOOL)isShow;
@end


