#import "SWChatModel.h"
@implementation SWChatModel
-(instancetype)initWithDictionary:(NSDictionary *)map{
    self = [super init];
    if (self) {
        self.userName = minstr([map valueForKey:@"userName"]);
        self.contentChat = minstr([map valueForKey:@"contentChat"]);
        self.userID = minstr([map valueForKey:@"userID"]);
        self.type = minstr([map valueForKey:@"type"]);
        self.icon = minstr([map valueForKey:@"icon"]);
        self.isattent = [minstr([map valueForKey:@"isattent"]) intValue];
        self.userType = minstr(map[@"usertype"]);
    }
    return self;
}

- (instancetype)initWithOnlineDictionary:(NSDictionary *)map{
    self = [super init];
    if (self) {
        self.userName = minstr([map valueForKey:@"nickname"]);
        self.userID = minstr([map valueForKey:@"uid"]);
        self.icon = minstr([map valueForKey:@"avatar"]);
        self.money = minstr(map[@"total"]);
    }
    return self;
}
@end
