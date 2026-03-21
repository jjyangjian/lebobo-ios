//
//  LinkUserView.m
//  WYLiveShopping
//
//  Created by iyz on 2026/1/24.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import "LinkUserView.h"
#import <TXLiteAVSDK_Professional/TXLiteAVSDK.h>
#import <TXLiteAVSDK_Professional/V2TXLivePlayer.h>
#import "PublicObj.h"

@interface LinkUserView()<V2TXLivePlayerObserver,V2TXLivePusherObserver>
{
    UIButton  *_returnCancle;

    int linkCount;

    UIView *_attView;
    UIImageView *_headImg;
    UILabel *_nameLb;
    UIButton *_attBtn;
    UIView *_videoContainerView;

}
@property(nonatomic, strong)V2TXLivePlayer *txLivePlayer;
@property(nonatomic,strong)V2TXLiveVideoEncoderParam *txLiveVieoParam;
@property(nonatomic,strong)V2TXLivePusher *txLivePusher;
@property(nonatomic,strong)TXAudioEffectManager *audioEffect;
@property(nonatomic,copy,readwrite)NSString *remoteUserId;

@end


@implementation LinkUserView

-(instancetype)initWithRTMPURL:(NSDictionary *)dic andFrame:(CGRect)frames andisHOST:(BOOL)ishost andAnToAn:(BOOL)isAnchor{
    self = [super initWithFrame:frames];
    linkCount = 1;
    _subdic = [NSDictionary dictionaryWithDictionary:dic];
    _playurl = [NSString stringWithFormat:@"%@",[dic valueForKey:@"playurl"]];
    _pushurl = [NSString stringWithFormat:@"%@",[dic valueForKey:@"pushurl"]];
    NSLog(@"\n_playurl=%@\n",_playurl);
    if (self) {
        _ishost = ishost;
        _videoContainerView = [[UIView alloc] initWithFrame:self.bounds];
        _videoContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _videoContainerView.backgroundColor = UIColor.blackColor;
        [self addSubview:_videoContainerView];

        if ([_pushurl isEqual:@"0"]) {
            if (_playurl.length > 0 && ![_playurl isEqualToString:@"0"]) {
                [self RTMPPlay:frames];
            }
        }
        else{
            [self RTMPPUSH:frames];
        }
        loadingImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frames.size.width, frames.size.height)];
        loadingImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:loadingImage];
        NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"loading_image0.png"],
                                 [UIImage imageNamed:@"loading_image1.png"],
                                 [UIImage imageNamed:@"loading_image2.png"],
                                 [UIImage imageNamed:@"loading_image3.png"],
                                 [UIImage imageNamed:@"loading_image4.png"],
                                 [UIImage imageNamed:@"loading_image5.png"],
                                 [UIImage imageNamed:@"loading_image6.png"],
                                 [UIImage imageNamed:@"loading_image7.png"],
                                 [UIImage imageNamed:@"loading_image8.png"],
                                 [UIImage imageNamed:@"loading_image9.png"],
                                 [UIImage imageNamed:@"loading_image10.png"],
                                 [UIImage imageNamed:@"loading_image11.png"],
                                 [UIImage imageNamed:@"loading_image12.png"],
                                 [UIImage imageNamed:@"loading_image13.png"],
                                 [UIImage imageNamed:@"loading_image14.png"],
                                 nil];
        //要展示的动画
        loadingImage.animationImages=array;
        //一次动画的时间
        loadingImage.animationDuration= [array count]*0.1;
        //只执行一次动画
        loadingImage.animationRepeatCount = MAXFLOAT;
        //开始动画
        [loadingImage startAnimating];


        //直播间观众—关闭
        _returnCancle = [UIButton buttonWithType:UIButtonTypeCustom];
        _returnCancle.tintColor = [UIColor whiteColor];
        [_returnCancle setImage:[UIImage imageNamed:@"直播间观众—关闭"] forState:UIControlStateNormal];
        _returnCancle.backgroundColor = [UIColor clearColor];
        [_returnCancle setTitle:[dic valueForKey:@"userid"] forState:UIControlStateNormal];
        [_returnCancle setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [_returnCancle addTarget:self action:@selector(returnCancles:) forControlEvents:UIControlEventTouchUpInside];
        _returnCancle.frame = CGRectMake(frames.size.width-37, 3, 34, 34);
        _returnCancle.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_returnCancle];

        /*
        if (isAnchor) {
            _attView = [[UIView alloc]init];
            _attView.frame = CGRectMake(frames.size.width-120, frames.size.height-26-10, 110, 26);
            _attView.backgroundColor = RGBA(1, 1, 1, 0.4);
            _attView.layer.cornerRadius = 13;
            _attView.layer.masksToBounds = YES;
            [self addSubview:_attView];

            _headImg = [[UIImageView alloc]init];
            _headImg.layer.cornerRadius = 11;
            _headImg.layer.masksToBounds = YES;
            [_attView addSubview:_headImg];
            [_headImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_attView.mas_left).offset(2);
                make.centerY.equalTo(_attView);
                make.height.width.mas_equalTo(22);
            }];

            _attBtn = [UIButton buttonWithType:0];
            _attBtn.layer.cornerRadius = 8;
            _attBtn.layer.masksToBounds = YES;
            [_attBtn setImage:[UIImage imageNamed:@"pkatt"] forState:0];
            [_attBtn addTarget:self action:@selector(forceBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [_attView addSubview:_attBtn];
            [_attBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_attView.mas_right).offset(-5);
                make.centerY.equalTo(_attView);
                make.height.width.mas_equalTo(16);
            }];

            _nameLb = [[UILabel alloc]init];
            _nameLb.font = [UIFont systemFontOfSize:10];
            _nameLb.textColor = UIColor.whiteColor;
            [_attView addSubview:_nameLb];
            [_nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_headImg.mas_right).offset(3);
                make.right.equalTo(_attBtn.mas_left).offset(-3);
                make.centerY.equalTo(_attView);
            }];
            [self getUserInfo:dic];
        }
        */
        if (_ishost) {
            _returnCancle.hidden = NO;
        }else{
            _returnCancle.hidden = YES;
        }
    }
    return self;
}

-(instancetype)initWithTRTCRemoteUserId:(NSString *)userId andFrame:(CGRect)frames andisHOST:(BOOL)ishost {
    self = [super initWithFrame:frames];
    if (self) {
        _ishost = ishost;
        _remoteUserId = [userId copy];
        _subdic = @{ @"userid": userId ?: @"" };
        _playurl = @"";
        _pushurl = @"0";

        _videoContainerView = [[UIView alloc] initWithFrame:self.bounds];
        _videoContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _videoContainerView.backgroundColor = UIColor.blackColor;
        [self addSubview:_videoContainerView];

        // 关闭按钮
        _returnCancle = [UIButton buttonWithType:UIButtonTypeCustom];
        _returnCancle.tintColor = [UIColor whiteColor];
        [_returnCancle setImage:[UIImage imageNamed:@"直播间观众—关闭"] forState:UIControlStateNormal];
        _returnCancle.backgroundColor = [UIColor clearColor];
        [_returnCancle setTitle:userId forState:UIControlStateNormal];
        [_returnCancle setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [_returnCancle addTarget:self action:@selector(returnCancles:) forControlEvents:UIControlEventTouchUpInside];
        _returnCancle.frame = CGRectMake(frames.size.width-37, 3, 34, 34);
        _returnCancle.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_returnCancle];

        _returnCancle.hidden = !_ishost;
    }
    return self;
}

-(void)ctrCloseBtn:(BOOL)isShow {
    _returnCancle.hidden = !isShow;
}

-(UIView *)videoContainerView {
    return _videoContainerView ?: self;
}


- (void)appactive{
    //    [[YBLiveRTCManager shareInstance]resumePush];
    [_txLivePusher resumeVideo];
}
- (void)appnoactive{
    //    [[YBLiveRTCManager shareInstance]pausePush];
    [_txLivePusher pauseVideo];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)returnCancles:(UIButton *)sender{

    sender.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(sender){
            sender.userInteractionEnabled = YES;
        }
    });
    if ([self.delegate respondsToSelector:@selector(tx_closeuserconnect:)]) {
        [self.delegate tx_closeuserconnect:sender.titleLabel.text];
    }
    [self removeFromSuperview];
}
#pragma mark -用户端推流
-(void)RTMPPUSH:(CGRect)frames{
    UIView *preView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frames.size.width, frames.size.height)];
    [self addSubview:preView];

    //配置推流参数
    _txLiveVieoParam = [[V2TXLiveVideoEncoderParam alloc]init];
    _txLiveVieoParam.videoResolution =V2TXLiveVideoResolution1280x720;

    _txLivePusher = [[V2TXLivePusher alloc]initWithLiveMode:V2TXLiveMode_RTC];
    [_txLivePusher setVideoQuality:_txLiveVieoParam];
    [_txLivePusher startCamera:YES];
    [_txLivePusher startMicrophone];
    [_txLivePusher setRenderView:preView];
    [_txLivePusher startPush:_pushurl];
    [_txLivePusher setObserver:self];
    [_txLivePusher setEncoderMirror:YES];
    TXBeautyManager *beautyManager = [_txLivePusher getBeautyManager];
    [beautyManager setBeautyStyle:0];
    [beautyManager setBeautyLevel:9];
    [beautyManager setWhitenessLevel:3];
    [beautyManager setRuddyLevel:0];

    //注册进入后台的处理
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(appactive)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
    [dc addObserver:self
           selector:@selector(appnoactive)
               name:UIApplicationWillResignActiveNotification
             object:nil];

}
-(V2TXLivePlayer *)txLivePlayer{
    if(!_txLivePlayer){
        _txLivePlayer = [[V2TXLivePlayer alloc] init];
        [_txLivePlayer setObserver:self];
        [_txLivePlayer enableObserveAudioFrame:YES];
        [_txLivePlayer setRenderFillMode:V2TXLiveFillModeFill];
    }
    return _txLivePlayer;
}
-(void)RTMPPlay:(CGRect)frames{
    [self.txLivePlayer setRenderView:self.videoContainerView];
    V2TXLiveCode result = [self.txLivePlayer startLivePlay:_playurl];
    NSLog(@"wangminxin%ld",result);
    if( result == 0){
        NSLog(@"播放视频");
        //        [loadingImage removeFromSuperview];
        //        loadingImage = nil;
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}
#pragma mark  --RTC推流回调
/**
 * 推流器连接状态回调通知
 *
 * @param status    推流器连接状态 {@link V2TXLivePushStatus}。
 * @param msg       连接状态信息。
 * @param extraInfo 扩展信息。
 */
-(void)ybRTCPushStatusUpdate:(V2TXLivePushStatus)status message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo{

    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == V2TXLivePushStatusDisconnected) {
            /// 与服务器断开连接
            NSLog(@"PUSH_EVT_PUSH_BEGIN网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启推流");
            [MBProgressHUD showError:@"推流失败，结束连麦"];
            if ([self.delegate respondsToSelector:@selector(tx_stoppushlink)]) {
                [self.delegate tx_stoppushlink];
            }

        }else if(status == V2TXLivePushStatusConnecting){
            /// 正在连接服务器

        }else if(status == V2TXLivePushStatusConnectSuccess){
            /// 连接服务器成功
            if ([self.delegate respondsToSelector:@selector(tx_startConnectRtmpForLink_mic)]) {
                [self.delegate tx_startConnectRtmpForLink_mic];//开始连麦推流
            }
            [loadingImage removeFromSuperview];
            loadingImage = nil;
        }
    });
}
#pragma mark -主播和用户连麦混流
-(void)liveConnectWithUser{
    //    V2TXLiveTranscodingConfig *config = [[V2TXLiveTranscodingConfig alloc] init];
    //    config.videoWidth = 360;
    //    config.videoHeight = 640;
    //    config.videoBitrate = 900;
    //
    //    V2TXLiveMixStream *mainStream = [[V2TXLiveMixStream alloc] init];
    //    mainStream.streamId = self.streamId;
    //    mainStream.userId = self.userId;
    //    mainStream.height = 640;
    //    mainStream.width = 360;
    //    mainStream.x = 0;
    //    mainStream.y = 0;
    //    mainStream.zOrder = 1;
    //    mainStream.inputType = V2TXLiveMixInputTypeAudioVideo;
    //
    //    V2TXLiveMixStream *subStream = [[V2TXLiveMixStream alloc] init];
    //    subStream.streamId = streamId;
    //    subStream.userId = minstr([_subdic valueForKey:@"userid"]);
    //    subStream.height = 180;
    //    subStream.width = 100;
    //    subStream.x = 220;
    //    subStream.y = 400;
    //    subStream.zOrder = 2;
    //    subStream.inputType = V2TXLiveMixInputTypeAudioVideo;
    //
    //    config.mixStreams = @[mainStream, subStream];
    //    // 发起云端混流
    //
    //    [[YBLiveRTCManager shareInstance]MixTranscoding:config];
}
-(void)ybPushLiveStatus:(V2TXLiveCode)pushStatus
{
    if (pushStatus == V2TXLIVE_OK) {
        NSLog(@"LIVEBROADCAST --:推流成功、停止推流");
    }else if (pushStatus == V2TXLIVE_ERROR_INVALID_PARAMETER){
        [MBProgressHUD showError:@"操作失败，url 不合法"];
        NSLog(@"推流器启动失败");
    }else if (pushStatus == V2TXLIVE_ERROR_INVALID_LICENSE){
        [MBProgressHUD showError:@"操作失败，license 不合法，鉴权失败"];
        NSLog(@"推流器启动失败");
    }else if (pushStatus == V2TXLIVE_ERROR_REFUSED){
        [MBProgressHUD showError:@"操作失败，RTC 不支持同一设备上同时推拉同一个 StreamId"];
        NSLog(@"推流器启动失败");
    }else if (pushStatus == V2TXLIVE_WARNING_NETWORK_BUSY){
        [MBProgressHUD showError:@"您当前的网络环境不佳，请尽快更换网络保证正常直播"];
    }
}
/**
 * 推流器连接状态回调通知
 *
 * @param status    推流器连接状态 {@link V2TXLivePushStatus}。
 * @param msg       连接状态信息。
 * @param extraInfo 扩展信息。
 */
- (void)onPushStatusUpdate:(V2TXLivePushStatus)status message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == V2TXLivePushStatusDisconnected) {
            /// 与服务器断开连接
            NSLog(@"PUSH_EVT_PUSH_BEGIN网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启推流");
            [MBProgressHUD showError:@"网络断连"];

        }else if(status == V2TXLivePushStatusConnecting){
            /// 正在连接服务器

        }else if(status == V2TXLivePushStatusConnectSuccess){
            // 已经与服务器握手完毕,开始推流
            NSLog(@"play_linkmic连麦推流已经与服务器握手完毕,开始推流");
            if ([self.delegate respondsToSelector:@selector(tx_startConnectRtmpForLink_mic)]) {
                [self.delegate tx_startConnectRtmpForLink_mic];//开始连麦推流
            }
            [loadingImage removeFromSuperview];
            loadingImage = nil;

        }else if(status == V2TXLivePushStatusConnectSuccess){
            ///  重连服务器中
            [MBProgressHUD showError:@"网络断连, 已启动自动重连"];
        }
    });
}


//播放监听事件
-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PLAY_EVT_CONNECT_SUCC) {
            NSLog(@"play_linkMic已经连接服务器");
        }
        else if (EvtID == PLAY_EVT_RTMP_STREAM_BEGIN){
            NSLog(@"play_linkMic已经连接服务器，开始拉流");
        }
        else if (EvtID == PLAY_EVT_PLAY_BEGIN){
            NSLog(@"play_linkMic视频播放开始");
            [loadingImage removeFromSuperview];
            loadingImage = nil;
        }
        else if (EvtID== PLAY_WARNING_VIDEO_PLAY_LAG){
            NSLog(@"play_linkMic当前视频播放出现卡顿（用户直观感受）");
        }
        else if (EvtID == PLAY_EVT_PLAY_END){
            NSLog(@"play_linkMic视频播放结束");
        }
        else if (EvtID == PLAY_ERR_NET_DISCONNECT) {
            NSLog(@"play_linkMic网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启播放");
            //            if ([self.delegate respondsToSelector:@selector(tx_closeUserbyVideo:)]) {
            //                [self.delegate tx_closeUserbyVideo:_subdic];
            //            }
            [self returnCancles:_returnCancle];
        }
    });
}

- (void)stopConnect{
    if(_txLivePlayer != nil)
        {
        [_txLivePlayer stopPlay];
        }
}
-(void)stopPush{
    //    [_txLivePush stopPreview];
    if (_txLivePusher) {
        [_txLivePusher stopPush];
        [_txLivePusher stopCamera];
        [_txLivePusher stopMicrophone];
        _txLivePusher = nil;
    }

}
-(void)onNetStatus:(NSDictionary *)param{
}
//混流
-(void)hunliu:(NSDictionary *)hunDic andHost:(BOOL)isHost;{
    NSString *selfUrl = minstr([hunDic valueForKey:@"selfUrl"]);
    NSString *otherUrl = minstr([hunDic valueForKey:@"otherUrl"]);

    NSString * mainStreamId = [self getStreamIDByStreamUrl:selfUrl];
    NSString *subStreamId = [self getStreamIDByStreamUrl:otherUrl];

    V2TXLiveTranscodingConfig *config = [[V2TXLiveTranscodingConfig alloc] init];
    config.videoWidth =  540;
    config.videoHeight = 960;
    config.videoBitrate = 0;
    config.videoFramerate  = 20;

    V2TXLiveMixStream *mainStream = [[V2TXLiveMixStream alloc] init];
    V2TXLiveMixStream *subStream = [[V2TXLiveMixStream alloc] init];

    if (![PublicObj checkNull:otherUrl]) {
        if (isHost) {
            config.videoWidth = _window_width;
            config.videoHeight = _window_width*2/3;

            mainStream.streamId = nil;
            mainStream.userId = [Config getOwnID];
            mainStream.x = 0;
            mainStream.y = 0;
            mainStream.height = _window_width*2/3;
            mainStream.width = _window_width/2;
            mainStream.zOrder   = 0;
            mainStream.inputType = V2TXLiveMixInputTypeAudioVideo;

            subStream.streamId = subStreamId;
            subStream.userId = minstr([_subdic valueForKey:@"userid"]);
            subStream.height = _window_width*2/3;
            subStream.width = _window_width/2;
            subStream.x = _window_width/2;//rr
            subStream.y = 0;
            subStream.zOrder = 1;
            subStream.inputType = V2TXLiveMixInputTypeAudioVideo;
        }else{
            mainStream.streamId = nil;
            mainStream.userId = [Config getOwnID];
            mainStream.height = 960;//rrrr
            mainStream.width = 540;//rrrr
            mainStream.x = 0;
            mainStream.y = 0;
            mainStream.zOrder = 1;
            mainStream.inputType = V2TXLiveMixInputTypeAudioVideo;

            subStream.streamId = subStreamId;
            subStream.userId = minstr([_subdic valueForKey:@"userid"]);
            subStream.height =  240;
            subStream.width = 135;
            subStream.x = 390;
            subStream.y =576;
            subStream.zOrder = 2;
            subStream.inputType = V2TXLiveMixInputTypeAudioVideo;

        }
        config.mixStreams = @[mainStream,subStream];
        // [[YBLiveRTCManager shareInstance]MixTranscoding:config];
    }else{
        //断开连麦取消云端混流
        // [[YBLiveRTCManager shareInstance]MixTranscoding:nil];
    }
}
-(void)requestLink:(NSDictionary *)dicInfo andUrl:(NSString *)urlStr{

    //    YBWeakSelf;
//    [YBNetworking postWithUrl:urlStr Dic:dicInfo Suc:^(NSDictionary *data, NSString *code, NSString *msg) {
//        NSLog(@"===检查混流(uid%@)===code:%@==date:%@===msg:%@",[Config getOwnID],code,data,msg);
//        if ([code isEqual:@"0"]) {
//
//        }else{
//            if (linkCount > 3) {
//                return;
//            }else{
//                linkCount ++;
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [weakSelf requestLink:dicInfo andUrl:urlStr];
//                });
//
//            }
//        }
//    } Fail:nil];

}
- (NSString *)pictureArrayToJSON:(NSDictionary *)picArr {

    NSData *data=[NSJSONSerialization dataWithJSONObject:picArr options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //去除空格和回车：
    jsonStr = [jsonStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSLog(@"jsonStr==%@",jsonStr);
    return jsonStr;
}


-(NSString*) getStreamIDByStreamUrl:(NSString*) strStreamUrl {
    if (strStreamUrl == nil || strStreamUrl.length == 0) {
        return nil;
    }
    strStreamUrl = [strStreamUrl lowercaseString];
    //推流地址格式：rtmp://8888.livepush.myqcloud.com/live/8888_test_12345_test?txSecret=aaaa&txTime=bbbb
    NSString * strLive = @"/play/";
    NSRange range = [strStreamUrl rangeOfString:strLive];
    if (range.location == NSNotFound) {
        return nil;
    }
    NSString * strSubString = [strStreamUrl substringFromIndex:range.location + range.length];
    NSArray * array = [strSubString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?."]];
    if ([array count] > 0) {
        return [array objectAtIndex:0];
    }
    return @"";
}
#pragma mark---liveplayObserver
- (void)onError:(id<V2TXLivePlayer>)player code:(V2TXLiveCode)code message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo;
{
    NSLog(@"liveplay-error");
}
- (void)onWarning:(id<V2TXLivePlayer>)player code:(V2TXLiveCode)code message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo;
{
    NSLog(@"liveplay-onWarning");
}
/**
 * 已经成功连接到服务器
 *
 * @param player    回调该通知的播放器对象。
 * @param extraInfo 扩展信息。
 */

- (void)onVideoPlaying:(id<V2TXLivePlayer>)player firstPlay:(BOOL)firstPlay extraInfo:(NSDictionary *)extraInfo;
{
    NSLog(@"liveplay-VideoPlaying");
    [loadingImage removeFromSuperview];
    loadingImage = nil;
    //    [self liveConnectWithUser];

}

#pragma mark -判断用户信息
-(void)getUserInfo:(NSDictionary *)dic{
    /*
    NSDictionary *getPop = @{
        @"uid":[Config getOwnID],
        @"touid":[dic valueForKey:@"userid"],
        @"liveuid":[Config getOwnID]
    };
    [YBToolClass postNetworkWithUrl:@"Live.getPop" andParameter:getPop success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSArray *singleUserArray = [info firstObject];
            //头像
            NSString *avatar_str = minstr([singleUserArray valueForKey:@"avatar"]);
            [_headImg sd_setImageWithURL:[NSURL URLWithString:avatar_str]];
            //姓名
            NSString *userName = minstr([singleUserArray valueForKey:@"user_nickname"]);
            _nameLb.text = userName;

            NSString *isattention = [NSString stringWithFormat:@"%@",[singleUserArray valueForKey:@"isattention"]];
            //判断关注
            if ([isattention isEqual:@"0"]) {
                _attBtn.hidden = NO;
                [_attBtn setImage:[UIImage imageNamed:@"pkatt"] forState:0];
                [_attBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.width.mas_equalTo(16);
                }];
            }
            else{
                _attBtn.hidden = YES;
                [_attBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.width.mas_equalTo(1);
                }];
            }


        }
    } fail:^{

    }];
    */
}

@end
