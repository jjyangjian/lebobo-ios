#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SWAppDelegate;

@interface JJAppConfigManager : NSObject

+ (void)configIQKeyboardManager;
+ (void)configBugly;
+ (void)configNotificationsWithApplication:(UIApplication *)application appDelegate:(SWAppDelegate *)appDelegate;
+ (void)configShareSDK;
+ (void)configVRtxLiveParamWithAppDelegate:(SWAppDelegate *)appDelegate;
+ (void)configHomeConfigWithCompletion:(void (^ __nullable)(void))completion;
+ (void)configTXIM;

@end

NS_ASSUME_NONNULL_END
