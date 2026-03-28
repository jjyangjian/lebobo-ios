//
//  SWCommentModel.m
//  iphoneLive
//
//  Created by 王敏欣 on 2017/9/6.
//  Copyright © 2017年 cat. All rights reserved.
//

#import "SWCommentModel.h"

@implementation SWCommentModel
-(instancetype)initWithDic:(NSDictionary *)subdic{
    self = [super init];
    if (self) {
        _at_info = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"at_info"]];
        _avatar_thumb = minstr([subdic valueForKey:@"avatar"]);
        _user_nicename = minstr([subdic valueForKey:@"nickname"]);
        _content = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"content"]];
        _datetime = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"add_time"]];
        _likes = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"likes"]];
        _islike = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"islike"]];
        _commentid = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"cid"]];
        _parentid = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"id"]];
        _ID = minstr([subdic valueForKey:@"uid"]);
        _videoID = minstr([subdic valueForKey:@"vid"]);
        
        _replyList = [[subdic valueForKey:@"replay"] valueForKey:@"list"];
        _isMore = [[[subdic valueForKey:@"replay"] valueForKey:@"ismore"] intValue];
        if (_replyList.count > 0) {
            NSDictionary *rrrDic = [[subdic valueForKey:@"replylist"] firstObject];
            _replyDate = minstr([rrrDic valueForKey:@"datetime"]);
            _replyName = minstr([[rrrDic valueForKey:@"userinfo"] valueForKey:@"user_nicename"]);
            _replyContent = minstr([rrrDic valueForKey:@"content"]);
            _replys = [NSString stringWithFormat:@"%ld",_replyList.count];
        }else{
            _replys = @"0";
        }
    }
    return self;
}
-(void)setmyframe:(SWCommentModel *)model{
    NSString *str = [NSString stringWithFormat:@"%@ ",_content];
    CGSize size = [str boundingRectWithSize:CGSizeMake(_window_width - 100, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    
    NSString *str2 = [NSString stringWithFormat:@"%@ ",_replyContent];
    CGSize size2 = [str2 boundingRectWithSize:CGSizeMake(_window_width - 120, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size;

    _contentRect = CGRectMake(50,45, size.width, size.height+5);
    
    _ReplyFirstRect = CGRectMake(70, _contentRect.origin.y + _contentRect.size.height + 20, size2.width, size2.height);
    int replys = [_replys intValue];
    if (replys >1) {
        _ReplyRect = CGRectMake(50, _ReplyFirstRect.origin.y + _ReplyFirstRect.size.height + 5, _window_width - 100,20);
         _rowH = MAX(0, CGRectGetMaxY(_ReplyRect)) + 5;
    }else{
        if (replys == 1) {
            _rowH = MAX(0, CGRectGetMaxY(_ReplyFirstRect)) + 15;
        }else{
            _rowH = MAX(0, CGRectGetMaxY(_contentRect)) + 15;
        }
        _ReplyRect = CGRectMake(0, 0, 0, 0);
    }
    _rowH += 20;
}
+(instancetype)modelWithDic:(NSDictionary *)subdic{
    SWCommentModel *model = [[SWCommentModel alloc]initWithDic:subdic];
    return model;
}
@end
