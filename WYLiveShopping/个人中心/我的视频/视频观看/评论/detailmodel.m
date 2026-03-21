//
//  detailmodel.m
//  iphoneLive
//
//  Created by 王敏欣 on 2017/9/6.
//  Copyright © 2017年 cat. All rights reserved.
//
#import "detailmodel.h"
@implementation detailmodel
-(instancetype)initWithDic:(NSDictionary *)subdic{
    self = [super init];
    if (self) {
        _at_info = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"at_info"]];

        _avatar_thumb = minstr([subdic valueForKey:@"avatar"]);
        _user_nicename = minstr([subdic valueForKey:@"nickname"]);
        _ID = minstr([subdic valueForKey:@"uid"]);
        _touid = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"touid"]];
        _datetime = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"add_time"]];
        _likes = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"likes"]];
        _islike = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"islike"]];
//        _touserinfo = [subdic valueForKey:@"touserinfo"];
        _toname = minstr([subdic valueForKey:@"toname"]);
        _parentid = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"id"]];

        if ([_toname length] > 0) {
            _content = [NSString stringWithFormat:@"%@回复%@:%@",_user_nicename,_toname,[subdic valueForKey:@"content"]];
        }else{
            _content = [NSString stringWithFormat:@"%@:%@",_user_nicename,[subdic valueForKey:@"content"]];
        }
        [self setmyframe:nil];
    }
    return self;
}
-(void)setmyframe:(detailmodel *)model{
    //判断是不是回复的回复
    NSString *reply1 = [NSString stringWithFormat:@"%@",_content];
    CGSize size = [reply1 boundingRectWithSize:CGSizeMake(_window_width - 95, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    _contentRect = CGRectMake(5,5, _window_width - 95, size.height);

    _rowH = MAX(0, CGRectGetMaxY(_contentRect)) + 8;

//    int touid = [_touid intValue];
//    
//    if (touid>0) {
//        NSString *reply1 = [NSString stringWithFormat:@"回复%@:%@",[_touserinfo valueForKey:@"user_nicename"],_content];
//        CGSize size = [reply1 boundingRectWithSize:CGSizeMake(_window_width - 120, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size;
//        _contentRect = CGRectMake(50,55, size.width+20, size.height);
//        NSString *reply = [NSString stringWithFormat:@"%@:%@",[_touserinfo valueForKey:@"user_nicename"],[_tocommentinfo valueForKey:@"content"]];
//         CGSize size2 = [reply boundingRectWithSize:CGSizeMake(_window_width - 120, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size;
//        _ReplyRect = CGRectMake(0, 20, size2.width+20, size2.height);
//        _rowH = MAX(0, CGRectGetMaxY(_ReplyRect)) + 15;
//    }
//    else{
//        CGSize size = [_content boundingRectWithSize:CGSizeMake(_window_width - 120, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size;
//        _contentRect = CGRectMake(0,20, size.width, size.height);
//        _ReplyRect = CGRectMake(0, 0, 0, 0);
//        _rowH = MAX(0, CGRectGetMaxY(_contentRect)) + 15;
//    }
}
+(instancetype)modelWithDic:(NSDictionary *)subdic{
    detailmodel *model = [[detailmodel alloc]initWithDic:subdic];
    return model;
}
@end
