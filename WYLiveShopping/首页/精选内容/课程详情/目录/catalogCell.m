//
//  catalogCell.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/12.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "catalogCell.h"

@implementation catalogCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setModel:(catalogModel *)model{
    _model = model;
    _timeL.text = @"";
    switch ([_model.type intValue]) {
        case 1:
            _typeImgV.image = [UIImage imageNamed:@"目录-图文"];
            _typeL.text = @"图文";
            break;
        case 2:
            _typeImgV.image = [UIImage imageNamed:@"目录-视频"];
            _typeL.text = @"视频";
            break;
        case 3:
            _typeImgV.image = [UIImage imageNamed:@"目录-语音"];
            _typeL.text = @"音频";
            break;
        case 4: case 5: case 6:
        {
            _typeImgV.image = [UIImage imageNamed:@"目录-讲解"];
            _typeL.text = @"直播";
        }
            break;
        case 7:
        {
            _typeImgV.image = [UIImage imageNamed:@"目录-白板"];
        }
        break;
        case 8:
        {
            _typeImgV.image = [UIImage imageNamed:@"目录-普通直播"];
        }
        break;
        default:
            break;
    }
    _titleL.attributedText = [self getPicAndWord:[_model.islast isEqual:@"1"] ? YES : NO];
//    if ([_model.isenter isEqual:@"1"]) {
        _titleL.textColor = color32;
//    }else{
//        _titleL.textColor = color96;
//    }

//    if ([_model.type intValue] > 3) {
//        /// 形式，1图文2视频3音频4ppt直播5视频直播6音频直播7授课直播（白板）
//
//        switch ([_model.type intValue]) {
//            case 4:
//                _timeL.text = [NSString stringWithFormat:@"%@ PPT讲解",_model.time_date];
//                break;
//            case 5:
//                _timeL.text = [NSString stringWithFormat:@"%@ 视频讲解",_model.time_date];
//                break;
//            case 6:
//                _timeL.text = [NSString stringWithFormat:@"%@ 音频讲解",_model.time_date];
//                break;
//            case 7:
//                _timeL.text = [NSString stringWithFormat:@"%@ 白板互动",_model.time_date];
//                break;
//            case 8:
//                _timeL.text = [NSString stringWithFormat:@"%@ 普通直播",_model.time_date];
//                break;
//
//            default:
//                break;
//        }
//    }else{
        _timeL.text = @"";
//    }
    //状态 0正常 1试学2已学完3正在直播4锁
//    if ([_model.status isEqual:@"0"]) {
//        _lockImgV.hidden = YES;
//        _statusL.text = @"";
//    }else if ([_model.status isEqual:@"1"]) {
//        _lockImgV.hidden = YES;
//        _statusL.text = @"试学";
//        _statusL.textColor = normalColors;
//    }else if ([_model.status isEqual:@"2"]) {
//        _lockImgV.hidden = YES;
//        _statusL.text = @"已学完";
//        _statusL.textColor = RGB_COLOR(@"#C7C7C7", 1);
//    }else if ([_model.status isEqual:@"3"]) {
//        _lockImgV.hidden = YES;
//        _statusL.text = @"进入直播";
//        _statusL.textColor = normalColors;
//    }else {
//        _lockImgV.hidden = NO;
//        _statusL.text = @"";
//    }
    _lockImgV.hidden = YES;

    /*
            if([_model.islive isEqual:@"1"]){
                _lockImgV.hidden = YES;
                _statusL.text = @"正在直播";
                _statusL.textColor = normalColors;
    //            _timeL.text = _model.time_date;
            }else if([_model.islive isEqual:@"2"]){
                _lockImgV.hidden = YES;
                _statusL.text = @"直播已结束";
                _statusL.textColor = RGB_COLOR(@"#C7C7C7", 1);
    //            _timeL.text = _model.time_date;
            }else{
                _statusL.text = @"";
                _lockImgV.hidden = NO;
    //            _timeL.text = _model.time_date;
            }

    if ([_model.ifbuy isEqual:@"1"]) {
        if ([_model.status isEqual:@"2"]) {
            _lockImgV.hidden = YES;
            _statusL.text = @"已学完";
            _statusL.textColor = RGB_COLOR(@"#C7C7C7", 1);
        }else if ([_model.status isEqual:@"1"]) {
            _lockImgV.hidden = YES;
            _statusL.text = @"";
            _statusL.textColor = RGB_COLOR(@"#C7C7C7", 1);
        }else if ([_model.status isEqual:@"3"]){
            _lockImgV.hidden = NO;
            _statusL.text = @"";
            _statusL.textColor = RGB_COLOR(@"#C7C7C7", 1);
        }else{
            _lockImgV.hidden = YES;
            _statusL.text = @"";
        }
    }
    else{
        if ([_model.istrial isEqual:@"1"]) {
            _lockImgV.hidden = YES;
            _statusL.text = @"试学";
            _statusL.textColor = normalColors;
            _titleL.textColor = color32;
        }else{
            _lockImgV.hidden = YES;
            _titleL.textColor = color96;
        }

    }
    
    */

}
- (NSAttributedString *)getPicAndWord:(BOOL)isImage{
    NSMutableAttributedString *muArr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",_model.name]];
    if (isImage) {
        NSTextAttachment *typeAttchment = [[NSTextAttachment alloc]init];
        typeAttchment.bounds = CGRectMake(0, -2, 46, 15);//设置frame
        UIImage *image;
            image = [UIImage imageNamed:@"上次学到"];
        typeAttchment.image = image;//设置图片
        NSAttributedString *typeString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(typeAttchment)];
        [muArr appendAttributedString:typeString];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];        //设置行间距
    [muArr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [muArr length])];
    return muArr;
}

@end
