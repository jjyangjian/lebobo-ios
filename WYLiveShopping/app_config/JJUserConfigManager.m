#import "JJUserConfigManager.h"

@implementation JJUserConfigManager

+ (void)configIMLogin {
    [[TUIKit sharedInstance] login:[SWConfig getOwnID] userSig:[SWConfig getOwnUserTXIMSign] succ:^{
        NSLog(@"IM登录成功");
    } fail:^(int code, NSString *msg) {
        NSLog(@"IM登录失败 \n code=%d \n msg=%@", code, msg);
    }];
}

@end
