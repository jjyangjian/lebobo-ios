

#import <Foundation/Foundation.h>
#import "SWLiveUser.h"

@interface SWConfig : NSObject
+ (void)saveProfile:(SWLiveUser *)user;
+ (void)updateProfile:(SWLiveUser *)user;
+ (void)clearProfile;
+ (SWLiveUser *)myProfile;
+(NSString *)getOwnID;
+(NSString *)getOwnNicename;
+(NSString *)getOwnToken;
+(NSString *)getavatar;
+(NSString *)getLevel;
+(NSString *)getcoin;
+(NSString *)getAddr;
+(NSString *)getRealName;
+(NSString *)getBirthday;
+(NSString *)getCard_id;
+(NSString *)getPartner_id;
+(NSString *)getGroup_id;
+(NSString *)getPhoneNum;
+(NSString *)getIntegral;
+(NSString *)getSign_num;
+(NSString *)getSpread_uid;
+(NSString *)getSpread_time;
+(NSString *)getUser_type;
+(NSString *)getPay_count;
+(NSString *)getSpread_count;
+(NSString *)getIsShop;
+(NSString *)brokerage_price;

///保存token
+(void)saveOwnToken:(NSString *)token;
///保存是否是商铺
+(void)saveIsShop:(NSString *)isshop;
//更新金币
+(void)saveIcon:(NSString *)coin;
+(NSString *)getNowIcon;

+(void)saveOwnUserTXIMSign:(NSString *)sign;
+(NSString *)getOwnUserTXIMSign;
@end
