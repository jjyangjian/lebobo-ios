//
//  courseModel.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/17.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface courseModel : NSObject
-(instancetype)initWithDic:(NSDictionary *)dic;
@property (nonatomic,strong) NSString *user_nickname;
@property (nonatomic,strong) NSString *avatar;
@property (nonatomic,strong) NSString *userID;

/// 形式，1图文2视频3音频
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *courseID;

/// 类别，0内容1课程2直播3摄像头直播
@property (nonatomic,strong) NSString *sort;
@property (nonatomic,strong) NSString *thumb;
@property (nonatomic,strong) NSString *courseName;

/// 获取形式，0免费1收费2密码
@property (nonatomic,strong) NSString *paytype;

/// 价格位置显示内容，根据paytype区分颜色
@property (nonatomic,strong) NSString *payval;
/// 是否购买
@property (nonatomic,strong) NSString *ifbuy;

/// 课时位置显示内容
@property (nonatomic,strong) NSString *lesson;

@property (nonatomic,strong) NSString *islive;
/// 购物车商品是否选中
@property (nonatomic,assign) BOOL isSelected;
/// 是否含有教材0否1是
@property (nonatomic,assign) NSString * ismaterial;
/// 购物车ID
@property (nonatomic,assign) NSString *cartid;
@property (nonatomic,assign) NSString *isvip;
@property (nonatomic,assign) NSString *ifvip;
@property (nonatomic,assign) NSString *money_vip;
@property (nonatomic,assign) NSString *money;
@property (nonatomic,assign) BOOL isCartCourese;
@property (nonatomic,assign) NSString *isseckill;
@property (nonatomic,assign) NSString *money_seckill;
@property (nonatomic,assign) int seckill_ing;
@property (nonatomic,assign) int seckill_wait;
@property (nonatomic,assign) NSString *ispink;
@property (nonatomic,assign) NSString *money_pink;
@property (nonatomic,strong) NSString *lessons;
@property (nonatomic,strong) NSString *addTime;

@end

NS_ASSUME_NONNULL_END
