//
//  LinkmicManager.h
//  WYLiveShopping
//
//  Created by iyz on 2026/1/23.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TXLiteAVSDK_Professional/TXLiteAVSDK.h>

// 用户连麦状态
typedef NS_ENUM(NSInteger,UserLinkStatus) {
    UserLinkStatus_Normal,  // 默认-未申请
    UserLinkStatus_Applied, // 已申请
    UserLinkStatus_Onmic,   // 在麦上
};
// 连麦事件
typedef NS_ENUM(NSInteger,LinkEvent) {
    Link_Apply,
    Link_Cancel,
    Link_Infos,
    Link_Anchor_Manager,
};
typedef void (^LinkmicHandle)(LinkEvent event,int eventCode,NSDictionary *eventDic);

@interface LinkmicManager : NSObject

+(instancetype)shareInstance;

@property(nonatomic,strong)NSDictionary *roomDic;
@property(nonatomic,assign)BOOL linkSwitch;// 主播连麦开关状态
@property(nonatomic,assign)BOOL isLinking;// 主播连麦开关状态
@property(nonatomic,assign)UserLinkStatus userStatus; // 用户连麦状态
@property(nonatomic,assign,readonly)int currentApplayNums;


-(void)applyNumsChange:(BOOL)isAdd;
-(void)resetNums;

#pragma mark - 主播端
// 转推cdn
-(void)livemicCdn;
// 主播停止转推
-(void)livemicStop;
// 连麦开关
-(void)livemicSwitch:(int)status;
// 同意拒绝连麦
-(void)livemicManage:(BOOL)isAgree andUserid:(NSString*)touid handle:(LinkmicHandle)handle;
// 混流(接口混流)
-(void)livemicMix:(NSString *)touid;
// sdk混流
-(void)sdkLivemicMix:(NSString *)touid andUserPull:(NSString *)userPull pusher:(V2TXLivePusher*)livePusher;
#pragma mark - 用户端
//用户申请、取消
-(void)userApplay:(LinkmicHandle)handle;
-(void)userCancel:(LinkmicHandle)handle;
// 获取连麦信息
-(void)userGetLinkinfo:(LinkmicHandle)handle;
@end

