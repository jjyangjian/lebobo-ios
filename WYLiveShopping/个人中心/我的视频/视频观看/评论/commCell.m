//
//  commCell.m
//  yunbaolive
//
//  Created by Boom on 2018/12/17.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "commCell.h"
#import "commDetailCell.h"
#import "detailmodel.h"
#import "PublicObj.h"
@implementation commCell{
    NSString *lastid;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setModel:(commentModel *)model{
    _model = model;
    NSLog(@"_replyArray=%@",_model.replyList);
    _replyArray = [_model.replyList mutableCopy];
    [_iconImgView sd_setImageWithURL:[NSURL URLWithString:_model.avatar_thumb]];
    _nameL.text = _model.user_nicename;
    _timeL.text = _model.datetime;
    _zanNumL.text = _model.likes;
    if ([_model.islike isEqual:@"1"]) {
        [_zanBtn setImage:[UIImage imageNamed:@"likecomment-click"] forState:0];
        _zanNumL.textColor = RGB_COLOR(@"#fa561f", 1);
    }else{
        [_zanBtn setImage:[UIImage imageNamed:@"likecomment"] forState:0];
        _zanNumL.textColor = RGB(130, 130, 130);
    }
    //匹配表情文字
    NSArray *resultArr  = [[WYToolClass sharedInstance] machesWithPattern:emojiPattern andStr:_model.content];
    if (!resultArr) return;
    NSUInteger lengthDetail = 0;
    NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc]initWithString:_model.content];
    //遍历所有的result 取出range
    for (NSTextCheckingResult *result in resultArr) {
        //取出图片名
        NSString *imageName =   [_model.content substringWithRange:NSMakeRange(result.range.location, result.range.length)];
        NSLog(@"--------%@",imageName);
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        UIImage *emojiImage = [UIImage imageNamed:imageName];
        NSAttributedString *imageString;
        if (emojiImage) {
            attach.image = emojiImage;
            attach.bounds = CGRectMake(0, -2, 15, 15);
            imageString =   [NSAttributedString attributedStringWithAttachment:attach];
        }else{
            imageString =   [[NSMutableAttributedString alloc]initWithString:imageName];
        }
        //图片附件的文本长度是1
        NSLog(@"emoj===%zd===size-w:%f==size-h:%f",imageString.length,imageString.size.width,imageString.size.height);
        NSUInteger length = attstr.length;
        NSRange newRange = NSMakeRange(result.range.location - lengthDetail, result.range.length);
        [attstr replaceCharactersInRange:newRange withAttributedString:imageString];
        
        lengthDetail += length - attstr.length;
    }

//    NSAttributedString *dateStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" \n\n%@",_model.datetime] attributes:@{NSForegroundColorAttributeName:RGB_COLOR(@"#959697", 1),NSFontAttributeName:[UIFont systemFontOfSize:11]}];
//    [attstr appendAttributedString:dateStr];
    //更新到label上
    [_replyTable reloadData];

    _contentL.attributedText = attstr;

    if ([_model.replys intValue] > 0) {

        CGFloat HHHH = 0.0;
        for (NSDictionary *dic in _replyArray) {
            detailmodel *model = [[detailmodel alloc]initWithDic:dic];
            HHHH += model.rowH;
        }
        if (_replyArray.count < 3 || ([_replyArray count] == 3 && !_model.isMore)) {
            _tableHeight.constant = HHHH;
        }else{
            if (!_replyBottomView) {
                _replyBottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
                _replyBottomView.backgroundColor = [UIColor whiteColor];
                //回复
                _Reply_Button = [UIButton buttonWithType:0];
                _Reply_Button.backgroundColor = [UIColor clearColor];
                _Reply_Button.titleLabel.textAlignment = NSTextAlignmentLeft;
                _Reply_Button.titleLabel.font = [UIFont systemFontOfSize:12];
                [_Reply_Button setTitleColor:RGB_COLOR(@"#4998F7", 1) forState:0];
                [_Reply_Button setTitleColor:RGB_COLOR(@"#4998F7", 1) forState:UIControlStateSelected];
                [_Reply_Button addTarget:self action:@selector(makeReply) forControlEvents:UIControlEventTouchUpInside];
                [_Reply_Button setTitle:@"展开更多回复" forState:0];
                [_Reply_Button setTitle:@"收起" forState:UIControlStateSelected];
                [_replyBottomView addSubview:_Reply_Button];
                
                [_Reply_Button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.top.bottom.equalTo(_replyBottomView);
                }];
                
            }
            _replyTable.tableFooterView = _replyBottomView;
            _Reply_Button.selected = !_model.isMore;

            if (_Reply_Button.hidden) {
                _replyTable.tableFooterView = nil;
                _tableHeight.constant = HHHH;
            }else{
                _tableHeight.constant = HHHH+20;
            }

        }

    }else{
        _tableHeight.constant = 0;
        _replyTable.tableFooterView = nil;
    }


}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _replyArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    commDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commDetailCELL"];
    if (!cell) {
        cell = [[commDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commDetailCell"];
        
    }

    detailmodel *model = [[detailmodel alloc]initWithDic:_replyArray[indexPath.row]];
    cell.model = model;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    detailmodel *model = [[detailmodel alloc]initWithDic:_replyArray[indexPath.row]];
    return model.rowH;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *subdic = _replyArray[indexPath.row];
    
    [self.delegate pushDetails:subdic];
}

- (void)makeReply{
    if (_Reply_Button.selected) {
        NSMutableArray *muaaaa = [NSMutableArray array];
        for (int i = 0; i < _replyArray.count; i ++) {
            if (i < 3) {
                [muaaaa addObject:_replyArray[i]];
            }
        }
        _replyArray = muaaaa;
        _model.isMore = YES;
        _model.replyList = _replyArray;
        [self.delegate reloadCurCell:_model andIndex:_curIndex andReplist:_replyArray];
    }else{
        lastid = @"0";

        if (_replyArray.count > 0) {
            lastid = minstr([[_replyArray lastObject] valueForKey:@"id"]);
        }
        [self requestData];
    }
}
- (void)requestData{
    [WYToolClass getQCloudWithUrl:[NSString stringWithFormat:@"videocomment&vid=%@&cid=%@&lastid=%@",_model.videoID,_model.parentid,lastid] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
//            if ([info count]>0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _model.isMore = [minstr([info valueForKey:@"ismore"]) intValue];
                    [_replyArray addObjectsFromArray:[info valueForKey:@"list"]];
                    _model.replyList = _replyArray;
                    if (!_model.isMore && _replyArray.count > 3) {
                        _Reply_Button.selected = NO;
                    }else{
                        _Reply_Button.selected = YES;
                    }
        //            [_replyTable reloadData];
                    [self.delegate reloadCurCell:_model andIndex:_curIndex andReplist:_replyArray];

                });
//            }
        }else{
            [MBProgressHUD showError:msg];
        }
    } Fail:^{
    }];


}
- (IBAction)zanBtnClick:(id)sender {

    if ([[Config getOwnID] intValue]<0) {
        [[WYToolClass sharedInstance] quitLogin];
        return;
    }
    if ([_model.ID isEqual:[Config getOwnID]]) {
        [MBProgressHUD showError:@"不能给自己的评论点赞"];
        
        return;
    }
    if ([[Config getOwnID] intValue] < 0) {
        //[self.delegate youkedianzan];
        return;
    }
    //_bigbtn.userInteractionEnabled = NO;
//    NSString *url = [purl stringByAppendingFormat:@"?service=Video.addCommentLike&uid=%@&commentid=%@&token=%@",[Config getOwnID],_model.parentid,[Config getOwnToken]];
    [WYToolClass postNetworkWithUrl:@"videocommentlike" andParameter:@{@"cid":_model.parentid,@"type":[_model.islike isEqual:@"1"] ? @"0" : @"1"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_zanBtn.imageView.layer addAnimation:[PublicObj bigToSmallRecovery] forKey:nil];
            });

            NSString *islike = [_model.islike isEqual:@"1"] ? @"0" : @"1";
            NSString *likes = [NSString stringWithFormat:@"%@",[info valueForKey:@"likes"]];

            [self.delegate makeLikeRloadList:_model.parentid andLikes:likes islike:islike];
        }else{
            [MBProgressHUD showError:msg];
        }

    } fail:^{
        
    }];
//    [YBNetworking postWithUrl:url Dic:nil Suc:^(NSDictionary *data, NSString *code, NSString *msg) {
//        if ([code isEqual:@"0"]) {
//            //动画
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [_zanBtn.imageView.layer addAnimation:[PublicObj bigToSmallRecovery] forKey:nil];
//            });
//
//            NSDictionary *info = [[data valueForKey:@"info"] firstObject];
//            NSString *islike = [NSString stringWithFormat:@"%@",[info valueForKey:@"islike"]];
//            NSString *likes = [NSString stringWithFormat:@"%@",[info valueForKey:@"likes"]];
//
//            [self.delegate makeLikeRloadList:_model.parentid andLikes:likes islike:islike];
//        }else{
//            [MBProgressHUD showError:msg];
//        }
//    } Fail:nil];
    
}

@end
