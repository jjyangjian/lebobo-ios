//
//  HomeLiveModel.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/15.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "HomeLiveModel.h"

@implementation HomeLiveModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _originDic = dic;
        self.thumb = minstr([dic valueForKey:@"thumb"]);
        self.uid = minstr([dic valueForKey:@"uid"]);
        self.titleStr = minstr([dic valueForKey:@"title"]);
        self.classid = minstr([dic valueForKey:@"classid"]);
        self.province = minstr([dic valueForKey:@"province"]);
        self.city = minstr([dic valueForKey:@"city"]);
        self.showid = minstr([dic valueForKey:@"showid"]);
        self.goodsnum = minstr([dic valueForKey:@"goodsnum"]);
        self.likes = minstr([dic valueForKey:@"likes"]);
        self.nums = minstr([dic valueForKey:@"nums"]);
        self.pull = minstr([dic valueForKey:@"pull"]);
        self.nickname = minstr([dic valueForKey:@"nickname"]);
        self.avatar = minstr([dic valueForKey:@"avatar"]);
        self.goods_img = minstr([dic valueForKey:@"goods_img"]);
        self.stream = minstr([dic valueForKey:@"stream"]);
        self.goods = [dic valueForKey:@"goods"];
        self.thumbs = [dic valueForKey:@"thumbs"];
        self.isattent = minstr([dic valueForKey:@"isattent"]);
        self.add_time = minstr([dic valueForKey:@"start_time"]);
        _rowH = 110;
        _imageH = 0;
        _scrollH = 0;
        [self getRowHeight];
        [self getContentAttString];
    }
    return self;
}
- (void)getRowHeight{
    CGFloat wordHeight = [[WYToolClass sharedInstance] heightOfString:[NSString stringWithFormat:@"占位符%@",_titleStr] andFont:SYS_Font(13) andWidth:_window_width-50];
    _rowH += wordHeight;
    _imageH = (_window_width-50)*0.615;
    _rowH += (_imageH + 10);

    if (_goods.count > 0) {
        _scrollH = 50;
        _rowH += 65;
    }
}
- (void)getContentAttString{
    NSMutableAttributedString *muAttStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@",_titleStr]];
    
    NSTextAttachment *typeAttchment = [[NSTextAttachment alloc]init];
    typeAttchment.bounds = CGRectMake(0, -2, 26, 14);//设置frame
    NSString *imageName = @"label-live";
    UIImage *image = [UIImage imageNamed:imageName];
    typeAttchment.image = image;//设置图片
    NSAttributedString *typeString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(typeAttchment)];
    [muAttStr insertAttributedString:typeString atIndex:0];
    _contentAttStr = muAttStr;
}

@end
