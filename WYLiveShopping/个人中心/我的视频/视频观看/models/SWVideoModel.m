//
//  NearbyVideoModel.m
//  iphoneLive
//
//  Created by YangBiao on 2017/9/6.
//  Copyright © 2017年 cat. All rights reserved.
//

#import "SWVideoModel.h"

@implementation SWVideoModel

- (instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        id goodssss = [dic valueForKey:@"goods"];
        if ([goodssss isKindOfClass:[NSArray class]]) {
            self.goods = goodssss;
        }else{
            self.goods = @[];
        }
        self.videoImage = [NSString stringWithFormat:@"%@",[dic valueForKey:@"thumb"]];
        self.videoTitle = [NSString stringWithFormat:@"%@",[dic valueForKey:@"name"]];
        self.videoID    = [NSString stringWithFormat:@"%@",[dic valueForKey:@"id"]];
        self.playUrlStr = [NSString stringWithFormat:@"%@",[dic valueForKey:@"href"]];
        self.distance   = [NSString stringWithFormat:@"%@",[dic valueForKey:@"distance"]];
        self.status   = [NSString stringWithFormat:@"%@",[dic valueForKey:@"status"]];
        self.views   = [NSString stringWithFormat:@"%@",[dic valueForKey:@"plays"]];
        self.userAvatar   = [NSString stringWithFormat:@"%@",[dic valueForKey:@"avatar"]];
        self.userName   = [NSString stringWithFormat:@"%@",[dic valueForKey:@"nickname"]];
        self.userUid    = [NSString stringWithFormat:@"%@",[dic valueForKey:@"uid"]];
        self.time       = [NSString stringWithFormat:@"%@",[dic valueForKey:@"datetime"]];
        self.commentNum = [NSString stringWithFormat:@"%@",[dic valueForKey:@"comments"]];
        self.zanNum     = [NSString stringWithFormat:@"%@",[dic valueForKey:@"likes"]];
    }
    return self;
}
+(instancetype)modelWithDic:(NSDictionary *)dic{
    
    SWVideoModel *model = [[SWVideoModel alloc]initWithDic:dic];
    return model;
}
@end
