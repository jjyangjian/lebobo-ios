//
//  SWCatalogModel.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/25.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWCatalogModel : NSObject
-(instancetype)initWithDic:(NSDictionary *)dic;
@property (nonatomic,strong) NSString *name;

/// 形式，1图文2视频3音频4ppt直播5视频直播6音频直播7授课直播（白板）
@property (nonatomic,strong) NSString *type;

/// 是否试学，0否1是
@property (nonatomic,strong) NSString *istrial;

/// 音频链接/视频链接/ 当type=4 url!='' 为回访
@property (nonatomic,strong) NSString *url;

/// 状态 0正常 1试学2已学完3正在直播4锁
@property (nonatomic,strong) NSString *status;
/// 是否可看 0否1是
@property (nonatomic,strong) NSString *isenter;
/// 是否上次学到 0否1是
@property (nonatomic,strong) NSString *islast;
/// 是否在直播0否1是
@property (nonatomic,strong) NSString *islive;

/// 开播时间
@property (nonatomic,strong) NSString *time_date;

/// 课时ID
@property (nonatomic,strong) NSString *lessonID;
/// 内容简介
@property (nonatomic,strong) NSString *des;
/// 是否购买课程
@property (nonatomic,strong) NSString *ifbuy;
/// 主播ID
@property (nonatomic,strong) NSString *liveuid;
/// 课程ID
@property (nonatomic,strong) NSString *courseid;
/// 主播头像
@property (nonatomic,strong) NSString *avatar_thumb;
/// 主播名称
@property (nonatomic,strong) NSString *user_nickname;
@end

NS_ASSUME_NONNULL_END
