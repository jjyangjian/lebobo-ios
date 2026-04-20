//
//  SWLiveMessageView.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/4.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWLiveMessageView.h"
#import "SWHomeTeacherView.h"
@interface SWLiveMessageView()
@end
@implementation SWLiveMessageView{
    UIScrollView *backScrollView;
    UILabel *titleLabel;
    UILabel *moneyLabel;
    UILabel *timeLabel;
    UILabel *numLabel;
    UILabel *contentL;
    UIButton *bottomButton;
//    teacherStarCell *teacherView;
    UILabel *teacherTitleLabel;
    WKWebView *webView;
    UILabel *contentTitleLabel;
    NSMutableArray *tearchersArray;
    UIView *tBackView;
}

- (instancetype)initWithFrame:(CGRect)frame andType:(NSString *)type{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        tearchersArray = [NSMutableArray array];
        [self creatUI];
    }
    return self;
}
- (void)creatUI{
    backScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height-ShowDiff)];
    [self addSubview:backScrollView];
    titleLabel = [[UILabel alloc]init];
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textColor = color32;
    [backScrollView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backScrollView).offset(15);
        make.top.equalTo(backScrollView).offset(15);
        make.width.equalTo(backScrollView).offset(-30);
    }];
    for (int i = 0; i < 3; i ++) {
        UILabel *label = [[UILabel alloc]init];
        [backScrollView addSubview:label];
        if (i == 0) {
            label.textColor = RGB_COLOR(@"#FF1B20", 1);
            label.font = [UIFont boldSystemFontOfSize:15];
            moneyLabel = label;
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(titleLabel.mas_bottom).offset(20);
                make.left.equalTo(titleLabel);
                make.height.mas_equalTo(16);

            }];

        }else{
            label.font = SYS_Font(11);
            label.textColor = color96;
            if (i == 1) {
                timeLabel = label;
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(titleLabel.mas_bottom).offset(20);
                    make.centerX.equalTo(titleLabel);
                    make.height.mas_equalTo(16);

                }];

            }else{
                numLabel = label;
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(titleLabel.mas_bottom).offset(20);
                    make.right.equalTo(titleLabel);
                    make.height.mas_equalTo(16);
                }];

            }
        }
    }
    UIView *lineV = [[UIView alloc]init];
    lineV.backgroundColor = colorf0;
    [backScrollView addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(40);
        make.left.width.equalTo(titleLabel);
        make.height.mas_equalTo(5);
    }];

//    teacherView = [[[NSBundle mainBundle] loadNibNamed:@"teacherStarCell" owner:nil options:nil] lastObject];
//    teacherView.frame = CGRectMake(0, 0, _window_width, 80);
//    [tBackView addSubview:teacherView];
    contentTitleLabel = [[UILabel alloc]init];
    contentTitleLabel.font = [UIFont boldSystemFontOfSize:16];
    contentTitleLabel.textColor = color32;
    [backScrollView addSubview:contentTitleLabel];
    [contentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineV.mas_bottom).offset(10);
        make.left.width.equalTo(titleLabel);
        make.height.mas_equalTo(35);
    }];

    webView = [[WKWebView alloc]init];
    webView.scrollView.bounces = NO;
    [backScrollView addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentTitleLabel.mas_bottom);
        make.left.width.equalTo(backScrollView);
        make.height.equalTo(backScrollView);
    }];
//    contentL = [[UILabel alloc]init];
//    contentL.font = SYS_Font(13);
//    contentL.textColor = color32;
//    contentL.numberOfLines = 0;
//    [backScrollView addSubview:contentL];
//    [contentL mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(contentTitleLabel.mas_bottom).offset(15);
//        make.left.width.equalTo(titleLabel);
//    }];
//    [backScrollView layoutIfNeeded];
//    backScrollView.contentSize = CGSizeMake(0, contentL.bottom + 20);
    

}
-(void)setDic:(NSDictionary *)dic{
    if (dic && dic.count > 0) {
        _dic = dic;

        titleLabel.attributedText = [self getPicAndWord:[NSString stringWithFormat:@"%@ ",minstr([_dic valueForKey:@"name"])]];
        /// 获取形式，0免费1收费2密码
        if ([minstr([_dic valueForKey:@"paytype"]) isEqual:@"0"]) {
            moneyLabel.text = @"免费";
            moneyLabel.textColor = RGB_COLOR(@"#64D3AD", 1);
        }else if ([minstr([_dic valueForKey:@"paytype"]) isEqual:@"1"]) {
            if ([minstr([_dic valueForKey:@"isbuy"]) isEqual:@"1"]) {
                moneyLabel.text = @"已付费";
            }else{
                moneyLabel.text = [NSString stringWithFormat:@"¥%@",minstr([_dic valueForKey:@"payval"])];
            }
            moneyLabel.textColor = RGB_COLOR(@"#FF1B20", 1);

        }else{
            moneyLabel.text = @"密码";
            moneyLabel.textColor = RGB_COLOR(@"#4385FF", 1);

        }
        contentTitleLabel.text = @"内容介绍";
        if (minstr([_dic valueForKey:@"lessons"]).length ==0 || [minstr([_dic valueForKey:@"lessons"]) intValue] ==0) {
            timeLabel.text = @"尚未添加内容";
//                        timeLabel.text = @"";
        }else{
            timeLabel.text = [NSString stringWithFormat:@"共%@",minstr([_dic valueForKey:@"lessons"])];
        }

        /*
        if ([minstr([_dic valueForKey:@"sort"]) isEqual:@"2"] || [minstr([_dic valueForKey:@"sort"]) isEqual:@"3"]  || [minstr([_dic valueForKey:@"sort"]) isEqual:@"4"]) {
            if ([minstr([_dic valueForKey:@"islive"]) isEqual:@"0"]) {
                timeLabel.text = [NSString stringWithFormat:@"直播时间：%@",minstr([_dic valueForKey:@"lesson"])];
            }else if ([minstr([_dic valueForKey:@"islive"]) isEqual:@"1"]){
                timeLabel.text = @"正在直播";
            }
            else{
                timeLabel.text = @"直播已结束";
            }
            contentTitleLabel.text = @"直播介绍";
        }else{
            if ([minstr([_dic valueForKey:@"sort"]) isEqual:@"0"]) {
                contentTitleLabel.text = @"内容介绍";
                timeLabel.text = minstr([_dic valueForKey:@"add_time"]);
            }else{
                contentTitleLabel.text = @"课程介绍";
                if ([minstr([_dic valueForKey:@"ismaterial"]) isEqual:@"1"]) {
                    if (minstr([_dic valueForKey:@"lessons"]).length == 0) {
                        timeLabel.attributedText = [self getHanjiaocai:@"尚未添加内容 "];
//                        timeLabel.attributedText = [self getHanjiaocai:@"暂未添加课时 "];

                    }else{
                        timeLabel.attributedText = [self getHanjiaocai:[NSString stringWithFormat:@"共%@ ",minstr([_dic valueForKey:@"lessons"])]];
                    }

                }else{
                    if (minstr([_dic valueForKey:@"lessons"]).length ==0) {
                        timeLabel.text = @"尚未添加内容";
//                        timeLabel.text = @"";
                    }else{
                        timeLabel.text = [NSString stringWithFormat:@"共%@",minstr([_dic valueForKey:@"lessons"])];
                    }
                }

            }
        }
         */
        numLabel.text = [NSString stringWithFormat:@"%@人学习",minstr([_dic valueForKey:@"views"])];
        [backScrollView layoutIfNeeded];
        backScrollView.contentSize = CGSizeMake(0, teacherTitleLabel.bottom +100+self.height);
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:minstr([_dic valueForKey:@"info_url"])]];
        [webView loadRequest:request];
    }
}
- (NSAttributedString *)getPicAndWord:(NSString *)str{
    NSMutableAttributedString *muArr = [[NSMutableAttributedString alloc]initWithString:str];
    UIImage *image;

    if ([minstr([_dic valueForKey:@"sort"]) isEqual:@"0"]) {
        switch ([minstr([_dic valueForKey:@"type"]) intValue]) {
            case 1:
                image = [UIImage imageNamed:@"xiangqing-图文自学"];
                break;
            case 2:
                image = [UIImage imageNamed:@"xiangqing-视频自学"];
                break;
            case 3:
                image = [UIImage imageNamed:@"xiangqing-语音自学"];
                break;
            default:
                break;
        }

//        if ([minstr([_dic valueForKey:@"type"]) isEqual:@"1"]) {
//            if ([minstr([_dic valueForKey:@"sort"]) isEqual:@"2"]) {
//                image = [UIImage imageNamed:@"详情-ppt"];
//            }else{
//                image = [UIImage imageNamed:@"详情-图文"];
//            }
//        }else if ([minstr([_dic valueForKey:@"type"]) isEqual:@"2"] || [minstr([_dic valueForKey:@"type"]) isEqual:@"5"]) {
//            image = [UIImage imageNamed:@"详情-视频"];
//        }else{
//            image = [UIImage imageNamed:@"详情-音频"];
//        }
    }else  if ([minstr([_dic valueForKey:@"sort"]) isEqual:@"2"]) {
        switch ([minstr([_dic valueForKey:@"type"]) intValue]) {
            case 1:
                image = [UIImage imageNamed:@"xiangqing-ppt讲解"];
                break;
            case 2:
                image = [UIImage imageNamed:@"xiangqing-视频讲解"];
                break;
            case 3:
                image = [UIImage imageNamed:@"xiangqing-语音讲解"];
                break;
            default:
                break;
        }

    }else  if ([minstr([_dic valueForKey:@"sort"]) isEqual:@"3"]) {
        image = [UIImage imageNamed:@"xiangqing-普通直播"];
    } else  if ([minstr([_dic valueForKey:@"sort"]) isEqual:@"4"]) {
        image = [UIImage imageNamed:@"xiangqing-白板互动"];
    }
    if (image) {
        NSTextAttachment *typeAttchment = [[NSTextAttachment alloc]init];
        typeAttchment.bounds = CGRectMake(-1, -2.5, 45, 16);//设置frame
        typeAttchment.image = image;//设置图片
        NSAttributedString *typeString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(typeAttchment)];
        [muArr appendAttributedString:typeString];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];        //设置行间距
    [muArr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [muArr length])];
    if (minstr([_dic valueForKey:@"des"]).length > 0) {
        NSMutableAttributedString *desStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"\n\n%@",minstr([_dic valueForKey:@"des"])]];
        [desStr addAttribute:NSForegroundColorAttributeName value:color96 range:NSMakeRange(0, desStr.length)];
        [desStr addAttribute:NSFontAttributeName value:SYS_Font(11) range:NSMakeRange(0, desStr.length)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];        //设置行间距
        [desStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [desStr length])];

        [muArr appendAttributedString:desStr];
    }
    return muArr;
}
- (NSAttributedString *)getHanjiaocai:(NSString *)str{
    NSMutableAttributedString *muArr = [[NSMutableAttributedString alloc]initWithString:str];
    NSTextAttachment *typeAttchment = [[NSTextAttachment alloc]init];
    typeAttchment.bounds = CGRectMake(0, -1, 10, 9);//设置frame
    UIImage *image = [UIImage imageNamed:@"含教材"];
    typeAttchment.image = image;//设置图片
    NSAttributedString *typeString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(typeAttchment)];
    [muArr appendAttributedString:typeString];
    NSMutableAttributedString *desStr = [[NSMutableAttributedString alloc]initWithString:@" 含教材"];
    [desStr addAttribute:NSForegroundColorAttributeName value:normalColors range:NSMakeRange(0, desStr.length)];
//    [desStr addAttribute:NSFontAttributeName value:SYS_Font(10) range:NSMakeRange(0, desStr.length)];
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle setLineSpacing:2];        //设置行间距
//    [desStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [desStr length])];

    [muArr appendAttributedString:desStr];
    return muArr;
}

#pragma mark -- 点击进入老师主页
- (void)doTeacherHome:(UIButton *)sender{
    if (![SWConfig getOwnID] || [[SWConfig getOwnID] intValue] == 0) {
        [[SWToolClass sharedInstance] showLoginView];
        return;
    }
}
- (void)changePayState{
    moneyLabel.text = @"已付费";
}
@end
