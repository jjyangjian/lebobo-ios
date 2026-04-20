//
//  SWLinkmicManager.m
//  WYLiveShopping
//
//  Created by iyz on 2026/1/23.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import "SWLinkmicManager.h"
#import "SWPublicObj.h"

@interface SWLinkmicManager()

@property(nonatomic,assign)int currentApplayNums;

@end

static SWLinkmicManager *_singleton = nil;

@implementation SWLinkmicManager

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [[super allocWithZone:NULL] init];
    });
    return _singleton;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}

-(void)applyNumsChange:(BOOL)isAdd; {
    if (isAdd) {
        _currentApplayNums += 1;
    }else {
        _currentApplayNums -= 1;
    }

    if (_currentApplayNums <= 0) {
        _currentApplayNums = 0;
    }

}
-(void)resetNums {
    _currentApplayNums = 0;
}
#pragma mark - 主播端
/// 主播转推
-(void)livemicCdn {
    /*
    NSDictionary *changelive = @{
        @"stream":minstr([_roomMap valueForKey:@"stream"]),
    };
    [SWToolClass postNetworkWithUrl:@"livemic/cdn" andParameter:changelive success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {

    } fail:^{

    }];
    */
}
/// 主播停止转推
-(void)livemicStop {
    // 服务端在关播处处理 app不再请求
    /*
    NSDictionary *changelive = @{
        @"stream":minstr([_roomMap valueForKey:@"stream"]),
    };
    [SWToolClass postNetworkWithUrl:@"livemic/stop" andParameter:changelive success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {

    } fail:^{

    }];
    */
}
///开关连麦 0-关闭  1-开启
-(void)livemicSwitch:(int)status {

    NSDictionary *changelive = @{
        @"status":@(status),
    };
    [SWToolClass postNetworkWithUrl:@"livemic/switch" andParameter:changelive success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
        if (code == 200) {
            [SWLinkmicManager shareInstance].linkSwitch = status == 1 ? YES:NO;
        }
    } fail:^{

    }];
}

/// 同意拒绝连麦
-(void)livemicManage:(BOOL)isAgree andUserid:(NSString*)touid handle:(LinkmicHandle)handle{
    NSDictionary *changelive = @{
        @"stream":minstr([_roomMap valueForKey:@"stream"]),
        @"status": isAgree ? @"1":@"0",
        @"touid":touid,
    };
    [SWToolClass postNetworkWithUrl:@"livemic/manage" andParameter:changelive success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
        if (code == 200) {
            if (handle) {
                handle(Link_Anchor_Manager,0,@{});
            }
        }else {
            if (handle) {
                handle(Link_Anchor_Manager,-1,@{});
            }
        }
    } fail:^{
        if (handle) {
            handle(Link_Anchor_Manager,-1,@{});
        }
    }];
}
/// 混流  下麦传0
-(void)livemicMix:(NSString *)touid {
    NSDictionary *changelive = @{
        @"stream":minstr([_roomMap valueForKey:@"stream"]),
        @"touid":touid,
    };
    [SWToolClass postNetworkWithUrl:@"livemic/mix" andParameter:changelive success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
        if (code == 200) {

        }
    } fail:^{

    }];
}
// sdk混流
-(void)sdkLivemicMix:(NSString *)touid andUserPull:(NSString *)userPull pusher:(V2TXLivePusher*)livePusher; {
    // NSString *selfUrl = minstr([_roomMap valueForKey:@"push"]);
    NSString *otherUrl = userPull;

    // NSString * mainStreamId = [self getStreamIDByStreamUrl:selfUrl];
    NSString *subStreamId = [self getStreamIDByStreamUrl:otherUrl];

    V2TXLiveTranscodingConfig *config = [[V2TXLiveTranscodingConfig alloc] init];
    config.videoWidth =  540;
    config.videoHeight = 960;
    config.videoBitrate = 0;
    config.videoFramerate  = 20;

    V2TXLiveMixStream *mainStream = [[V2TXLiveMixStream alloc] init];
    V2TXLiveMixStream *subStream = [[V2TXLiveMixStream alloc] init];

    if (![SWPublicObj checkNull:otherUrl]) {
        mainStream.streamId = nil;
        mainStream.userId = [SWConfig getOwnID];
        mainStream.height = 960;//rrrr
        mainStream.width = 540;//rrrr
        mainStream.x = 0;
        mainStream.y = 0;
        mainStream.zOrder = 1;
        mainStream.inputType = V2TXLiveMixInputTypeAudioVideo;

        subStream.streamId = subStreamId;
        subStream.userId = touid;
        subStream.height =  240;
        subStream.width = 135;
        subStream.x = 390;
        subStream.y =576;
        subStream.zOrder = 2;
        subStream.inputType = V2TXLiveMixInputTypeAudioVideo;
        config.mixStreams = @[mainStream,subStream];

        V2TXLiveCode hunliuCode = [livePusher setMixTranscodingConfig:config];
        NSLog(@"ybliveRtcHunliu----:%ld",hunliuCode);
    }else{
        //断开连麦取消云端混流
        V2TXLiveCode hunliuCode = [livePusher setMixTranscodingConfig:nil];
        NSLog(@"ybliveRtcHunliu----:%ld",hunliuCode);
    }
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

#pragma mark - 用户端
-(void)userApplay:(LinkmicHandle)handle {
    NSDictionary *changelive = @{
        @"stream":minstr([_roomMap valueForKey:@"stream"]),
    };
    [SWToolClass postNetworkWithUrl:@"livemic/apply" andParameter:changelive success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
        if (code == 200) {
            if (handle) {
                handle(Link_Apply,0,@{});
            }
        }else {
            if (handle) {
                handle(Link_Apply,-1,@{});
            }
        }
    } fail:^{
        if (handle) {
            handle(Link_Apply,-1,@{});
        }
    }];
}

-(void)userCancel:(LinkmicHandle)handle {
    NSDictionary *changelive = @{
        @"stream":minstr([_roomMap valueForKey:@"stream"]),
    };
    [SWToolClass postNetworkWithUrl:@"livemic/cancle" andParameter:changelive success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
        if (code == 200) {
            if (handle) {
                handle(Link_Cancel,0,@{});
            }
        }else {
            if (handle) {
                handle(Link_Cancel,1,@{});
            }
        }
    } fail:^{
        if (handle) {
            handle(Link_Cancel,1,@{});
        }
    }];
}

// 获取连麦信息
-(void)userGetLinkinfo:(LinkmicHandle)handle {
//    NSDictionary *changelive = @{
//        @"stream":minstr([_roomMap valueForKey:@"stream"]),
//        @"liveuid":minstr([_roomMap valueForKey:@"uid"]),
//    };
    NSString *getUrl = [NSString stringWithFormat:@"livemic/url&liveuid=%@&stream=%@",minstr([_roomMap valueForKey:@"uid"]),minstr([_roomMap valueForKey:@"stream"])];
    [SWToolClass getQCloudWithUrl:getUrl Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
        if (code == 200) {
            /**
             返回值：
             live_pull   主播的播流地址
             user_push    用户的推流地址
             user_pull     用户的播流地址
             */
            if (handle) {
                handle(Link_Infos,0,info);
            }
        }else {
            if (handle) {
                handle(Link_Infos,-1,@{});
            }
        }
    } Fail:^{
        if (handle) {
            handle(Link_Infos,-1,@{});
        }
    }];
}

@end
