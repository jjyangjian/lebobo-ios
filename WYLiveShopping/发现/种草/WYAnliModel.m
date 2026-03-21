//
//  WYAnliModel.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/30.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYAnliModel.h"

@implementation WYAnliModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        _content = minstr([dic valueForKey:@"title"]);
        _image = [dic valueForKey:@"thumbs"];
        _goods = [dic valueForKey:@"goods"];
        _avatar = minstr([dic valueForKey:@"avatar"]);
        _add_time = minstr([dic valueForKey:@"add_time"]);
        _kolid = minstr([dic valueForKey:@"id"]);
        _isattent = minstr([dic valueForKey:@"isattent"]);
        _islike = minstr([dic valueForKey:@"islike"]);
        _likes = minstr([dic valueForKey:@"likes"]);
        _mer_id = minstr([dic valueForKey:@"mer_id"]);
        _nickname = minstr([dic valueForKey:@"nickname"]);
        _type = minstr([dic valueForKey:@"type"]);
        _views = minstr([dic valueForKey:@"views"]);
        _shoptype = minstr([dic valueForKey:@"shoptype"]);
        _rowH = 110;
        _imageH = 0;
        _scrollH = 0;
        [self getContentAttString];
        [self getRowHeight];
    }
    return self;
}
- (void)getRowHeight{
    CGFloat wordHeight = [[WYToolClass sharedInstance] heightOfString:[NSString stringWithFormat:@"占位符%@",_content] andFont:SYS_Font(13) andWidth:_window_width-50];
    _rowH += wordHeight;
    if (_isLive) {
        _imageH = (_window_width-50)*0.615;
        _rowH += (_imageH + 10);

        if (_goods.count > 0) {
            _scrollH = 50;
            _rowH += 65;
        }
    }else{
        //    if (_goods.count > 0) {
        //        _scrollH = 50;
                _rowH += 65;
        //    }
            if (_image.count > 0) {
                if (_image.count < 4) {
                    _imageH = ((_window_width-50-4)/3 * 0.75);
                }else if (_image.count < 7){
                    _imageH = ((_window_width-50-4)/3 * 0.75 * 2 + 2);
                }else{
                    _imageH = ((_window_width-50-4)/3 * 0.75 * 3 + 4);
                }
                _rowH += (_imageH + 10);
            }

    }
}
- (void)getContentAttString{
    NSMutableAttributedString *muAttStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@",_content]];
    
    NSTextAttachment *typeAttchment = [[NSTextAttachment alloc]init];
    typeAttchment.bounds = CGRectMake(0, -2, 26, 14);//设置frame
    NSString *imageName;
    int type = [_type intValue];
    switch (type) {
        case 2:
            imageName = @"label-new";
            break;
        case 1:
            imageName = @"label-anli";
            break;
        default:
            break;
    }
    UIImage *image = [UIImage imageNamed:imageName];
    typeAttchment.image = image;//设置图片
    NSAttributedString *typeString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(typeAttchment)];
    [muAttStr insertAttributedString:typeString atIndex:0];
    _contentAttStr = muAttStr;
}
@end
